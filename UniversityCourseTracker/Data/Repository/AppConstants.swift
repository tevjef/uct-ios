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

    init() {
        // Set defaults

        let betaUniversities = NSUserDefaults.standardUserDefaults().boolForKey("beta_universities")
        
        // Enable beta endpoint
        if betaUniversities {
            Network.base = "https://api.staging.coursetrakr.io"
        } else {
            Network.base = "https://api.coursetrakr.io"
        }
    }
    
    lazy var UNIVERSITIES = "\(Network.base)/\(Network.apiVersion)/\(Network.universities)"
    lazy var UNIVERSITY = "\(Network.base)/\(Network.apiVersion)/\(Network.university)"
    lazy var SUBJECTS = "\(Network.base)/\(Network.apiVersion)/\(Network.subjects)"
    lazy var SUBJECT = "\(Network.base)/\(Network.apiVersion)/\(Network.subject)"
    lazy var COURSES = "\(Network.base)/\(Network.apiVersion)/\(Network.courses)"
    lazy var COURSE = "\(Network.base)/\(Network.apiVersion)/\(Network.course)"
    lazy var SECTION = "\(Network.base)/\(Network.apiVersion)/\(Network.section)"
    
    struct Notification {
        static var genericNotificationTitle = "Course Tracker"
    }
    
    struct Network {
        static var apiVersion = "v2"
        static var base = "https://api.coursetrakr.io"
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
            static var singleCourse = "singleCourseVC"
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
    
    struct Size {
        static func getFontSize(style: FontStyle) -> CGFloat {
            switch style {
            case .Headline:
                return 13
            case .Body:
                return 12
            case .Caption:
                return 11
            }
            
        }
    }
    
    struct UCTColors {
        static var primary = "607D8B"
        static var primaryDark = "455A64"
        static var primaryLight = "ECEFF1"
        
        static var darkText = "000000"
        static var lightText = "ECEFF1"
        
        static var closedSection = "F44336"
        static var openSection = "4CAF50"
    }
    
    struct Colors {
        static var primary: UIColor = UIColor(hexString: UCTColors.primary)
        static var primaryDark: UIColor = UIColor(hexString: UCTColors.primaryDark)
        static var primaryLight: UIColor = UIColor(hexString: UCTColors.primaryLight)
        
        static var primaryDarkText: UIColor = UIColor(hexString: UCTColors.darkText, alpha: 0.77)
        static var secondaryDarkText: UIColor = UIColor(hexString: UCTColors.darkText, alpha: 0.67)
        static var disabledDarkText: UIColor = UIColor(hexString: UCTColors.darkText, alpha: 0.38)

        static var primaryLightText: UIColor = UIColor(hexString: UCTColors.lightText, alpha: 0.87)
        static var secondaryLightText: UIColor = UIColor(hexString: UCTColors.lightText, alpha: 0.54)
        static var disabledLightText: UIColor = UIColor(hexString: UCTColors.lightText, alpha: 0.38)
        
        
        static var closedSection: UIColor = UIColor(hexString: UCTColors.closedSection)
        static var openSection: UIColor = UIColor(hexString: UCTColors.openSection)
        
        static func configureLabel(label: UILabel, style: FontStyle) {
            switch style {
            case .Headline:
                label.textColor = primaryDarkText
            case .Body:
                label.textColor = secondaryDarkText
            case .Caption:
                label.textColor = secondaryDarkText
            }
        }
    }
    
    enum FontStyle {
        case Headline
        case Body
        case Caption
    }
    
    struct PropertyKey {
        static let universityTopicNameKey = "universityTopicNameKey"
        static let yearKey = "yearKey"
        static let seasonKey = "seasonKey"
    }
}