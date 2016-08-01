//
//  AppConstants.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/30/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation

class AppConstants {
    var BASE_URL: String {
        get {
         return "https://uct.tevindev.me/v2/"
        }
    }
    var UNIVERSITIES: String {
        get {
            return self.BASE_URL + "universities"
        }
    }
    var UNIVERSITY: String {
        get {
            return self.BASE_URL + "university/"
        }
    }
    var SUBJECTS: String {
        get {
            return self.BASE_URL + "subjects/"
        }
    }
    var SUBJECT: String {
        get {
            return self.BASE_URL + "subject/"
        }
    }
    var COURSES: String {
        get {
            return self.BASE_URL + "courses/"
        }
    }
    var COURSE: String {
        get {
            return self.BASE_URL + "course/"
        }
    }
    var SECTION: String {
        get {
            return self.BASE_URL + "section/"
        }
    }
    
    var primaryColor: String {
        get {
            return "607D8B"
        }
    }
    
    struct PropertyKey {
        static let universityTopicNameKey = "universityTopicNameKey"
        static let yearKey = "yearKey"
        static let seasonKey = "seasonKey"
    }
}