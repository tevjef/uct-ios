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

class FirebaseManager: NSObject {
    
    let appDelegate: AppDelegate
    
    init(appDelegate: AppDelegate) {
        self.appDelegate = appDelegate
        super.init()
        Timber.d("Configuring Firebase...")
        FIRApp.configure()

        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirebaseManager.sendDataMessageFailure), name:FIRMessagingSendErrorNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirebaseManager.sendDataMessageSuccess), name:FIRMessagingSendSuccessNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirebaseManager.didDeleteMessagesOnServer), name:FIRMessagingMessagesDeletedNotification, object: nil)
        NSNotificationCenter.defaultCenter().addObserver(self, selector: #selector(FirebaseManager.tokenRefreshNotification), name: kFIRInstanceIDTokenRefreshNotification, object: nil)
        
        let token = FIRInstanceID.instanceID().token()
        Timber.d("Token on startup= \(token ?? "")")
    }
    
    func subscribeToTopic(topicName: String) {
        FIRMessaging.messaging().subscribeToTopic(topicName)
        Timber.d("Subscribing to \(topicName)")
    }
    
    func unsubscribeFromTopic(topicName: String) {
        FIRMessaging.messaging().unsubscribeFromTopic(topicName)
        Timber.d("Unsubscribe from  \(topicName)")
    }
    
    class func setAPNSToken(deviceToken: NSData) {
        let tokenChars = UnsafePointer<CChar>(deviceToken.bytes)
        var tokenString = ""
        
        for i in 0..<deviceToken.length {
            tokenString += String(format: "%02.2hhx", arguments: [tokenChars[i]])
        }
        
        //Tricky line
        Timber.d("Manually setting device token...")
        FIRInstanceID.instanceID().setAPNSToken(deviceToken, type: FIRInstanceIDAPNSTokenType.Unknown)
        Timber.d("APNS Device Token: \(tokenString)")
    }
    
    class func connectToFcm() {
        Timber.d("Connecting to FCM...")
        FIRMessaging.messaging().connectWithCompletion { (error) in
            if (error != nil) {
                Timber.w("Unable to connect with FCM. \(error)")
            } else {
                Timber.d("Connected to FCM.")
            }
        }
    }
    
    class func disconnectFromFcm() {
        Timber.d("Disconnecting to FCM...")
        FIRMessaging.messaging().disconnect()
    }
    
    func tokenRefreshNotification(notification: NSNotification) {
        let refreshedToken = FIRInstanceID.instanceID().token()
        if refreshedToken != nil {
            Timber.d("tokenRefreshNotification InstanceID token: \(refreshedToken)")
        } else{
            Timber.e("tokenRefreshNotification InstanceID token: empty")
        }
        
        // Connect to FCM since connection may have failed when attempted before having a token.
        FirebaseManager.connectToFcm()
    }
    
    func sendDataMessageFailure(notification: NSNotification) {
        Timber.d("sendDataMessageFailure= \(notification.description)")
    }
    
    func sendDataMessageSuccess(notification: NSNotification) {
        Timber.d("sendDataMessageSuccess= \(notification.description)")
    }
    
    func didDeleteMessagesOnServer(notification: NSNotification) {
        Timber.d("didDeleteMessagesOnServer= \(notification.description)")
    }
}