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

class Reporting: NSObject {

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

        Analytics.logEvent(Event.screen_view, parameters: params)
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
    
    func logChangeSemester(_ semester: String) {
        let params = [Params.semester: semester]
        Analytics.logEvent(Event.changeSemester, parameters: params)
        Answers.logCustomEvent(withName: Event.changeSemester, customAttributes: params)
        DDLogInfo("\(#function) \(params.description)")

    }
    
    
    func logChangeUniversity(_ topicId: String) {
        let params = [Params.topicId: topicId]
        Analytics.logEvent(Event.changeUniversity, parameters: params)
        Answers.logCustomEvent(withName: Event.changeUniversity, customAttributes: params)
        DDLogInfo("\(#function) \(params.description)")
    }
    
    func logDefaultUniversity(_ topicId: String) {
        DDLogInfo("\(#function) \(topicId)")
        Analytics.setUserProperty(topicId, forName: Event.defaultUni)
    }
    
    func logSubscription(_ sectionTopicId: String) {
        let params = [Params.topicId: sectionTopicId]
        Analytics.logEvent(Event.subscribe, parameters: params)
        Answers.logCustomEvent(withName: Event.subscribe, customAttributes: params)
        DDLogInfo("\(#function) \(params.description)")

    }
    
    func logUnsubscription(_ sectionTopicId: String) {
        let params = [Params.topicId: sectionTopicId]
        Analytics.logEvent(Event.unsubscribe, parameters: params)
        Answers.logCustomEvent(withName: Event.unsubscribe, customAttributes: params)
        DDLogInfo("\(#function) \(params.description)")

    }
    
    func logReceiveNotification(_ sectionTopicId: String) {
        let params = [Params.topicId: sectionTopicId]
        Analytics.logEvent(Event.receiveNotification, parameters: params)
        Answers.logCustomEvent(withName: Event.receiveNotification, customAttributes: params)
        DDLogInfo("\(#function) \(params.description)")

    }
    
    func logRegister(_ sectionTopicId: String) {
        let params = [Params.topicId: sectionTopicId]
        Analytics.logEvent(Event.register, parameters: params)
        Answers.logCustomEvent(withName: Event.register, customAttributes: params)
        DDLogInfo("\(#function) \(params.description)")

    }
    
    func logFilterAllSections(_ topicId: String, count: Int) {
        let params = [Params.topicId: topicId, Params.count: count] as [String : Any]
        Analytics.logEvent(Event.filterAllSections, parameters: (params as! [String : NSObject]))
        Answers.logCustomEvent(withName: Event.filterAllSections, customAttributes: (params as! [String : AnyObject]))
        DDLogInfo("\(#function) \(params.description)")

    }
    
    func logFilterOpenSections(_ topicId: String, count: Int) {
        let params = [Params.topicId: topicId, Params.count: count] as [String : Any]
        Analytics.logEvent(Event.filterOpenSections, parameters: (params as! [String : NSObject]))
        Answers.logCustomEvent(withName: Event.filterOpenSections, customAttributes: (params as! [String : AnyObject]))
        DDLogInfo("\(#function) \(params.description)")

    }
    
    struct Screen {
        static var trackedSections = "tracked_sections"
        static var subjects = "subjects"
        static var singleCourse = "single_course"
        static var course = "course"
        static var section = "section"
        static var options = "search_options"
        static var startupDefaults = "startup_defaults"
    }
    
    struct Params {
        static var screen_name = "screen_name"
        static var name = "name"
        static var number = "number"
        static var topicId = "topic_id"
        static var topicName = "topic_name"
        static var count = "count"
        static var semester = "semester"
    }
    
    struct Event {
        static var defaultUni = "default_uni"
        static var screen_view = "screen_view"
        static var changeSemester = "change_semester"
        static var changeUniversity = "change_university"
        static var subscribe = "subscribe"
        static var unsubscribe = "unsubscribe"
        static var register = "register"
        static var receiveNotification = "receive_notification"
        static var filterOpenSections = "filter_open_sections"
        static var filterAllSections = "filter_all_sections"
        static var popHome = "pop_home"
    }
}
