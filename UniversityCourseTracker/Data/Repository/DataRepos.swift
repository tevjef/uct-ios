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
    var session: SessionManager
    
    init(constants: AppConstants) {
        self.constants = constants
        let appVersionString: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let displayName: String = Bundle.main.object(forInfoDictionaryKey: "CFBundleName") as! String

        var defaultHeaders = Alamofire.SessionManager.defaultHTTPHeaders
        
        // Add version number to User-Agent
        defaultHeaders["User-Agent"] = "\(defaultHeaders["User-Agent"]!) \(displayName)/\(appVersionString)"
        let configuration = URLSessionConfiguration.default
        configuration.httpAdditionalHeaders = defaultHeaders
        session = Alamofire.SessionManager(configuration: configuration)
        
    }
    
    let headers = [
        "Accept": "application/x-protobuf",
    ]
    
    func processRequest(_ request: DataRequest, completion: @escaping (Response?) -> Void) {
        DDLogDebug("Request \(request.debugDescription)")
        request.responseData { response in
            if response.result.isSuccess {
                do {
                    let resp = try Response.parseFrom(data: response.data!)
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
                DDLogError("Error while trying to complete request \(request.debugDescription) result=\(response.result.error?.localizedDescription)")
            }
        }
    }
    
    func getUniversities(_ universities: @escaping (Array<University>?) -> Void) {
        let url = constants.UNIVERSITIES
        let request = session.request(url, method: .get, headers: headers)
        processRequest(request, completion: {
            response in
            universities(response?.data.universities)
        })
    }
    
    func getUniversity(_ universityTopic: String, _ university: @escaping (University?) -> Void) {
        let url = "\(constants.UNIVERSITY)/\(universityTopic)"
        let request = session.request(url, method: .get, headers: headers)
        processRequest(request, completion: {
            response in
            university(response?.data.university)
        })
    }
    
    func getSubjects(_ universityTopic: String, _ season: String, _ year: String,
                     _ subjects: @escaping (Array<Subject>?) -> Void) {
        let url = "\(constants.SUBJECTS)/\(universityTopic)/\(season)/\(year)"
        let request = session.request(url, method: .get, headers: headers)
        processRequest(request, completion: {
            response in
            subjects(response?.data.subjects)
        })
    }
    
    func getSubject(_ subjectTopic: String, _ subject: @escaping (Subject?) -> Void) {
        let url = "\(constants.SUBJECT)/\(subjectTopic)"
        let request = session.request(url, method: .get, headers: headers)
        processRequest(request, completion: {
            response in
            subject(response?.data.subject)
        })
    }
    
    func getCourses(_ subjectTopic: String, _ courses: @escaping (Array<Course>?) -> Void) {
        let url = "\(constants.COURSES)/\(subjectTopic)"
        let request = session.request(url, method: .get, headers: headers)
        processRequest(request, completion: {
            response in
            courses(response?.data.courses)
        })
    }
    
    func getCourse(_ courseTopic: String, _ course: @escaping (Course?) -> Void) {
        let url = "\(constants.COURSE)/\(courseTopic)"
        let request = session.request(url, method: .get, headers: headers)
        processRequest(request, completion: {
            response in
            course(response?.data.course)
        })
    }
    
    func getSection(_ sectionTopic: String, _ section: @escaping (Section?) -> Void) {
        let url = "\(constants.SECTION)/\(sectionTopic)"
        let request = session.request(url, method: .get, headers: headers)
        processRequest(request, completion: {
            response in
            section(response?.data.section)
        })
        
    }
}


