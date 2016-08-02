//
//  DataRepos.swift
//  Hello World
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import Alamofire

class DataRepos {
    
    var constants: AppConstants
    
    init(constants: AppConstants) {
        self.constants = constants
    }
    
    func processRequest(request: Request, completion: (Common.Response?) -> Void) {
        request.responseData { response in
            if response.result.isSuccess {
                do {
                    let resp = try Common.Response.parseFromData(response.data!)
                    completion(resp)
                } catch {
                    completion(nil)
                }
            } else {
                completion(nil)
            }
        }
    }
    
    func getUniversities(universities: (Array<Common.University>?) -> Void) {
        let url = constants.UNIVERSITIES
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            universities(response?.data.universities)
        })
    }
    
    func getUniversity(universityTopic: String, _ university: (Common.University?) -> Void) {
        let url = "\(constants.UNIVERSITY)\(universityTopic)"
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            university(response?.data.university)
        })
    }
    
    func getSubjects(universityTopic: String, _ season: String, _ year: String,
                     _ subjects: (Array<Common.Subject>?) -> Void) {
        let url = "\(constants.SUBJECTS)\(universityTopic)/\(season)/\(year)"
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            subjects(response?.data.subjects)
        })
    }
    
    func getSubject(subjectTopic: String, _ subject: (Common.Subject?) -> Void) {
        let url = "\(constants.SUBJECT)\(subjectTopic)"
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            subject(response?.data.subject)
        })
    }
    
    func getCourses(subjectTopic: String, _ courses: (Array<Common.Course>?) -> Void) {
        let url = "\(constants.COURSES)\(subjectTopic)"
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            courses(response?.data.courses)
        })
    }
    
    func getCourse(courseTopic: String, _ course: (Common.Course?) -> Void) {
        let url = "\(constants.COURSE)\(courseTopic)"
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            course(response?.data.course)
        })
    }
    
    func getSection(sectionTopic: String, _ section: (Common.Section?) -> Void) {
        let url = "\(constants.SECTION)\(sectionTopic)"
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            section(response?.data.section)
        })
        
    }
}


