//
//  CoreSubscription.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/6/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import CoreData
import FirebaseMessaging
import CocoaLumberjack

class CoreSubscription: NSManagedObject {
    
    class func getAllSubscription(_ ctx: NSManagedObjectContext) -> [Subscription] {
        do {
            var subscriptions = [Subscription]()
            for coreSubscription in try getAllCoreSubscriptions(ctx) {
                let subscription = subscriptionFromCore(coreSubscription)
                if subscription != nil {
                    subscriptions.append(subscription!)
                }
            }
            
            return subscriptions
        } catch {
            DDLogError("Failed getting all subscriptions \(error)")
            fatalError()
        }
    }
    
    class func getSubscription(_ ctx: NSManagedObjectContext, topicName: String) -> Subscription? {
        do {
            var subscriptions = [Subscription]()
            for coreSubscription in try getCoreSubscriptions(ctx, topicName: topicName) {
                let subscription = subscriptionFromCore(coreSubscription)
                if subscription != nil {
                    subscriptions.append(subscription!)
                }
            }
            
            if subscriptions.count == 0 {
                DDLogDebug("No subscription found for \(topicName)")
                return nil
            }
            
            if subscriptions.count > 1 {
                DDLogError("Multiple universities found while getting \(topicName)")
                fatalError()
            }
            
            return subscriptions.first
        } catch {
            DDLogError("Failed getting subscription \(error)")
            fatalError()
        }
    }
    
    class func upsertSubscription(_ ctx: NSManagedObjectContext, subscription: Subscription) {
            
        do {
            let fetchedCoreSubscriptions = try getCoreSubscriptions(ctx, topicName: subscription.sectionTopicName)
            if fetchedCoreSubscriptions.count > 1 {
                // TODO code smell, deletes potential duplicated subscriptions
                for index in 1..<fetchedCoreSubscriptions.count {
                    ctx.delete(fetchedCoreSubscriptions[index])
                }
            } else if fetchedCoreSubscriptions.count == 0 {
                let coreSubscription = CoreSubscription(context: ctx, dummy: "")
                coreSubscription.insert(subscription)
            } else if fetchedCoreSubscriptions.count == 1 {
                let subscriptionToUpdate = fetchedCoreSubscriptions.first
                subscriptionToUpdate!.update(subscription)
            } else {
                DDLogError("Logic error while upserting subscription")
            }
        } catch {
            DDLogError("Failed to remove subscription \(error)")
        }
    }
    
    class func removeSubscription(_ ctx: NSManagedObjectContext, topicName: String) -> Int {
        var count = 0

        do {
            let fetchedCoreSubscriptions = try getCoreSubscriptions(ctx, topicName: topicName)
            if fetchedCoreSubscriptions.count == 0 {
                DDLogError("Attempted to remove subscription that did not exist")
            } else if fetchedCoreSubscriptions.count > 1 {
                DDLogError("Multiple topics with same name found: \(topicName)")
            }
            
            for obj in fetchedCoreSubscriptions {
                count += 1
                ctx.delete(obj)
            }
            
            try ctx.save()
            
        } catch {
            DDLogError("Failed to remove subscription \(error)")
        }
        
        return count
    }
    
    override class func entityName() -> String {
        return AppConstants.CoreData.subscriptions
    }
    
    fileprivate class func requestAllSubscriptions() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest(entityName: CoreSubscription.entityName())
    }
    
    fileprivate class func resquestSubscriptionByTopicName(_ topicName: String) -> NSFetchRequest<NSFetchRequestResult> {
        let fetchRequest = NSFetchRequest<NSFetchRequestResult>(entityName: CoreSubscription.entityName())
        fetchRequest.predicate = getFilterPredicate(topicName)
        
        return fetchRequest
    }
    
    fileprivate class func getFilterPredicate(_ topicName: String) -> NSPredicate {
        return NSPredicate(format: "topicName = %@", topicName)
    }
    
    fileprivate class func subscriptionFromCore(_ coreSubscription: CoreSubscription) -> Subscription? {
        do {
            if coreSubscription.university != nil {
                let uni = try University.parseFrom(data: coreSubscription.university! as Data)
                return Subscription(topicName: coreSubscription.topicName!, university: uni)
            }
        } catch {
            DDLogError("Failed parsing university \(error)")
        }
        
        return nil
    }
    
    fileprivate func insert(_ subscription: Subscription) {
        let data = subscription.university!.data()
        
        university = data as NSData?
        topicName = subscription.sectionTopicName
        
        do {
            try managedObjectContext?.save()
        } catch {
            DDLogError("Failed to insert subscription \(error)")
        }
    }
    
    fileprivate func update(_ subscription: Subscription) {
        let data = subscription.university!.data()
        
        university = data as NSData?
        topicName = subscription.sectionTopicName
        
        do {
            try managedObjectContext?.save()
        } catch {
            DDLogError("Failed to insert subscription \(error)")
        }
    }
    
    fileprivate class func getCoreSubscriptions(_ ctx: NSManagedObjectContext, topicName: String) throws -> [CoreSubscription] {
        let requestByTopicName = CoreSubscription.resquestSubscriptionByTopicName(topicName)
        let fetchedCoreSubscriptions = try ctx.fetch(requestByTopicName) as! [CoreSubscription]
        
        return fetchedCoreSubscriptions
    }
    
    fileprivate class func getAllCoreSubscriptions(_ ctx: NSManagedObjectContext) throws -> [CoreSubscription] {
        let requestAll = CoreSubscription.requestAllSubscriptions()
        let fetchedCoreSubscriptions = try ctx.fetch(requestAll) as! [CoreSubscription]
        
        return fetchedCoreSubscriptions
    }


}
