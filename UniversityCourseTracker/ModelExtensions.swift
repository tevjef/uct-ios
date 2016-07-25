//
//  ModelExtensions.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/24/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation

extension Common {
    static func getReadableString(semester: Common.Semester) -> String {
        return semester.season.capitalizedString + " " + String(semester.year)
    }
}