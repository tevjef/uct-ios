//
//  AppConfigruation.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/31/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import CoreData

// The holiest of god objects
class CoreDataManager: NSObject {
  
    let appDelegate: AppDelegate
    
    let moc: NSManagedObjectContext
    
    init(appDelegate: AppDelegate)  {
        self.appDelegate = appDelegate
        moc = appDelegate.managedObjectContext
    }
    
    func addSubscription(subscription: Subscription) {
        Timber.d("Adding subscription=\(subscription.description)")
        CoreSubscription.upsertSubscription(moc, subscription: subscription)
    }
    
    func removeSubscription(topicName: String) -> Int {
        Timber.d("Removing subscription=\(topicName)")
        return CoreSubscription.removeSubscription(moc, topicName: topicName)
    }
    
    func updateSubscription(subscription: Subscription) {
        Timber.d("Updating subscription=\(subscription.description)")
        CoreSubscription.upsertSubscription(moc, subscription: subscription)
    }
    
    func getSubscription(topicName: String) -> Subscription? {
        let subscription = CoreSubscription.getSubscription(moc, topicName: topicName)
        Timber.d("Getting subscription=\(topicName) returning=\(subscription.debugDescription)")
        return subscription
    }
    
    func getAllSubscriptions() -> [Subscription] {
        let subscriptions = CoreSubscription.getAllSubscription(moc)
        Timber.d("Getting all subscriptions returning=\(subscriptions.count)")
        return subscriptions
    }
    
    var cachedUniverisity: University?
    var cachedSemester: Semester?
    
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
    }
    
    private func updateSemester(semester: Semester)  {
        Timber.d("Updating semester=\(semester.description)")
        
        // Invalidate cache
        cachedSemester = nil
        CoreUserDefault.saveSemester(moc, data: semester)
    }
}