//
//  SearchFlow.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/31/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import CocoaLumberjack

protocol SearchFlowDelegate: class {
    var searchFlow: SearchFlow? { get set }
    func prepareSearchFlow(_ searchFlowDelegate: SearchFlowDelegate)
}

class SearchFlow: NSObject, NSCoding {
    // MARK: Properties
    // Minimum required to search
    var universityTopicName: String?
    var year: String?
    var season: String?
    var subjectTopicName: String?
    var courseTopicName: String?
    var sectionTopicName: String?
    
    var tempSemester: Semester?
    var tempUniversity: University?
    var tempSubject: Subject?
    var tempCourse: Course?
    var tempSection: Section?
    
    // MARK: Archiving Paths
    static let DocumentsDirectory = FileManager().urls(for: .documentDirectory, in: .userDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.appendingPathComponent("SearchFlow")
    
    // MARK: Types
    struct PropertyKey {
        static let universityTopicNameKey = "universityTopicNameKey"
        static let yearKey = "yearKey"
        static let seasonKey = "seasonKey"
        static let subjectTopicNameKey = "subjectTopicNameKey"
        static let courseTopicNameKey = "courseTopicNameKey"
        static let sectionTopicNameKey = "sectionTopicNameKey"
    }
    
    override init() {
        
    }
    
    // MARK: Initialization
    init?(universityTopicName: String, year: String, season: String, subjectTopicName: String, courseTopicName: String, sectionTopicName: String) {
        self.universityTopicName = universityTopicName
        self.year = year
        self.season = season
        self.subjectTopicName = subjectTopicName
        self.courseTopicName = courseTopicName
        self.sectionTopicName = sectionTopicName
    }
    
    // MARK: NSCoding
    func encode(with aCoder: NSCoder) {
        aCoder.encode(universityTopicName, forKey: PropertyKey.universityTopicNameKey)
        aCoder.encode(year, forKey: PropertyKey.yearKey)
        aCoder.encode(season, forKey: PropertyKey.seasonKey)
        aCoder.encode(subjectTopicName, forKey: PropertyKey.subjectTopicNameKey)
        aCoder.encode(courseTopicName, forKey: PropertyKey.courseTopicNameKey)
        aCoder.encode(sectionTopicName, forKey: PropertyKey.sectionTopicNameKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let universityTopicName = aDecoder.decodeObject(forKey: PropertyKey.universityTopicNameKey) as! String
        let year = aDecoder.decodeObject(forKey: PropertyKey.yearKey) as! String
        let season = aDecoder.decodeObject(forKey: PropertyKey.seasonKey) as! String
        let subjectTopicName = aDecoder.decodeObject(forKey: PropertyKey.subjectTopicNameKey) as! String
        let courseTopicName = aDecoder.decodeObject(forKey: PropertyKey.courseTopicNameKey) as! String
        let sectionTopicName = aDecoder.decodeObject(forKey: PropertyKey.sectionTopicNameKey) as! String
        self.init(universityTopicName: universityTopicName, year: year, season: season, subjectTopicName: subjectTopicName,
                  courseTopicName: courseTopicName, sectionTopicName: sectionTopicName)
    }
    
    static func saveSearchFlows(_ flows: [SearchFlow]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(flows, toFile: SearchFlow.ArchiveURL.path)
        if !isSuccessfulSave {
            print("Failed to save flows...")
        }
    }
    
    func loadSearchFlows() -> [SearchFlow]? {
        return NSKeyedUnarchiver.unarchiveObject(withFile: SearchFlow.ArchiveURL.path) as? [SearchFlow]
    }
    
    func buildSubscription() -> Subscription {
        let subscription = Subscription(topicName: sectionTopicName!)
        do {
            // Set section in course
            let courseBuilder = try Course.Builder().mergeFrom(other: tempCourse!)
            let sections = [tempSection!]
            courseBuilder.setSections(sections)
            let course = try courseBuilder.build()
            
            // Set course in subject
            let subjectBuilder = try Subject.Builder().mergeFrom(other: tempSubject!)
            let courses = [course]
            subjectBuilder.setCourses(courses)
            let subject = try subjectBuilder.build()
            
            // Set subject in university 
            let universityBuilder = try University.Builder().mergeFrom(other: tempUniversity!)
            let subjects = [subject]
            universityBuilder.setSubjects(subjects)
            universityBuilder.setAvailableSemesters([self.tempSemester!])
            let university = try universityBuilder.build()
            
            subscription.university = university
        } catch {
            DDLogError("Failed to build subscriptions \(error)")
        }
        
        return subscription
    }
    
    override var description : String {
        return "UniversityTopicName=\(universityTopicName)\n Season=\(season) \n Year=\(year) \n SubjectTopicName=\(subjectTopicName) \n CourseTopicName=\(courseTopicName) \n SectionTopicName=\(sectionTopicName)"
    }
}

class Subscription: NSObject {
    var sectionTopicName: String

    // Contains a nested tree
    // University
    // -Subject
    // --Course
    // ---Section
    var university: University?

    init(topicName: String) {
        self.sectionTopicName = topicName
    }
    
    convenience init(topicName: String, university: University) {
        self.init(topicName: topicName)
        self.university = university
    }
    
    func getUniversity() -> University {
        return university!
    }
    
    func getSubject() -> Subject {
        return university!.subjects.first!
    }
    
    func getCourse() -> Course {
        return getSubject().courses.first!
    }
    
    func getSection() -> Section {
        return getCourse().sections.first!
    }
    
    func getSearchFlow() -> SearchFlow {
        let searchFlow = SearchFlow()

        searchFlow.universityTopicName = self.getUniversity().topicName
        searchFlow.year = self.getSubject().year
        searchFlow.season = self.getSubject().season
        searchFlow.subjectTopicName = self.getSubject().topicName
        searchFlow.courseTopicName = self.getCourse().topicName
        searchFlow.sectionTopicName = self.getSection().topicName

        searchFlow.tempSemester = self.getUniversity().availableSemesters.first
        searchFlow.tempUniversity = self.getUniversity()
        searchFlow.tempSubject =  self.getSubject()
        searchFlow.tempCourse =  self.getCourse()
        searchFlow.tempSection = self.getSection()

        return searchFlow
    }
    
    func updateSection(_ section: Section) {
        var tempUni = university
        var tempSubject = tempUni!.subjects.first!
        var tempCourse = tempSubject.courses.first!
        do {
            tempCourse = try Course.getBuilder().mergeFrom(other: tempCourse).setSections([section]).build()
            tempSubject = try Subject.getBuilder().mergeFrom(other: tempSubject).setCourses([tempCourse]).build()
            tempUni = try University.getBuilder().mergeFrom(other: tempUni!).setSubjects([tempSubject]).build()
        } catch {
            DDLogError("Error when updating section in subscription \(error)")
        }
        
        university = tempUni!
    }
}

