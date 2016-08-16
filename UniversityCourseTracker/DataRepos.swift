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
    
    func processRequest(request: Request, completion: (Response?) -> Void) {
        Timber.d("Request \(request.debugDescription)")
        request.responseData { response in
            if response.result.isSuccess {
                do {
                    let resp = try Response.parseFromData(response.data!)
                    completion(resp)
                } catch {
                    completion(nil)
                    Timber.e("Error while parsing response \(request.debugDescription) error=\(error)")

                }
            } else {
                completion(nil)
                Timber.e("Error while trying to complete request \(request.debugDescription) result=\(response.result.error)")
            }
        }
    }
    
    func getUniversities(universities: (Array<University>?) -> Void) {
        let url = constants.UNIVERSITIES
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            universities(response?.data.universities)
        })
    }
    
    func getUniversity(universityTopic: String, _ university: (University?) -> Void) {
        let url = "\(constants.UNIVERSITY)/\(universityTopic)"
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            university(response?.data.university)
        })
    }
    
    func getSubjects(universityTopic: String, _ season: String, _ year: String,
                     _ subjects: (Array<Subject>?) -> Void) {
        let url = "\(constants.SUBJECTS)/\(universityTopic)/\(season)/\(year)"
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            subjects(response?.data.subjects)
        })
    }
    
    func getSubject(subjectTopic: String, _ subject: (Subject?) -> Void) {
        let url = "\(constants.SUBJECT)/\(subjectTopic)"
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            subject(response?.data.subject)
        })
    }
    
    func getCourses(subjectTopic: String, _ courses: (Array<Course>?) -> Void) {
        let url = "\(constants.COURSES)/\(subjectTopic)"
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            courses(response?.data.courses)
        })
    }
    
    func getCourse(courseTopic: String, _ course: (Course?) -> Void) {
        let url = "\(constants.COURSE)/\(courseTopic)"
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            course(response?.data.course)
        })
    }
    
    func getSection(sectionTopic: String, _ section: (Section?) -> Void) {
        let url = "\(constants.SECTION)/\(sectionTopic)"
        let request = Alamofire.request(.GET, url)
        processRequest(request, completion: {
            response in
            section(response?.data.section)
        })
        
    }
}


