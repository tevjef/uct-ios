//
//  Reporting.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/13/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import Firebase
import Crashlytics
import CocoaLumberjack

class Reporting {

    func logShowScreen(_ view: UIViewController) {
        var params: [String: NSObject] = [:]
        
        if view is CoursesViewController {
            let vc = view as! CoursesViewController
            params = [Params.topicId: vc.searchFlow!.tempSubject!.topicId as NSObject]
        } else if view is SingleCourseViewController {
            let vc = view as! SingleCourseViewController
            params = [Params.topicId: vc.searchFlow!.tempCourse!.topicId as NSObject]
        } else if view is SubjectsViewController {
            let vc = view as! SubjectsViewController
            params = [Params.semester: vc.searchFlow!.tempSemester!.readableString as NSObject, Params.topicId: vc.searchFlow!.tempUniversity!.topicId as NSObject]
        } else if view is SectionViewController {
            let vc = view as! SectionViewController
            params = [Params.semester: vc.searchFlow!.tempSemester!.readableString as NSObject, Params.topicId: vc.searchFlow!.tempSection!.topicId as NSObject]
        }
        
        params[Params.screen_name] = view.nameOfClass as NSObject?

        Analytics.setScreenName(view.nameOfClass, screenClass: view.nameOfClass)
        Answers.logCustomEvent(withName: Event.screen_view, customAttributes: params)
        Crashlytics.sharedInstance().setObjectValue(Event.screen_view, forKey: params.description)
        DDLogInfo("\(#function) \(params.description)")
    }
    
    func logPopHome(_ from: UIViewController) {
        let params = [Params.screen_name: from.nameOfClass]
        Analytics.logEvent(Event.popHome, parameters: params)
        Answers.logCustomEvent(withName: Event.popHome, customAttributes: params)
        DDLogInfo("\(#function) \(params.description)")
    }

    func logDefaultUniversity(_ topicName: String) {
        DDLogInfo("\(#function) \(topicName)")
        Analytics.setUserProperty(topicName, forName: Event.defaultUniversity)
    }

    func logDefaultSemester(_ semester: Semester) {
        DDLogInfo("\(#function) \(semester.readableString)")
        Analytics.setUserProperty(semester.readableString, forName: Event.defaultSemester)
    }

    func logTrackedSections(_ count: Int) {
        let params = [Params.section_count: count]
        DDLogInfo("\(#function) \(params.description)")

        Analytics.logEvent(Event.trackedSections, parameters: params)
        Answers.logCustomEvent(withName: Event.trackedSections, customAttributes: params)
    }
    
    func logSubscription(_ topicId: String, _ topicName: String) {
        let params = [Params.topicId: topicId, Params.topicName: topicName]
        DDLogInfo("\(#function) \(params.description)")

        Analytics.logEvent(Event.subscribe, parameters: params)
        Answers.logCustomEvent(withName: Event.subscribe, customAttributes: params)
    }
    
    func logUnsubscription(_ topicId: String, _ topicName: String) {
        let params = [Params.topicId: topicId, Params.topicName: topicName]
        DDLogInfo("\(#function) \(params.description)")

        Analytics.logEvent(Event.unsubscribe, parameters: params)
        Answers.logCustomEvent(withName: Event.unsubscribe, customAttributes: params)
    }
    
    func logReceiveNotification(_ sectionTopicId: String, _ sectionTopicName: String, _ notificationId: String) {
        let params = [Params.topicId: sectionTopicId, Params.topicName: sectionTopicName, Params.notificationId: notificationId]
        DDLogInfo("\(#function) \(params.description)")

        Analytics.logEvent(Event.receiveNotification, parameters: params)
        Answers.logCustomEvent(withName: Event.receiveNotification, customAttributes: params)
    }
    
    func logRegister(_ sectionTopicId: String) {
        let params = [Params.topicId: sectionTopicId]
        DDLogInfo("\(#function) \(params.description)")

        Analytics.logEvent(Event.register, parameters: params)
        Answers.logCustomEvent(withName: Event.register, customAttributes: params)
    }

    struct Params {
        static var screen_name = "screen_name"
        static var name = "name"
        static var number = "number"
        static var topicId = "topic_id"
        static var topicName = "topic_name"
        static var notificationId = "notification_id"
        static var section_count = "section_count"
        static var semester = "semester"
    }
    
    struct Event {
        static var defaultUniversity = "default_university"
        static var defaultSemester = "default_semester"
        static var screen_view = "screen_view"
        static var trackedSections = "tracked_sections"
        static var subscribe = "subscribe"
        static var unsubscribe = "unsubscribe"
        static var register = "register"
        static var receiveNotification = "receive_notification"
        static var popHome = "pop_home"
    }
}
