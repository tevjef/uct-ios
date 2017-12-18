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
class CoreDataManager {
  
    static let addSubscriptionNotification = "addSubscriptionNotification"
    static let removeSubscriptionNotification = "removeSubscriptionNotification"
    static let updateSubscriptionsNotification = "updateSubscriptionsNotification"

    fileprivate var cachedUniverisity: University?
    fileprivate var cachedSemester: Semester?

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

    let appDelegate: AppDelegate
    let firebaseManager: FirebaseManager
    let reporting: Reporting
    let dataRepo: DataRepos
    let moc: NSManagedObjectContext
    
    init(_ appDelegate: AppDelegate, _ firebaseManager: FirebaseManager, _ dataRepo: DataRepos, _ reporting: Reporting)  {
        self.appDelegate = appDelegate
        self.firebaseManager = firebaseManager
        self.reporting = reporting
        self.dataRepo = dataRepo
        moc = appDelegate.managedObjectContext.self
    }

    func addSubscription(_ subscription: Subscription) {
        DDLogDebug("Adding subscription=\(subscription.sectionTopicName)")
        CoreSubscription.upsertSubscription(moc, subscription: subscription)
        firebaseManager.subscribeToTopic(subscription.sectionTopicName)
        NotificationCenter.default.post(name: Notification.Name(rawValue: CoreDataManager.addSubscriptionNotification), object: self)

        let section = subscription.getSection()
        dataRepo.postSubscription(true, firebaseManager.fcmToken(), subscription.sectionTopicName)
        reporting.logSubscription(section.topicId, section.topicName)
    }
    
    func removeSubscription(_ topicName: String) -> Int {
        DDLogDebug("Removing subscription=\(topicName)")
        let subscription = getSubscription(topicName)

        firebaseManager.unsubscribeFromTopic(topicName)
        let numRemoved = CoreSubscription.removeSubscription(moc, topicName: topicName)
        NotificationCenter.default.post(name: Notification.Name(rawValue: CoreDataManager.removeSubscriptionNotification), object: self)

        dataRepo.postSubscription(false, firebaseManager.fcmToken(), topicName)

        if let section = subscription?.getSection() {
            reporting.logUnsubscription(section.topicId, section.topicName)
        }
        
        return numRemoved
    }
    
    func refreshAllSubscriptions(_ completion: (() -> Void)? = nil) {
        let group: DispatchGroup = DispatchGroup();
        
        DDLogDebug("Refreshing all sections...")
        let subscriptions = getAllSubscriptions()
        for sub in subscriptions {
            group.enter();
            appDelegate.dataRepo?.getSection(sub.sectionTopicName, {
                if let section = $0 {
                    // Resubscribe just in case the topic name had changed :(
                    self.firebaseManager.subscribeToTopic(section.topicName)
                    sub.updateSection(section)
                    sub.sectionTopicName = section.topicName
                    
                    self.updateSubscription(sub)
                }
                
                group.leave();
            })
        }
        
        group.notify(queue: GlobalMainQueue, execute: {
            if completion != nil {
                completion!()
            }
            NotificationCenter.default.post(name: Notification.Name(rawValue: CoreDataManager.updateSubscriptionsNotification), object: self)
        })
    }
    
    func updateSubscription(_ subscription: Subscription) {
        DDLogDebug("Updating subscription=\(subscription.sectionTopicName)")
        CoreSubscription.upsertSubscription(moc, subscription: subscription)
    }
    
    func getSubscription(_ topicName: String) -> Subscription? {
        let subscription = CoreSubscription.getSubscription(moc, topicName: topicName)
        DDLogDebug("Getting subscription=\(topicName) returning=\(subscription?.sectionTopicName ?? "")")
        return subscription
    }
    
    func getAllSubscriptions() -> [Subscription] {
        let subscriptions = CoreSubscription.getAllSubscription(moc)
        DDLogDebug("Getting all subscriptions returning=\(subscriptions.count)")
        return subscriptions
    }
    
    fileprivate func getUniversity() -> University? {
        let university: University?

        if cachedUniverisity != nil {
            university = cachedUniverisity
        } else {
            university = CoreUserDefault.getUniversity(moc)
        }
        
        DDLogDebug("Getting university returning=\(university?.topicName ?? "nil")")
        return university
    }
    
    fileprivate func getSemester() -> Semester? {
        let semester: Semester?
        
        if cachedSemester != nil {
            semester = cachedSemester
        } else {
            semester = CoreUserDefault.getSemester(moc)
        }
        
        DDLogDebug("Getting semester returning=\(semester?.readableString ?? "nil"))")
        return semester
    }
    
    fileprivate func updateUniversity(_ university: University) {
        DDLogDebug("Updating university=\(university.topicName)")
        
        // Invalidate cache
        cachedUniverisity = nil
        CoreUserDefault.saveUniversity(moc, data: university)
        reporting.logDefaultUniversity(university.topicName)
    }
    
    fileprivate func updateSemester(_ semester: Semester)  {
        DDLogDebug("Updating semester=\(semester.description)")
        
        // Invalidate cache
        cachedSemester = nil
        CoreUserDefault.saveSemester(moc, data: semester)
        reporting.logDefaultSemester(semester)
    }
}
