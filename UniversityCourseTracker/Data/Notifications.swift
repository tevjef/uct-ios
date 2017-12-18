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
import UserNotifications

class Notifications {
    
    let appDelegate: AppDelegate
    let firebaseManager: FirebaseManager
    let reporting: Reporting

    var uctNotification: Uctnotification = Uctnotification.Builder().buildPartial()
    var university: University = University.Builder().buildPartial()
    var subject: Subject = Subject.Builder().buildPartial()
    var course: Course = Course.Builder().buildPartial()
    var section: Section = Section.Builder().buildPartial()
    
    static var shared: Notifications?
    
    init(_ appDelegate: AppDelegate, _ firebaseManager: FirebaseManager,  _ reporting: Reporting) {
        self.appDelegate = appDelegate
        self.reporting = reporting
        self.firebaseManager = firebaseManager
        Notifications.shared = self
    }

    func setNotificationData(_ uctNotification: Uctnotification) {
        self.uctNotification = uctNotification
        self.university = uctNotification.university
        self.subject = university.subjects.first!
        self.course = subject.courses.first!
        self.section = course.sections.first!
    }
    
    class func setCategories()  {
        let registerAction = UNNotificationAction(
            identifier: Id.registerActionId,
            title: "Register",
            options: [.foreground]
        )
        let unsubAction = UNNotificationAction(
            identifier: Id.unsubscribeActionId,
            title: "Unsubscribe",
            options: [.foreground, .destructive]
        )

        let sectionNotificationCategory = UNNotificationCategory(
            identifier: Id.sectionNotificationCategoryId,
            actions: [registerAction, unsubAction],
            intentIdentifiers: [],
            options: []
        )
        UNUserNotificationCenter.current().setNotificationCategories([sectionNotificationCategory])
    }
    
    
    class func makeCategories() -> Set<UIUserNotificationCategory> {
        let registerAction = UIMutableUserNotificationAction()
        registerAction.identifier = Id.registerActionId
        registerAction.title = "Register"
        registerAction.activationMode = UIUserNotificationActivationMode.foreground
        registerAction.isAuthenticationRequired = false
        registerAction.isDestructive = false
    
        let unsubAction = UIMutableUserNotificationAction()
        unsubAction.identifier = Id.unsubscribeActionId
        unsubAction.title = "Unsubscribe"
        unsubAction.activationMode = UIUserNotificationActivationMode.background
        unsubAction.isAuthenticationRequired = false
        unsubAction.isDestructive = true
    
        let sectionNotificationCategory = UIMutableUserNotificationCategory()
        sectionNotificationCategory.identifier = Id.sectionNotificationCategoryId
    
        sectionNotificationCategory.setActions([registerAction, unsubAction],
                                           for: UIUserNotificationActionContext.default)
    
        sectionNotificationCategory.setActions([registerAction, unsubAction],
                                           for: UIUserNotificationActionContext.minimal)
        var set = Set<UIUserNotificationCategory>()
        set.insert(sectionNotificationCategory)
        return set
    }
    
    func scheduleNotification() {
        reporting.logReceiveNotification(section.topicId, section.topicName, uctNotification.notificationId.description)
        let application: UIApplication = UIApplication.shared
        let center = UNUserNotificationCenter.current()
        
        var title: String = "A section has opened!"
        var body: String = "Section \(section.number) of \(course.name) has opened! GO! GO! GO!"
        
        let content = UNMutableNotificationContent()

        let closed = section.status == "Closed"
        if closed {
            title = "A section has closed"
            body = "Section \(section.number) of \(course.name) has closed!"
            content.categoryIdentifier = "nil"
        } else {
            content.categoryIdentifier = Id.sectionNotificationCategoryId
        }

        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        content.badge = 1
        content.categoryIdentifier = Id.sectionNotificationCategoryId
        content.userInfo = ["registrationPage": university.registrationPage,
                           "topicName": section.topicName,
                           "status": section.status]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 0, repeats: false)
        let identifier = section.topicName + section.status
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                DDLogError("Error when creating notification" + error.localizedDescription)
            }
        })
        
        if application.applicationState == UIApplicationState.active {
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

        firebaseManager.acknowledgeNotification(uctNotification.notificationId.description, section.topicName)
    }
    
    func requestNotificationPermission() {
        //let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: Notifications.makeCategories())
        //UIApplication.shared.registerUserNotificationSettings(settings)
        //UIApplication.shared.registerForRemoteNotifications()
        
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options:[.badge, .alert, .sound]){[weak self](granted, error) in
                guard error == nil else {
                    return
                }
                
                if granted {
                    UNUserNotificationCenter.current().delegate = self?.appDelegate
                    Notifications.setCategories()
                }
            }
             UIApplication.shared.registerForRemoteNotifications()
        } else {
            let settings: UIUserNotificationSettings = UIUserNotificationSettings(types: [.alert, .badge, .sound], categories: Notifications.makeCategories())
            UIApplication.shared.registerUserNotificationSettings(settings)
            UIApplication.shared.registerForRemoteNotifications()
        }
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
        _ = appDelegate.coreDataManager?.removeSubscription(topicName)
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
