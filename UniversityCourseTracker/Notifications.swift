//
//  Notification.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/12/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import UIKit

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
        registerAction.activationMode = UIUserNotificationActivationMode.Foreground
        registerAction.authenticationRequired = false
        registerAction.destructive = false
        
        let unsubAction = UIMutableUserNotificationAction()
        unsubAction.identifier = "UNSUBSCRIBE_ACTION"
        unsubAction.title = "Unsubscribe"
        unsubAction.activationMode = UIUserNotificationActivationMode.Background
        unsubAction.authenticationRequired = false
        unsubAction.destructive = true
        
        let sectionNotificationCategory = UIMutableUserNotificationCategory()
        sectionNotificationCategory.identifier = "SECTION_NOTIFICATION_CATEGORY"
        
        sectionNotificationCategory.setActions([registerAction, unsubAction],
                                               forContext: UIUserNotificationActionContext.Default)
        
        sectionNotificationCategory.setActions([registerAction, unsubAction],
                                               forContext: UIUserNotificationActionContext.Minimal)
        var set = Set<UIUserNotificationCategory>()
        set.insert(sectionNotificationCategory)
        return set
    }
    
    func scheduleNotification() {
        appDelegate.reporting?.logReceiveNotification(section.topicName)

        let application: UIApplication = UIApplication.sharedApplication()
        let title: String = "A section has opened!"
        let body: String = "Section \(section.number) of \(course.name) has opened! GO! GO! GO!"
        
        let notification = UILocalNotification()
        notification.category = Id.sectionNotificationCategoryId
        notification.alertBody = body
        notification.alertAction = "Open" // text that is displayed after "slide to..." on the lock screen - defaults to "slide to view"
        notification.fireDate = NSDate(timeIntervalSinceNow: AppDelegate.isUserPaid() ? 0 : 900)// todo item due date (when notification will be fired)
        notification.soundName = UILocalNotificationDefaultSoundName // play default sound
        notification.userInfo = ["registrationPage": university.registrationPage,
                                 "topicName": section.topicName,
                                 "status": section.status]
        notification.applicationIconBadgeNumber = 1
        
        if application.applicationState == UIApplicationState.Inactive {
            Timber.d("Incoming notification while inactive")
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
        } else if application.applicationState == UIApplicationState.Background {
            Timber.d("Incoming notification while in background");
            UIApplication.sharedApplication().scheduleLocalNotification(notification)
            
        } else if application.applicationState == UIApplicationState.Active {
            let sectionAlert: UIAlertController = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.Alert)
            sectionAlert.addAction(UIAlertAction(title: "Register", style: .Default, handler: { action in self.register(self.university.registrationPage) }))
            sectionAlert.addAction(UIAlertAction(title: "Unsubscribe", style: .Destructive, handler: { action in self.unsubscribe(self.section.topicName) }))
            sectionAlert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: nil))
            
            self.appDelegate.window?.rootViewController?.presentViewController(sectionAlert, animated: true, completion: nil)
        }
    }
    
    class func makeGenericAlert(title: String?, message: String) -> UIAlertController {
        var messageTitle: String
        if title != nil {
            messageTitle = title!
        } else {
            messageTitle = AppConstants.Notification.genericNotificationTitle
        }
        
        let sectionAlert: UIAlertController = UIAlertController(title: messageTitle, message: message,
                                                                preferredStyle: UIAlertControllerStyle.Alert)
        sectionAlert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        return sectionAlert
    }
    
    func register(url: String) {
        appDelegate.openUrl(url)
    }
    
    func unsubscribe(topicName: String) {
        appDelegate.coreDataManager?.removeSubscription(topicName)
    }
    
    class func incrementBadge() {
        if UIApplication.sharedApplication().applicationState == UIApplicationState.Active {
            return
        }
        UIApplication.sharedApplication().applicationIconBadgeNumber += 1
    }
    
    class func decrementBadge() {
        let number = UIApplication.sharedApplication().applicationIconBadgeNumber
        if number > 0 {
            UIApplication.sharedApplication().applicationIconBadgeNumber -= 1
        }
    }
    
    class func resetBadge() {
        UIApplication.sharedApplication().applicationIconBadgeNumber = 0
    }
    
    struct Id {
        static let registerActionId = "REGISTER_ACTION"
        static let unsubscribeActionId = "UNSUBSCRIBE_ACTION"
        static let sectionNotificationCategoryId = "SECTION_NOTIFICATION_CATEGORY"
    }
}
