//
//  FirebaseManager.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/12/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import Firebase
import FirebaseMessaging
import Crashlytics
import CocoaLumberjack

class FirebaseManager: NSObject {
    
    let appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        super.init()
        DDLogDebug("Configuring Firebase...")
        FirebaseApp.configure()
        Messaging.messaging().delegate = self

        NotificationCenter.default.addObserver(self, selector: #selector(FirebaseManager.sendDataMessageFailure), name:NSNotification.Name.MessagingSendError, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirebaseManager.sendDataMessageSuccess), name:NSNotification.Name.MessagingSendSuccess, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirebaseManager.didDeleteMessagesOnServer), name:NSNotification.Name.MessagingMessagesDeleted, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(FirebaseManager.tokenRefreshNotification), name: NSNotification.Name.InstanceIDTokenRefresh, object: nil)
        
        let token = InstanceID.instanceID().token()
        DDLogDebug("Token on startup= \(token ?? "")")
    }
    
    func subscribeToTopic(_ topicName: String) {
        Messaging.messaging().subscribe(toTopic: "/topics/\(topicName)")
        DDLogDebug("Subscribing to \(topicName)")
    }
    
    func unsubscribeFromTopic(_ topicName: String) {
        Messaging.messaging().unsubscribe(fromTopic: "/topics/\(topicName)")
        DDLogDebug("Unsubscribe from  \(topicName)")
    }
    
    class func setAPNSToken(_ deviceToken: Foundation.Data) {
        let tokenChars = (deviceToken as NSData).bytes.bindMemory(to: CChar.self, capacity: deviceToken.count)
        var tokenString = ""
        
        for i in 0..<deviceToken.count {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }

        Messaging.messaging().fcmToken
        //Tricky line
        DDLogDebug("Manually setting device token...")
        Messaging.messaging().setAPNSToken(deviceToken, type: MessagingAPNSTokenType.unknown)
        InstanceID.instanceID().setAPNSToken(deviceToken, type: InstanceIDAPNSTokenType.unknown)
        DDLogDebug("APNS Device Token: \(tokenString)")
    }
    
    class func connectToFcm() {
        DDLogDebug("Connecting to FCM...")
        Messaging.messaging().connect { (error) in
            if (error != nil) {
                DDLogWarn("Unable to connect with FCM. \(String(describing: error))")
            } else {
                DDLogDebug("Connected to FCM.")
            }
        }
    }
    
    class func disconnectFromFcm() {
        DDLogDebug("Disconnecting to FCM...")
        Messaging.messaging().disconnect()
    }
    
    func tokenRefreshNotification(_ notification: Notification) {
        let refreshedToken = InstanceID.instanceID().token()
        if refreshedToken != nil {
            Crashlytics.sharedInstance().setUserIdentifier(refreshedToken)
            DDLogDebug("tokenRefreshNotification InstanceID token: \(refreshedToken)")
        } else{
            DDLogError("tokenRefreshNotification InstanceID token: empty")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        FirebaseManager.connectToFcm()
    }
    
    func sendDataMessageFailure(_ notification: Notification) {
        DDLogDebug("sendDataMessageFailure= \(notification.description)")
    }
    
    func sendDataMessageSuccess(_ notification: Notification) {
        DDLogDebug("sendDataMessageSuccess= \(notification.description)")
    }
    
    func didDeleteMessagesOnServer(_ notification: Notification) {
        DDLogDebug("didDeleteMessagesOnServer= \(notification.description)")
    }
}

extension FirebaseManager : MessagingDelegate {
    func messaging(_ messaging: Messaging, didRefreshRegistrationToken fcmToken: String) {
        print("Firebase registration token: \(fcmToken)")

        // TODO: If necessary send token to application server.
        // Note: This callback is fired at each app startup and whenever a new token is generated.
    }
    // [END refresh_token]
    // [START ios_10_data_message]
    // Receive data messages on iOS 10+ directly from FCM (bypassing APNs) when the app is in the foreground.
    // To enable direct data messages, you can set Messaging.messaging().shouldEstablishDirectChannel to true.
    func messaging(_ messaging: Messaging, didReceive remoteMessage: MessagingRemoteMessage) {
        print("Received data message: \(remoteMessage.appData)")
    }
}
