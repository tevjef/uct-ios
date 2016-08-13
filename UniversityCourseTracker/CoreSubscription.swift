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


class CoreSubscription: NSManagedObject {
    
    class func getAllSubscription(ctx: NSManagedObjectContext) -> [Subscription] {
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
            Timber.e("Failed getting all subscriptions \(error)")
            fatalError()
        }
    }
    
    class func getSubscription(ctx: NSManagedObjectContext, topicName: String) -> Subscription? {
        do {
            var subscriptions = [Subscription]()
            for coreSubscription in try getCoreSubscriptions(ctx, topicName: topicName) {
                let subscription = subscriptionFromCore(coreSubscription)
                if subscription != nil {
                    subscriptions.append(subscription!)
                }
            }
            
            if subscriptions.count == 0 {
                Timber.d("No subscription found for \(topicName)")
                return nil
            }
            
            if subscriptions.count > 1 {
                Timber.e("Multiple universities found while getting \(topicName)")
                fatalError()
            }
            
            return subscriptions.first
        } catch {
            Timber.e("Failed getting subscription \(error)")
            fatalError()
        }
    }
    
    class func upsertSubscription(ctx: NSManagedObjectContext, subscription: Subscription) {
            
        do {
            let fetchedCoreSubscriptions = try getCoreSubscriptions(ctx, topicName: subscription.sectionTopicName)
            if fetchedCoreSubscriptions.count > 1 {
                // TODO code smell, deletes potential duplicated subscriptions
                for index in 1..<fetchedCoreSubscriptions.count {
                    ctx.deleteObject(fetchedCoreSubscriptions[index])
                }
            } else if fetchedCoreSubscriptions.count == 0 {
                let coreSubscription = CoreSubscription(context: ctx)
                coreSubscription.insert(subscription)
            } else if fetchedCoreSubscriptions.count == 1 {
                let subscriptionToUpdate = fetchedCoreSubscriptions.first
                subscriptionToUpdate!.update(subscription)
            } else {
                Timber.e("Logic error while upserting subscription")
            }
        } catch {
            Timber.e("Failed to remove subscription \(error)")
        }
    }
    
    class func removeSubscription(ctx: NSManagedObjectContext, topicName: String) -> Int {
        var count = 0

        do {
            let fetchedCoreSubscriptions = try getCoreSubscriptions(ctx, topicName: topicName)
            if fetchedCoreSubscriptions.count == 0 {
                Timber.e("Attempted to remove subscription that did not exist")
            } else if fetchedCoreSubscriptions.count > 1 {
                Timber.e("Multiple topics with same name found: \(topicName)")
            }
            
            for obj in fetchedCoreSubscriptions {
                count += 1
                ctx.deleteObject(obj)
            }
            
            try ctx.save()
            
        } catch {
            Timber.e("Failed to remove subscription \(error)")
        }
        
        return count
    }
    
    override class func entityName() -> String {
        return AppConstants.CoreData.subscriptions
    }
    
    private class func requestAllSubscriptions() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: CoreSubscription.entityName())
        
        return fetchRequest
    }
    
    private class func resquestSubscriptionByTopicName(topicName: String) -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: CoreSubscription.entityName())
        fetchRequest.predicate = getFilterPredicate(topicName)
        
        return fetchRequest
    }
    
    private class func getFilterPredicate(topicName: String) -> NSPredicate {
        return NSPredicate(format: "topicName = %@", topicName)
    }
    
    private class func subscriptionFromCore(coreSubscription: CoreSubscription) -> Subscription? {
        do {
            if coreSubscription.university != nil {
                let uni = try University.parseFromData(coreSubscription.university!)
                return Subscription(topicName: coreSubscription.topicName!, university: uni)
            }
        } catch {
            Timber.e("Failed parsing university \(error)")
        }
        
        return nil
    }
    
    private func insert(subscription: Subscription) {
        let data = subscription.university!.data()
        
        university = data
        topicName = subscription.sectionTopicName
        
        do {
            try managedObjectContext?.save()
        } catch {
            Timber.e("Failed to insert subscription \(error)")
        }
    }
    
    private func update(subscription: Subscription) {
        let data = subscription.university!.data()
        
        university = data
        topicName = subscription.sectionTopicName
        
        do {
            try managedObjectContext?.save()
        } catch {
            Timber.e("Failed to insert subscription \(error)")
        }
    }
    
    private class func getCoreSubscriptions(ctx: NSManagedObjectContext, topicName: String) throws -> [CoreSubscription] {
        let requestByTopicName = CoreSubscription.resquestSubscriptionByTopicName(topicName)
        let fetchedCoreSubscriptions = try ctx.executeFetchRequest(requestByTopicName) as! [CoreSubscription]
        
        return fetchedCoreSubscriptions
    }
    
    private class func getAllCoreSubscriptions(ctx: NSManagedObjectContext) throws -> [CoreSubscription] {
        let requestAll = CoreSubscription.requestAllSubscriptions()
        let fetchedCoreSubscriptions = try ctx.executeFetchRequest(requestAll) as! [CoreSubscription]
        
        return fetchedCoreSubscriptions
    }


}
