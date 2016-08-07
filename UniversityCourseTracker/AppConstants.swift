//
//  AppConstants.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/30/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import UIKit

class AppConstants {
    var UNIVERSITIES = "\(Network.base)/\(Network.apiVersion)/\(Network.universities)/"
    var UNIVERSITY = "\(Network.base)/\(Network.apiVersion)/\(Network.university)/"
    var SUBJECTS = "\(Network.base)/\(Network.apiVersion)/\(Network.subjects)/"
    var SUBJECT = "\(Network.base)/\(Network.apiVersion)/\(Network.subject)/"
    var COURSES = "\(Network.base)/\(Network.apiVersion)/\(Network.courses)/"
    var COURSE = "\(Network.base)/\(Network.apiVersion)/\(Network.course)/"
    var SECTION = "\(Network.base)/\(Network.apiVersion)/\(Network.section)/"
    
    struct Network {
        static var apiVersion = "v2"
        static var base = "https://uct.tevindev.me"
        static var universities = "universities"
        static var university = "university"
        static var subjects = "subjects"
        static var subject = "subject"
        static var courses = "courses"
        static var course = "course"
        static var section = "section"
    }
    
    struct CoreData {
        static var objectModel = "UniversityCourseTracker"
        static var userDefaults = "CoreUserDefault"
        static var subscriptions = "CoreSubscription"
    }
    
    struct Id {
        struct Controllers {
            static var trackedSections = "trackedSectionsVC"
            static var section = "sectionVC"
        }
        
        struct Segue {
            static var trackedSections = "gotoTrackedSections"
            static var subjects = "gotoSubjects"
            static var courses = "gotoCourses"
            static var sections = "gotoSections"
            static var section = "gotoSection"
            static var options = "gotoOptions"
        }
    }

    struct Colors {
        static var primary: UIColor = UIColor(hexString: "607D8B")
        
        static var closedSection: UIColor = UIColor(hexString: "F44336")
        static var openSection: UIColor = UIColor(hexString: "4CAF50")
    }
    
    struct PropertyKey {
        static let universityTopicNameKey = "universityTopicNameKey"
        static let yearKey = "yearKey"
        static let seasonKey = "seasonKey"
    }
}