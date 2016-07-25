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
let UNIVERISITY = BASE_URL + "university/%s"
let SUBJECTS = BASE_URL + "subject/%s"
let SUBJECT = BASE_URL + "subjects/%s/%s/%s"
let COURSES = BASE_URL + "courses/%s"
let COURSE = BASE_URL + "course/%s"
let SECTION = BASE_URL + "section/%s"

func getUniversities(universities: (Array<Common.University>?) -> Void) {
    let request = Alamofire.request(.GET, UNIVERSITIES)
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            universities(resp.data.universities)
        } catch {
            universities(nil)
        }
        
    }
}

func getUniversity(universityTopic: String, university: (Common.University?) -> Void) {
    let request = Alamofire.request(.GET, String(format: UNIVERISITY, universityTopic))
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            university(resp.data.university)
        } catch {
            university(nil)
        }
    }
}

func getSubjects(universityTopic: String, season: String, year: String,
                 subjects: (Array<Common.Subject>?) -> Void) {
    let request = Alamofire.request(.GET, String(format: SUBJECTS, universityTopic, season, year))
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            subjects(resp.data.subjects)
        } catch {
            subjects(nil)
        }
    }
}

func getSubject(subjectTopic: String, subject: (Common.Subject?) -> Void) {
    let request = Alamofire.request(.GET, String(format: SUBJECT, subjectTopic))
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            subject(resp.data.subject)
        } catch {
            subject(nil)
        }
    }
}

func getCourses(subjecTopic: String, courses: (Array<Common.Course>?) -> Void) {
    let request = Alamofire.request(.GET, String(format: COURSES, subjecTopic))
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            courses(resp.data.courses)
        } catch {
            courses(nil)
        }
    }
}

func getCourse(courseTopic: String, course: (Common.Course?) -> Void) {
    let request = Alamofire.request(.GET, String(format: COURSE, courseTopic))
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            course(resp.data.course)
        } catch {
            course(nil)
        }
    }
}

func getSection(sectionTopic: String, section: (Common.Section?) -> Void) {
    let request = Alamofire.request(.GET, String(format: SECTION, sectionTopic))
    request.responseJSON { response in
        do {
            let resp = try Common.Response.parseFromData(response.data!)
            section(resp.data.section)
        } catch {
            section(nil)
        }
    }
}