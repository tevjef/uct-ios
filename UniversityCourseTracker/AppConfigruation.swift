//
//  AppConfigruation.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/31/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation

class AppConfigruation: NSObject {
    var university: Common.University?
    let dataRepo: DataRepos
    let userDefaults: UserDefaults
    
    init(dataRepo: DataRepos, defaults: UserDefaults)  {
        self.dataRepo = dataRepo
        self.userDefaults = defaults

        super.init()
        userDefaults.defaults.addObserver(self, forKeyPath: AppConstants.PropertyKey.universityTopicNameKey, options: NSKeyValueObservingOptions.New, context: nil)
        loadUniversity(userDefaults.universityTopicName)
    }
    
    override func observeValueForKeyPath(keyPath: String?, ofObject object: AnyObject?, change: [String : AnyObject]?, context: UnsafeMutablePointer<Void>) {
        if keyPath == AppConstants.PropertyKey.universityTopicNameKey {
            loadUniversity((change?["new"])! as! String)
        }
    }
    
    func loadUniversity(topicName: String) {
        if topicName == "" {
            return
        }
        
        dataRepo.getUniversity(topicName) { (university) in
            if let university = university {
                self.university = university
            } else {
                NSLog("Error getting configruations for university " + topicName)
            }
        }
    }
    
    deinit {
        userDefaults.defaults.removeObserver(self, forKeyPath: AppConstants.PropertyKey.universityTopicNameKey)
    }
}