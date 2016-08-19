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

class Reporting: NSObject {

    func logShowScreen(view: UIViewController) {
        var params: [String: NSObject] = [:]
        
        if view is CoursesViewController {
            let vc = view as! CoursesViewController
            params = [Params.topicId: vc.searchFlow!.tempSubject!.topicId]
        } else if view is SingleCourseViewController {
            let vc = view as! SingleCourseViewController
            params = [Params.topicId: vc.searchFlow!.tempCourse!.topicId]
        } else if view is SubjectsViewController {
            let vc = view as! SubjectsViewController
            params = [Params.semester: vc.searchFlow!.tempSemester!.readableString, Params.topicId: vc.searchFlow!.tempUniversity!.topicId]
        } else if view is SectionViewController {
            let vc = view as! SectionViewController
            params = [Params.semester: vc.searchFlow!.tempSemester!.readableString, Params.topicId: vc.searchFlow!.tempSection!.topicId]
        }
        
        params[Params.screen_name] = view.nameOfClass

        FIRAnalytics.logEventWithName(Event.screen_view, parameters: params)
        Answers.logCustomEventWithName(Event.screen_view, customAttributes: params)
        Crashlytics.sharedInstance().setObjectValue(Event.screen_view, forKey: params.description)
        Timber.i("\(#function) \(params.description)")
    }
    
    func logPopHome(from: UIViewController) {
        let params = [Params.screen_name: from.nameOfClass]
        FIRAnalytics.logEventWithName(Event.popHome, parameters: params)
        Answers.logCustomEventWithName(Event.popHome, customAttributes: params)
        Timber.i("\(#function) \(params.description)")

    }
    
    func logChangeSemester(semester: String) {
        let params = [Params.semester: semester]
        FIRAnalytics.logEventWithName(Event.changeSemester, parameters: params)
        Answers.logCustomEventWithName(Event.changeSemester, customAttributes: params)
        Timber.i("\(#function) \(params.description)")

    }
    
    
    func logChangeUniversity(topicId: String) {
        let params = [Params.topicId: topicId]
        FIRAnalytics.logEventWithName(Event.changeUniversity, parameters: params)
        Answers.logCustomEventWithName(Event.changeUniversity, customAttributes: params)
        Timber.i("\(#function) \(params.description)")
    }
    
    func logDefaultUniversity(topicId: String) {
        Timber.i("\(#function) \(topicId)")
        FIRAnalytics.setUserPropertyString(topicId, forName: Event.defaultUni)
    }
    
    func logSubscription(sectionTopicId: String) {
        let params = [Params.topicId: sectionTopicId]
        FIRAnalytics.logEventWithName(Event.subscribe, parameters: params)
        Answers.logCustomEventWithName(Event.subscribe, customAttributes: params)
        Timber.i("\(#function) \(params.description)")

    }
    
    func logUnsubscription(sectionTopicId: String) {
        let params = [Params.topicId: sectionTopicId]
        FIRAnalytics.logEventWithName(Event.unsubscribe, parameters: params)
        Answers.logCustomEventWithName(Event.unsubscribe, customAttributes: params)
        Timber.i("\(#function) \(params.description)")

    }
    
    func logReceiveNotification(sectionTopicId: String) {
        let params = [Params.topicId: sectionTopicId]
        FIRAnalytics.logEventWithName(Event.receiveNotification, parameters: params)
        Answers.logCustomEventWithName(Event.receiveNotification, customAttributes: params)
        Timber.i("\(#function) \(params.description)")

    }
    
    func logRegister(sectionTopicId: String) {
        let params = [Params.topicId: sectionTopicId]
        FIRAnalytics.logEventWithName(Event.register, parameters: params)
        Answers.logCustomEventWithName(Event.register, customAttributes: params)
        Timber.i("\(#function) \(params.description)")

    }
    
    func logFilterAllSections(topicId: String, count: Int) {
        let params = [Params.topicId: topicId, Params.count: count]
        FIRAnalytics.logEventWithName(Event.filterAllSections, parameters: (params as! [String : NSObject]))
        Answers.logCustomEventWithName(Event.filterAllSections, customAttributes: (params as! [String : AnyObject]))
        Timber.i("\(#function) \(params.description)")

    }
    
    func logFilterOpenSections(topicId: String, count: Int) {
        let params = [Params.topicId: topicId, Params.count: count]
        FIRAnalytics.logEventWithName(Event.filterOpenSections, parameters: (params as! [String : NSObject]))
        Answers.logCustomEventWithName(Event.filterOpenSections, customAttributes: (params as! [String : AnyObject]))
        Timber.i("\(#function) \(params.description)")

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