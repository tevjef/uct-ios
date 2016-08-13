//
//  AppDelegate.swift
//  Hello World
//
//  Created by Tevin Jeffrey on 12/23/15.
//  Copyright © 2015 Tevin Jeffrey. All rights reserved.
//

import UIKit
import CoreData
import Firebase
import FirebaseMessaging

@UIApplicationMain
class AppDelegate: UIResponder, UIApplicationDelegate {

    var window: UIWindow?

    var dataRepo: DataRepos?
    var appconstants = AppConstants()
    var coreDataManager: CoreDataManager?
    var firebaseManager: FirebaseManager?
    
    func application(application: UIApplication, didFinishLaunchingWithOptions launchOptions: [NSObject: AnyObject]?) -> Bool {
        dataRepo = DataRepos(constants: appconstants)
        Timber.plant(DebugTree())
        firebaseManager = FirebaseManager(appDelegate: self)
        coreDataManager = CoreDataManager(appDelegate: self, firebaseManager: firebaseManager!)
    
        window?.backgroundColor = UIColor.whiteColor()

        let settings: UIUserNotificationSettings = UIUserNotificationSettings(forTypes: [.Alert, .Badge, .Sound], categories: Notifications.makeCategories())
        application.registerUserNotificationSettings(settings)
        application.registerForRemoteNotifications()
        return true
    }
    
    func application(application: UIApplication, didRegisterForRemoteNotificationsWithDeviceToken deviceToken: NSData) {
        FirebaseManager.setAPNSToken(deviceToken)
    }
    
    func application(application: UIApplication, didReceiveRemoteNotification userInfo: [NSObject : AnyObject],
                     fetchCompletionHandler completionHandler: (UIBackgroundFetchResult) -> Void) {
        // If you are receiving a notification message while your app is in the background,
        // this callback will not be fired till the user taps on the notification launching the application.
        // TODO: Handle data of notification
        let json: [String: AnyObject]!
        let university: University!

        if let message = userInfo["message"] as? String {
            do {
                Timber.i(message)
                let jsonData = message.dataUsingEncoding(NSUTF8StringEncoding)!
                json = try NSJSONSerialization.JSONObjectWithData(jsonData, options: NSJSONReadingOptions()) as? [String: AnyObject]
                university = University.parseFromJson(json["university"] as! [String: AnyObject])
                let notification = Notifications(appDelegate: self, university: university)
                
                // Schedule notification
                notification.scheduleNotification()
            } catch {
                completionHandler(UIBackgroundFetchResult.Failed)
                print(error)
            }
        } else {
            guard let aps = userInfo["aps"],
                let alert = aps["alert"] else {
                    completionHandler(UIBackgroundFetchResult.Failed)
                    return
            }
            
            let alertController = Notifications.makeGenericAlert(nil, message: alert.description)
            self.window?.rootViewController?.presentViewController(alertController, animated: true, completion: nil)
            completionHandler(UIBackgroundFetchResult.NewData)
            return
        }
        
        // Reload all data
        coreDataManager?.refreshAllSubscriptions()
        
        Notifications.incrementBadge()
        completionHandler(UIBackgroundFetchResult.NewData)
    }
    
    func application(application: UIApplication, handleActionWithIdentifier identifier: String?, forLocalNotification notification: UILocalNotification, completionHandler: () -> Void) {
        Timber.d("handleActionWithIdentifier \(identifier)")
        let topicName = notification.userInfo!["topicName"] as! String
        let subscription = coreDataManager?.getSubscription(topicName)
        if subscription == nil {
            return
        }
        
        if notification.category == Notifications.Id.sectionNotificationCategoryId {
            switch identifier! {
            case Notifications.Id.registerActionId:
                AppDelegate.openUrl(subscription!.getUniversity().registrationPage)
                
            case Notifications.Id.unsubscribeActionId:
                Notifications.decrementBadge()
                coreDataManager?.removeSubscription(topicName)
            default:
                break
            }
        }
        // TODO log handling notification action
    }

    class func isUserPaid() -> Bool {
        return true
    }
    
    class func openUrl(url: String) {
        UIApplication.sharedApplication().openURL(NSURL(string:url)!)
    }
    
    func application(application: UIApplication, didRegisterUserNotificationSettings notificationSettings: UIUserNotificationSettings) {
        Timber.i("didRegisterUserNotificationSettings")

    }
    
    func application(application: UIApplication, didFailToRegisterForRemoteNotificationsWithError error: NSError) {
        Timber.i("didFailToRegisterForRemoteNotificationsWithError \(error))")
    }
    
