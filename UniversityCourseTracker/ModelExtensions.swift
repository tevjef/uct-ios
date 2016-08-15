//
//  ModelExtensions.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation

class Common {}
typealias Payload = [String: AnyObject]

extension University {
    class func parseFromJson(json: [String: AnyObject]) -> University? {
        let university = University.Builder()

        guard
            let abbr = json["abbr"] as? String,
            let name = json["name"] as? String,
            let topicId = json["topic_id"] as? String,
            let topicName = json["topic_name"] as? String,
            let homePage = json["home_page"] as? String,
            let registrationPage = json["registration_page"] as? String,
            let subjects = json["subjects"] as? [Payload] else {
                return nil
        }

        var parsedSubjects: [Subject] = []
        for s in subjects {
            let subject = Subject.parseFromJson(s)
            if subject != nil {
                parsedSubjects.append(subject!)
            }
        }
        
        university
        .setAbbr(abbr)
        .setName(name)
        .setTopicId(topicId)
        .setTopicName(topicName)
        .setHomePage(homePage)
        .setRegistrationPage(registrationPage)
        .setSubjects(parsedSubjects)

        do {
            return try university.build()
        } catch {
            Timber.e("Error creating university \(error)")
        }
        
        return nil
    }
}

extension Subject {
    class func parseFromJson(json: [String: AnyObject]) -> Subject? {
        let subject = Subject.Builder()

        guard
        let number = json["number"] as? String,
        let name = json["name"] as? String,
        let season = json["season"] as? String,
        let year = json["year"] as? String,
        let topicId = json["topic_id"] as? String,
        let topicName = json["topic_name"] as? String,
        let courses = json["courses"] as? [Payload] else {
            return nil
        }

        var parsedCourses: [Course] = []
        for c in courses {
            let course = Course.parseFromJson(c)
            if course != nil {
                parsedCourses.append(course!)
            }
        }
        
        subject
        .setName(name)
        .setNumber(number)
        .setSeason(season)
        .setYear(year)
        .setTopicId(topicId)
        .setTopicName(topicName)
        .setCourses(parsedCourses)

        do {
            return try subject.build()
        } catch {
            Timber.e("Error creating subject \(error)")
        }
        
        return nil
    }
}

extension Course {
    class func parseFromJson(json: [String: AnyObject]) -> Course? {
        let course = Course.Builder()

        guard
        let number = json["number"] as? String,
        let name = json["name"] as? String,
        let topicId = json["topic_id"] as? String,
        let topicName = json["topic_name"] as? String,
        let sections = json["sections"] as? [Payload] else {
            return nil
        }

        var parsedSections: [Section] = []
        for s in sections {
            let section = Section.parseFromJson(s)
            if section != nil {
                parsedSections.append(section!)
            }
        }
        
        course
        .setName(name)
        .setNumber(number)
        .setTopicId(topicId)
        .setTopicName(topicName)
        .setSections(parsedSections)

        do {
            return try course.build()
        } catch {
            Timber.e("Error creating course \(error)")
        }
        return nil
    }

}

extension Section {
    class func parseFromJson(json: [String: AnyObject]) -> Section? {
        let section = Section.Builder()

        guard
        let max = json["max"] as? Int,
        let now = json["now"] as? Int,
        let number = json["number"] as? String,
        let callNumber = json["call_number"] as? String,
        let status = json["status"] as? String,
        let credits = json["credits"] as? String,
        let topicId = json["topic_id"] as? String,
        let topicName = json["topic_name"] as? String else {
            return nil
        }

        section
        .setNumber(number)
        .setCallNumber(callNumber)
        .setMax(Int64(max))
        .setNow(Int64(now))
        .setCredits(credits)
        .setStatus(status)
        .setTopicId(topicId)
        .setTopicName(topicName)

        do {
            return try section.build()
        } catch {
            Timber.e("Error creating section \(error)")
        }
        
        return nil
    }

}

extension Semester {
    var readableString: String { return self.season.capitalizedString + " " + String(self.year) }
}

extension Course {
    var openSections: Int {
        var count: Int = 0
        for section in self.sections {
            if section.status == "Open" {
                count = count + 1
            }
        }
        return count
    }
}

extension CollectionType where Generator.Element == Instructor {
    var listString: String {
        var str: String = ""
        
        for instructor in self {
            str += instructor.name
            if instructor != self.reverse().first {
                str += " | "
            }
        }
        return str
    }
}

class Utils {
    static func semesterFromString(str: String) -> Semester? {
        let components = str.componentsSeparatedByString(" ")
        let season = components.first!
        let year = Int32(components.last!)
        
        do {
            let semester = try Semester.Builder().setSeason(season).setYear(year!).build()
            return semester
        } catch {
            Timber.e("Failed to parse semester")
        }
        return nil
    }
}