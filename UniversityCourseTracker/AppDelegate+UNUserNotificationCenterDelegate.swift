//
// Created by Tevin Jeffrey on 12/3/17.
// Copyright (c) 2017 Tevin Jeffrey. All rights reserved.
//

import CocoaLumberjack
import Foundation
import UserNotifications

// [START ios_10_message_handling]
@available(iOS 10, *)
extension AppDelegate : UNUserNotificationCenterDelegate {

/*    // Receive displayed notifications for iOS 10 devices.
    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        let userInfo = notification.request.content.userInfo

        // With swizzling disabled you must let Messaging know about the message, for Analytics
        // Messaging.messaging().appDidReceiveMessage(userInfo)
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        // Change this to your preferred presentation option
        completionHandler([])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {
        let userInfo = response.notification.request.content.userInfo
        // Print message ID.
        if let messageID = userInfo[gcmMessageIDKey] {
            print("Message ID: \(messageID)")
        }

        // Print full message.
        print(userInfo)

        completionHandler()
    }*/

    /// MARK: UNUserNotificationCenterDelegate

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                willPresent notification: UNNotification,
                                withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        // Play sound and show alert to the user
        completionHandler([.alert,.sound])
    }

    func userNotificationCenter(_ center: UNUserNotificationCenter,
                                didReceive response: UNNotificationResponse,
                                withCompletionHandler completionHandler: @escaping () -> Void) {

        let topicName = response.notification.request.content.userInfo["topicName"] as! String
        let subscription = coreDataManager?.getSubscription(topicName)
        if subscription == nil {
            completionHandler()
        }

        // Determine the user action
        switch response.actionIdentifier {
        case UNNotificationDismissActionIdentifier:
            DDLogInfo("Notification dismissed")
        case UNNotificationDefaultActionIdentifier:
            DDLogInfo("Default notifcation action")
        case Notifications.Id.unsubscribeActionId:
            _ = coreDataManager?.removeSubscription(topicName)
        case Notifications.Id.registerActionId:
            openUrl(subscription!.getUniversity().registrationPage)
        default:
            completionHandler()
        }
        Notifications.decrementBadge()
        completionHandler()
    }
}
// [END ios_10_message_handling]
