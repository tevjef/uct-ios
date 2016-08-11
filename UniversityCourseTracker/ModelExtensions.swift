//
//  ModelExtensions.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation

class Common {}

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
            if instructor != self[self.endIndex] {
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