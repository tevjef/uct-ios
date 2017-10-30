//
//  Notification.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/12/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import UIKit
import CocoaLumberjack

class Notifications {
    
    let university: University
    let subject: Subject
    let course: Course
    let section: Section
    let appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate, university: University) {
        self.university = university
        self.subject = university.subjects.first!
        self.course = subject.courses.first!
        self.section = course.sections.first!
        self.appDelegate = appDelegate
    }
    
    class func makeCategories() -> Set<UIUserNotificationCategory> {
        let registerAction = UIMutableUserNotificationAction()
        registerAction.identifier = "REGISTER_ACTION"
        registerAction.title = "Register"
        registerAction.activationMode = UIUserNotificationActivationMode.foreground
        registerAction.isAuthenticationRequired = false
        registerAction.isDestructive = false
        
        let unsubAction = UIMutableUserNotificationAction()
        unsubAction.identifier = "UNSUBSCRIBE_ACTION"
        unsubAction.title = "Unsubscribe"
        unsubAction.activationMode = UIUserNotificationActivationMode.background
        unsubAction.isAuthenticationRequired = false
        unsubAction.isDestructive = true
        
        let sectionNotificationCategory = UIMutableUserNotificationCategory()
        sectionNotificationCategory.identifier = "SECTION_NOTIFICATION_CATEGORY"
        
        sectionNotificationCategory.setActions([registerAction, unsubAction],
                                               for: UIUserNotificationActionContext.default)
        
        sectionNotificationCategory.setActions([registerAction, unsubAction],
                                               for: UIUserNotificationActionContext.minimal)
        var set = Set<UIUserNotificationCategory>()
        set.insert(sectionNotificationCategory)
        return set
    }
    
    func scheduleNotification() {
        appDelegate.reporting?.logReceiveNotification(section.topicName)
        let application: UIApplication = UIApplication.shared
        
        let notification = UILocalNotification()
        notification.category = Id.sectionNotificationCategoryId
        
        var title: String = "A section has opened!"
        var body: String = "Section \(section.number) of \(course.name) has opened! GO! GO! GO!"
        
        let closed = section.status == "Closed"
        if closed {
            title = "A section has closed"
            body = "Section \(section.number) of \(course.name) has closed!"
            notification.category = nil
        }

        notification.alertBody = body
        notification.alertAction = "Open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = Date(timeIntervalSinceNow: AppDelegate.isUserPaid() ? 0 : 900)// todo item due date (when notification will be fired)
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = ["registrationPage": university.registrationPage,
                                 "topicName": section.topicName,
                                 "status": section.status]
        notification.applicationIconBadgeNumber = 1
        
        if application.applicationState == UIApplicationState.inactive {
            DDLogDebug("Incoming notification while inactive")
            UIApplication.shared.scheduleLocalNotification(notification)
            
        } else if application.applicationState == UIApplicationState.background {
            DDLogDebug("Incoming notification while in background");
            UIApplication.shared.scheduleLocalNotification(notification)
            
        } else if application.applicationState == UIApplicationState.active {
            let sectionAlert: UIAlertController = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
            if closed {
                sectionAlert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
            } else {
                sectionAlert.addAction(UIAlertAction(title: "Register", style: .default, handler: { action in self.register(self.university.registrationPage) }))
                sectionAlert.addAction(UIAlertAction(title: "Unsubscribe", style: .destructive, handler: { action in self.unsubscribe(self.section.topicName) }))
                sectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }

            
            self.appDelegate.window?.rootViewController?.present(sectionAlert, animated: true, completion: nil)
        }
    }
    
    class func requestNotificationPermission() {
        let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: Notifications.makeCategories())
        UIApplication.shared.registerUserNotificationSettings(settings)
        UIApplication.shared.registerForRemoteNotifications()
        
       // var settings = UIApplication.sharedApplication().currentUserNotificationSettings()

    }
    
    class func makeGenericAlert(_ title: String?, message: String) -> UIAlertController {
        var messageTitle: String
        if title != nil {
            messageTitle = title!
        } else {
            messageTitle = AppConstants.Notification.genericNotificationTitle
        }
        
        let sectionAlert: UIAlertController = UIAlertController(title: messageTitle, message: message,
                                                                preferredStyle: UIAlertControllerStyle.alert)
        sectionAlert.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        return sectionAlert
    }
    
    func register(_ url: String) {
        appDelegate.openUrl(url)
    }
    
    func unsubscribe(_ topicName: String) {
        appDelegate.coreDataManager?.removeSubscription(topicName)
    }
    
    class func incrementBadge() {
        if UIApplication.shared.applicationState == UIApplicationState.active {
            return
        }
        UIApplication.shared.applicationIconBadgeNumber += 1
    }
    
    class func decrementBadge() {
        let number = UIApplication.shared.applicationIconBadgeNumber
        if number > 0 {
            UIApplication.shared.applicationIconBadgeNumber -= 1
        }
    }
    
    class func resetBadge() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
    
    struct Id {
        static let registerActionId = "REGISTER_ACTION"
        static let unsubscribeActionId = "UNSUBSCRIBE_ACTION"
        static let sectionNotificationCategoryId = "SECTION_NOTIFICATION_CATEGORY"
    }
}
