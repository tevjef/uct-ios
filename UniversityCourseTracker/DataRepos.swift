//
//  DataRepos.swift
//  Hello World
//
//  Created by Tevin Jeffrey on 7/23/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import Alamofire

let BASE_URL = "https://uct.tevindev.me/v2/"
let UNIVERSITIES = BASE_URL + "universities"
let UNIVERISITY = BASE_URL + "university/"
let SUBJECTS = BASE_URL + "subjects/"
let SUBJECT = BASE_URL + "subject/"
let COURSES = BASE_URL + "courses/"
let COURSE = BASE_URL + "course/"
let SECTION = BASE_URL + "section/"

func getUniversities(universities: (Array<Common.University>?) -> Void) {
    let url = UNIVERSITIES
    let request = Alamofire.request(.GET, url)
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            universities(resp.data.universities)
        } catch {
            universities(nil)
        }
        
    }
}

func getUniversity(universityTopic: String, _ university: (Common.University?) -> Void) {
    let url = "\(UNIVERISITY)\(universityTopic)"
    let request = Alamofire.request(.GET, url)
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            university(resp.data.university)
        } catch {
            university(nil)
        }
    }
}

func getSubjects(universityTopic: String, _ season: String, _ year: String,
                 _ subjects: (Array<Common.Subject>?) -> Void) {
    let url = "\(SUBJECTS)\(universityTopic)/\(season)/\(year)"
    let request = Alamofire.request(.GET, url)
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            subjects(resp.data.subjects)
        } catch {
            subjects(nil)
        }
    }
}

func getSubject(subjectTopic: String, _ subject: (Common.Subject?) -> Void) {
    let url = "\(SUBJECT)\(subjectTopic)"
    let request = Alamofire.request(.GET, url)
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            subject(resp.data.subject)
        } catch {
            subject(nil)
        }
    }
}

func getCourses(subjectTopic: String, _ courses: (Array<Common.Course>?) -> Void) {
    let url = "\(COURSES)\(subjectTopic)"
    let request = Alamofire.request(.GET, url)
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            courses(resp.data.courses)
        } catch {
            courses(nil)
        }
    }
}

func getCourse(courseTopic: String, _ course: (Common.Course?) -> Void) {
    let url = "\(COURSE)\(courseTopic)"
    let request = Alamofire.request(.GET, url)
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            course(resp.data.course)
        } catch {
            course(nil)
        }
    }
}

func getSection(sectionTopic: String, _ section: (Common.Section?) -> Void) {
    let url = "\(SECTION)\(sectionTopic)"
    let request = Alamofire.request(.GET, url)
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            section(resp.data.section)
        } catch {
            section(nil)
        }
    }
}