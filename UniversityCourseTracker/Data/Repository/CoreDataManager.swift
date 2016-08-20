//
//  AppConfigruation.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/31/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import CoreData
import FirebaseMessaging
import CocoaLumberjack

// The holiest of god objects
class CoreDataManager: NSObject {
  
    static let addSubscriptionNotification = "addSubscriptionNotification"
    static let removeSubscriptionNotification = "removeSubscriptionNotification"
    static let updateSubscriptionsNotification = "updateSubscriptionsNotification"

    let appDelegate: AppDelegate
    let firebaseManager: FirebaseManager
    
    let moc: NSManagedObjectContext
    
    init(appDelegate: AppDelegate, firebaseManager: FirebaseManager)  {
        self.appDelegate = appDelegate
        self.firebaseManager = firebaseManager
        moc = appDelegate.managedObjectContext.self
    }
    
    func addSubscription(subscription: Subscription) {
        DDLogDebug("Adding subscription=\(subscription.sectionTopicName)")
        CoreSubscription.upsertSubscription(moc, subscription: subscription)
        firebaseManager.subscribeToTopic(subscription.sectionTopicName)
        NSNotificationCenter.defaultCenter().postNotificationName(CoreDataManager.addSubscriptionNotification, object: self)
        
        appDelegate.reporting?.logSubscription(subscription.getSection().topicId)
    }
    
    func removeSubscription(topicName: String) -> Int {
        DDLogDebug("Removing subscription=\(topicName)")
        let subscription = getSubscription(topicName)

        firebaseManager.unsubscribeFromTopic(topicName)
        let numRemoved = CoreSubscription.removeSubscription(moc, topicName: topicName)
        NSNotificationCenter.defaultCenter().postNotificationName(CoreDataManager.removeSubscriptionNotification, object: self)
        
        appDelegate.reporting?.logUnsubscription(subscription?.getSection().topicId ?? "")
        return numRemoved
    }
    
    func refreshAllSubscriptions(completion: (() -> Void)? = nil) {
        let group: dispatch_group_t = dispatch_group_create();
        
        DDLogDebug("Refreshing all sections...")
        let subscriptions = getAllSubscriptions()
        for sub in subscriptions {
            dispatch_group_enter(group);
            appDelegate.dataRepo?.getSection(sub.sectionTopicName, {
                if let section = $0 {
                    // Resubscribe just in case the topic name had changed :(
                    self.firebaseManager.subscribeToTopic(section.topicName)
                    sub.updateSection(section)
                    sub.sectionTopicName = section.topicName
                    
                    self.updateSubscription(sub)
                }
                
                dispatch_group_leave(group);
            })
        }
        
        dispatch_group_notify(group, GlobalMainQueue, {
            if completion != nil {
                completion!()
            }
            NSNotificationCenter.defaultCenter().postNotificationName(CoreDataManager.updateSubscriptionsNotification, object: self)
        })
    }
    
    func updateSubscription(subscription: Subscription) {
        DDLogDebug("Updating subscription=\(subscription.sectionTopicName)")
        CoreSubscription.upsertSubscription(moc, subscription: subscription)
    }
    
    func getSubscription(topicName: String) -> Subscription? {
        let subscription = CoreSubscription.getSubscription(moc, topicName: topicName)
        DDLogDebug("Getting subscription=\(topicName) returning=\(subscription?.sectionTopicName ?? "")")
        return subscription
    }
    
    func getAllSubscriptions() -> [Subscription] {
        let subscriptions = CoreSubscription.getAllSubscription(moc)
        DDLogDebug("Getting all subscriptions returning=\(subscriptions.count)")
        return subscriptions
    }
    
    private var cachedUniverisity: University?
    private var cachedSemester: Semester?
    
    var university: University? {
        get {
            return getUniversity()
        }
        set(university) {
            updateUniversity(university!)
        }
    }
    
    var semester: Semester? {
        get {
            return getSemester()
        }
        set(semester) {
            updateSemester(semester!)
        }
    }
    
    private func getUniversity() -> University? {
        let university: University?

        if cachedUniverisity != nil {
            university = cachedUniverisity
        } else {
            university = CoreUserDefault.getUniversity(moc)
        }
        
        DDLogDebug("Getting university returning=\(university?.topicName ?? "nil")")
        return university
    }
    
    private func getSemester() -> Semester? {
        let semester: Semester?
        
        if cachedSemester != nil {
            semester = cachedSemester
        } else {
            semester = CoreUserDefault.getSemester(moc)
        }
        
        DDLogDebug("Getting semester returning=\(semester?.description ?? "nil")")
        return semester
    }
    
    private func updateUniversity(university: University) {
        DDLogDebug("Updating university=\(university.topicName)")
        
        // Invalidate cache
        cachedUniverisity = nil
        CoreUserDefault.saveUniversity(moc, data: university)
        appDelegate.reporting?.logChangeUniversity(university.topicId)
    }
    
    private func updateSemester(semester: Semester)  {
        DDLogDebug("Updating semester=\(semester.description)")
        
        // Invalidate cache
        cachedSemester = nil
        CoreUserDefault.saveSemester(moc, data: semester)
        appDelegate.reporting?.logChangeSemester(semester.readableString)
    }
}