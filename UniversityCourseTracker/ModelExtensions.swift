//
//  ModelExtensions.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation

extension Common {
    
    static func getReadableInstructor(instructors: Array<Common.Instructor>) -> String {
        var str: String = ""
        for instructor in instructors {
            str += instructor.name
            if instructor != instructors.last {
                str += " | "
            }
        }
        return str
    }
    
    static func getReadableSemester(semester: Common.Semester) -> String {
        return semester.season.capitalizedString + " " + String(semester.year)
    }
    
    static func semesterFromString(str: String) -> Common.Semester? {
        let components = str.componentsSeparatedByString(" ")
        let season = components.first!
        let year = Int32(components.last!)
        
        do {
            let semester = try Common.Semester.Builder().setSeason(season).setYear(year!).build()
            return semester
        } catch {
            Timber.e("Failed to parse semester")
        }
        return nil
    }
    
    static func getOpenSections(course: Common.Course) -> Int {
        var count: Int = 0
        for section in course.sections {
            if section.status == "Open" {
                count = count + 1
            }
        }
        return count
    }
}