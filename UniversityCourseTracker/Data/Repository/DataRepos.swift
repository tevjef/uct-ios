//
//  DataRepos.swift
//  Hello World
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import Alamofire
import CocoaLumberjack

class DataRepos {
    
    var constants: AppConstants
    var session: Manager
    
    init(constants: AppConstants) {
        self.constants = constants
        let appVersionString: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let displayName: String = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleName") as! String

        var defaultHeaders = Alamofire.Manager.defaultHTTPHeaders
        
        // Add version number to User-Agent
        defaultHeaders["User-Agent"] = "\(defaultHeaders["User-Agent"]!) \(displayName)/\(appVersionString)"
        let configuration = NSURLSessionConfiguration.defaultSessionConfiguration()
        configuration.HTTPAdditionalHeaders = defaultHeaders
        session = Alamofire.Manager(configuration: configuration)
        
    }
    
    let headers = [
        "Accept": "application/x-protobuf",
    ]
    
    func processRequest(request: Request, completion: (Response?) -> Void) {
        DDLogDebug("Request \(request.debugDescription)")
        request.responseData { response in
            if response.result.isSuccess {
                do {
                    let resp = try Response.parseFromData(response.data!)
                    // Usually a 404
                    if resp.hasData {
                        completion(resp)
                    } else {
                        completion(nil)
                    }
                } catch {
                    completion(nil)
                    DDLogError("Error while parsing response \(request.debugDescription) error=\(error)")

                }
            } else {
                completion(nil)
                DDLogError("Error while trying to complete request \(request.debugDescription) result=\(response.result.error)")
            }
        }
    }
    
    func getUniversities(universities: (Array<University>?) -> Void) {
        let url = constants.UNIVERSITIES
        let request = session.request(.GET, url, headers: headers)
        processRequest(request, completion: {
            response in
            universities(response?.data.universities)
        })
    }
    
    func getUniversity(universityTopic: String, _ university: (University?) -> Void) {
        let url = "\(constants.UNIVERSITY)/\(universityTopic)"
        let request = session.request(.GET, url, headers: headers)
        processRequest(request, completion: {
            response in
            university(response?.data.university)
        })
    }
    
    func getSubjects(universityTopic: String, _ season: String, _ year: String,
                     _ subjects: (Array<Subject>?) -> Void) {
        let url = "\(constants.SUBJECTS)/\(universityTopic)/\(season)/\(year)"
        let request = session.request(.GET, url, headers: headers)
        processRequest(request, completion: {
            response in
            subjects(response?.data.subjects)
        })
    }
    
    func getSubject(subjectTopic: String, _ subject: (Subject?) -> Void) {
        let url = "\(constants.SUBJECT)/\(subjectTopic)"
        let request = session.request(.GET, url, headers: headers)
        processRequest(request, completion: {
            response in
            subject(response?.data.subject)
        })
    }
    
    func getCourses(subjectTopic: String, _ courses: (Array<Course>?) -> Void) {
        let url = "\(constants.COURSES)/\(subjectTopic)"
        let request = session.request(.GET, url, headers: headers)
        processRequest(request, completion: {
            response in
            courses(response?.data.courses)
        })
    }
    
    func getCourse(courseTopic: String, _ course: (Course?) -> Void) {
        let url = "\(constants.COURSE)/\(courseTopic)"
        let request = session.request(.GET, url, headers: headers)
        processRequest(request, completion: {
            response in
            course(response?.data.course)
        })
    }
    
    func getSection(sectionTopic: String, _ section: (Section?) -> Void) {
        let url = "\(constants.SECTION)/\(sectionTopic)"
        let request = session.request(.GET, url, headers: headers)
        processRequest(request, completion: {
            response in
            section(response?.data.section)
        })
        
    }
}


