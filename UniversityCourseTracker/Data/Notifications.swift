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

    static var shared: Notifications?

    init(_ appDelegate: AppDelegate, _ firebaseManager: FirebaseManager, _ reporting: Reporting) {
        self.appDelegate = appDelegate
        self.reporting = reporting
        self.firebaseManager = firebaseManager
        Notifications.shared = self
    }

    class func setCategories() {
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

    func scheduleNotification(
            _ title: String,
            _ body: String,
            _ status: String,
            _ notificationId: String,
            _ topicName: String,
            _ registrationUrl: String,
            _ topicId: String) {
        let application: UIApplication = UIApplication.shared
        let center = UNUserNotificationCenter.current()
        
        let content = UNMutableNotificationContent()

        let closed = status == "Closed"
        if closed {
            content.categoryIdentifier = "nil"
        } else {
            content.categoryIdentifier = Id.sectionNotificationCategoryId
        }

        content.title = title
        content.body = body
        content.sound = UNNotificationSound.default()
        content.badge = 1
        content.categoryIdentifier = Id.sectionNotificationCategoryId
        content.userInfo = ["registrationUrl":registrationUrl,
                           "topicName": topicName,
                           "status": status]
        
        let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 5, repeats: false)
        let identifier = topicName + status
        let request = UNNotificationRequest(identifier: identifier, content: content, trigger: trigger)
        center.add(request, withCompletionHandler: { (error) in
            if let error = error {
                DDLogError("Error when creating notification" + error.localizedDescription)
            }
        })
        
        if application.applicationState == UIApplicationState.active {
            let sectionAlert: UIAlertController = UIAlertController(title: title, message: body, preferredStyle: UIAlertControllerStyle.alert)
            if status != "Open" {
                sectionAlert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
            } else {
                sectionAlert.addAction(UIAlertAction(title: "Register", style: .default, handler: { action in self.register(registrationUrl) }))
                sectionAlert.addAction(UIAlertAction(title: "Unsubscribe", style: .destructive, handler: { action in self.unsubscribe(topicName) }))
                sectionAlert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
            }
            self.appDelegate.window?.rootViewController?.present(sectionAlert, animated: true, completion: nil)
        }

        reporting.logReceiveNotification(topicId, topicName, notificationId)
        firebaseManager.acknowledgeNotification(notificationId, topicName)
    }

    func requestNotificationPermission() {
        // iOS 10 support
        if #available(iOS 10, *) {
            UNUserNotificationCenter.current().requestAuthorization(options: [.badge, .alert, .sound]) { [weak self](granted, error) in
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
