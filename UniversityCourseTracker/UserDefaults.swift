//
//  UserDefaults.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/31/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation

class UserDefaults: NSObject {
    // MARK: Properties
    var universityTopicName: String {
        get {
            if let topic = defaults.stringForKey(AppConstants.PropertyKey.universityTopicNameKey) as String! {
                return topic
            } else {
                return ""
            }
        }
        
        set(topicName) {
            defaults.setObject(topicName, forKey: AppConstants.PropertyKey.universityTopicNameKey)
        }
    }
    
    var season: String {
        get {
            if let season = defaults.stringForKey(AppConstants.PropertyKey.seasonKey) as String! {
                return season
            } else {
                return ""
            }
        }
        
        set(season) {
            defaults.setObject(season, forKey: AppConstants.PropertyKey.seasonKey)
        }
    }

    var year: String {
        get {
            if let year = defaults.stringForKey(AppConstants.PropertyKey.yearKey) as String! {
                return year
            } else {
                return ""
            }
        }
        
        set(year) {
            defaults.setObject(year, forKey: AppConstants.PropertyKey.yearKey)
        }
    }

    var defaults: NSUserDefaults

    init(defaults: NSUserDefaults) {
        self.defaults = defaults
        //defaults.removePersistentDomainForName(NSBundle.mainBundle().bundleIdentifier!)
    }
    
    func commit() -> Bool {
        return defaults.synchronize()
    }
}
