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
        FIRApp.configure()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirebaseManager.sendDataMessageFailure), name:FIRMessagingSendErrorNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirebaseManager.sendDataMessageSuccess), name:FIRMessagingSendSuccessNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirebaseManager.didDeleteMessagesOnServer), name:FIRMessagingMessagesDeletedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirebaseManager.tokenRefreshNotification), name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        
        #if DEBUG
            //FIRAnalyticsConfiguration.sharedInstance().setIsEnabled(false)
        #endif
        
        let token = FIRInstanceID.instanceID().token()
        DDLogDebug("Token on startup= \(token ?? "")")
    }
    
    func subscribeToTopic(topicName: String) {
        FIRMessaging.messaging().subscribeToTopic("/topics/\(topicName)")
        DDLogDebug("Subscribing to \(topicName)")
    }
    
    func unsubscribeFromTopic(topicName: String) {
        FIRMessaging.messaging().unsubscribeFromTopic("/topics/\(topicName)")
        DDLogDebug("Unsubscribe from  \(topicName)")
    }
    
    class func setAPNSToken(deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        //Tricky line
        DDLogDebug("Manually setting device token...")
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Unknown)
        DDLogDebug("APNS Device Token: \(tokenString)")
    }
    
    class func connectToFcm() {
        DDLogDebug("Connecting to FCM...")
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                DDLogWarn("Unable to connect with FCM. \(error)")
            } else {
                DDLogDebug("Connected to FCM.")
            }
        }
    }
    
    class func disconnectFromFcm() {
        DDLogDebug("Disconnecting to FCM...")
        FIRMessaging.messaging().disconnect()
    }
    
    func tokenRefreshNotification(notification: NSNotification) {
        let refreshedToken = FIRInstanceID.instanceID().token()
        if refreshedToken != nil {
            Crashlytics.sharedInstance().setUserIdentifier(refreshedToken)
            DDLogDebug("tokenRefreshNotification InstanceID token: \(refreshedToken)")
        } else{
            DDLogError("tokenRefreshNotification InstanceID token: empty")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        FirebaseManager.connectToFcm()
    }
    
    func sendDataMessageFailure(notification: NSNotification) {
        DDLogDebug("sendDataMessageFailure= \(notification.description)")
    }
    
    func sendDataMessageSuccess(notification: NSNotification) {
        DDLogDebug("sendDataMessageSuccess= \(notification.description)")
    }
    
    func didDeleteMessagesOnServer(notification: NSNotification) {
        DDLogDebug("didDeleteMessagesOnServer= \(notification.description)")
    }
}