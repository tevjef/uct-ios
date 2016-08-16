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
        Timber.d("Adding subscription=\(subscription.sectionTopicName)")
        CoreSubscription.upsertSubscription(moc, subscription: subscription)
        firebaseManager.subscribeToTopic("/topics/\(subscription.sectionTopicName)")
        NSNotificationCenter.defaultCenter().postNotificationName(CoreDataManager.addSubscriptionNotification, object: self)
        
        appDelegate.reporting?.logSubscription(subscription.getSection().topicId)
    }
    
    func removeSubscription(topicName: String) -> Int {
        Timber.d("Removing subscription=\(topicName)")
        let subscription = getSubscription(topicName)

        firebaseManager.unsubscribeFromTopic("/topics/\(topicName)")
        let numRemoved = CoreSubscription.removeSubscription(moc, topicName: topicName)
        NSNotificationCenter.defaultCenter().postNotificationName(CoreDataManager.removeSubscriptionNotification, object: self)
        
        appDelegate.reporting?.logUnsubscription(subscription?.getSection().topicId ?? "")
        return numRemoved
    }
    
    func refreshAllSubscriptions(completion: (() -> Void)? = nil) {
        let group: dispatch_group_t = dispatch_group_create();
        
        Timber.d("Refreshing all sections...")
        let subscriptions = getAllSubscriptions()
        for sub in subscriptions {
            dispatch_group_enter(group);
            appDelegate.dataRepo?.getSection(sub.sectionTopicName, {
                if let section = $0 {
                    sub.updateSection(section)
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
        Timber.d("Updating subscription=\(subscription.sectionTopicName)")
        CoreSubscription.upsertSubscription(moc, subscription: subscription)
    }
    
    func getSubscription(topicName: String) -> Subscription? {
        let subscription = CoreSubscription.getSubscription(moc, topicName: topicName)
        Timber.d("Getting subscription=\(topicName) returning=\(subscription?.sectionTopicName ?? "")")
        return subscription
    }
    
    func getAllSubscriptions() -> [Subscription] {
        let subscriptions = CoreSubscription.getAllSubscription(moc)
        Timber.d("Getting all subscriptions returning=\(subscriptions.count)")
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
        
        Timber.d("Getting university returning=\(university?.topicName ?? "nil")")
        return university
    }
    
    private func getSemester() -> Semester? {
        let semester: Semester?
        
        if cachedSemester != nil {
            semester = cachedSemester
        } else {
            semester = CoreUserDefault.getSemester(moc)
        }
        
        Timber.d("Getting semester returning=\(semester?.description ?? "nil")")
        return semester
    }
    
    private func updateUniversity(university: University) {
        Timber.d("Updating university=\(university.topicName)")
        
        // Invalidate cache
        cachedUniverisity = nil
        CoreUserDefault.saveUniversity(moc, data: university)
        appDelegate.reporting?.logChangeUniversity(university.topicId)
    }
    
    private func updateSemester(semester: Semester)  {
        Timber.d("Updating semester=\(semester.description)")
        
        // Invalidate cache
        cachedSemester = nil
        CoreUserDefault.saveSemester(moc, data: semester)
        appDelegate.reporting?.logChangeSemester(semester.readableString)
    }
}