    func applicationWillResignActive(application: UIApplication) {
        // Sent when the application is about to move from active to inactive state. This can occur for certain types of temporary interruptions (such as an incoming phone call or SMS message) or when the user quits the application and it begins the transition to the background state.
        // Use this method to pause ongoing tasks, disable timers, and throttle down OpenGL ES frame rates. Games should use this method to pause the game.
        Timber.i("applicationWillResignActive()")

    }

    func applicationDidEnterBackground(application: UIApplication) {
        // Use this method to release shared resources, save user data, invalidate timers, and store enough application state information to restore your application to its current state in case it is terminated later.
        // If your application supports background execution, this method is called instead of applicationWillTerminate: when the user quits.
        Timber.i("applicationDidEnterBackground()")
        FirebaseManager.disconnectFromFcm()
    }

    func applicationWillEnterForeground(application: UIApplication) {
        // Called as part of the transition from the background to the inactive state; here you can undo many of the changes made on entering the background.
        Timber.i("applicationWillEnterForeground()")
    }

    func applicationDidBecomeActive(application: UIApplication) {
        // Restart any tasks that were paused (or not yet started) while the application was inactive. If the application was previously in the background, optionally refresh the user interface.
        Timber.i("applicationDidBecomeActive()")

        FirebaseManager.connectToFcm()
        Notifications.resetBadge()
    }

    func applicationWillTerminate(application: UIApplication) {
        // Called when the application is about to terminate. Save data if appropriate. See also applicationDidEnterBackground:.
        // Saves changes in the application's managed object context before the application terminates.
        Timber.i("applicationWillTerminate()")

        self.saveContext()
    }

    // MARK: - Core Data stack

    lazy var applicationDocumentsDirectory: NSURL = {
        // The directory the application uses to store the Core Data store file. This code uses a directory named "com.tevinjeffrey.Hello_World" in the application's documents Application Support directory.
        let urls = NSFileManager.defaultManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask)
        return urls[urls.count-1]
    }()

    lazy var managedObjectModel: NSManagedObjectModel = {
        // The managed object model for the application. This property is not optional. It is a fatal error for the application not to be able to find and load its model.
        let modelURL = NSBundle.mainBundle().URLForResource(AppConstants.CoreData.objectModel, withExtension: "momd")!
        return NSManagedObjectModel(contentsOfURL: modelURL)!
    }()

    lazy var persistentStoreCoordinator: NSPersistentStoreCoordinator = {
        // The persistent store coordinator for the application. This implementation creates and returns a coordinator, having added the store for the application to it. This property is optional since there are legitimate error conditions that could cause the creation of the store to fail.
        // Create the coordinator and store
        let coordinator = NSPersistentStoreCoordinator(managedObjectModel: self.managedObjectModel)
        let url = self.applicationDocumentsDirectory.URLByAppendingPathComponent("SingleViewCoreData.sqlite")
        var failureReason = "There was an error creating or loading the application's saved data."
        do {
            try coordinator.addPersistentStoreWithType(NSSQLiteStoreType, configuration: nil, URL: url, options: nil)
        } catch {
            // Report any error we got.
            var dict = [String: AnyObject]()
            dict[NSLocalizedDescriptionKey] = "Failed to initialize the application's saved data"
            dict[NSLocalizedFailureReasonErrorKey] = failureReason

            dict[NSUnderlyingErrorKey] = error as NSError
            let wrappedError = NSError(domain: "YOUR_ERROR_DOMAIN", code: 9999, userInfo: dict)
            // Replace this with code to handle the error appropriately.
            // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
            Timber.e("Unresolved error \(wrappedError), \(wrappedError.userInfo)")
            abort()
        }
        
        return coordinator
    }()

    lazy var managedObjectContext: NSManagedObjectContext = {
        // Returns the managed object context for the application (which is already bound to the persistent store coordinator for the application.) This property is optional since there are legitimate error conditions that could cause the creation of the context to fail.
        let coordinator = self.persistentStoreCoordinator
        var managedObjectContext = NSManagedObjectContext(concurrencyType: .MainQueueConcurrencyType)
        managedObjectContext.persistentStoreCoordinator = coordinator
        return managedObjectContext
    }()

    // MARK: - Core Data Saving support

    func saveContext () {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch {
                // Replace this implementation with code to handle the error appropriately.
                // abort() causes the application to generate a crash log and terminate. You should not use this function in a shipping application, although it may be useful during development.
                let nserror = error as NSError
                Timber.e("Unresolved error \(nserror), \(nserror.userInfo)")
                abort()
            }
        }
    }

}

