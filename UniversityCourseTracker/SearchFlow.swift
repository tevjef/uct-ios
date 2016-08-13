//
//  SearchFlow.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 7/31/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation

protocol SearchFlowDelegate: class {
    var searchFlow: SearchFlow? { get set }
    func prepareSearchFlow(searchFlowDelegate: SearchFlowDelegate)
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
    static let DocumentsDirectory = NSFileManager().URLsForDirectory(.DocumentDirectory, inDomains: .UserDomainMask).first!
    static let ArchiveURL = DocumentsDirectory.URLByAppendingPathComponent("SearchFlow")
    
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
    func encodeWithCoder(aCoder: NSCoder) {
        aCoder.encodeObject(universityTopicName, forKey: PropertyKey.universityTopicNameKey)
        aCoder.encodeObject(year, forKey: PropertyKey.yearKey)
        aCoder.encodeObject(season, forKey: PropertyKey.seasonKey)
        aCoder.encodeObject(subjectTopicName, forKey: PropertyKey.subjectTopicNameKey)
        aCoder.encodeObject(courseTopicName, forKey: PropertyKey.courseTopicNameKey)
        aCoder.encodeObject(sectionTopicName, forKey: PropertyKey.sectionTopicNameKey)
    }
    
    required convenience init?(coder aDecoder: NSCoder) {
        let universityTopicName = aDecoder.decodeObjectForKey(PropertyKey.universityTopicNameKey) as! String
        let year = aDecoder.decodeObjectForKey(PropertyKey.yearKey) as! String
        let season = aDecoder.decodeObjectForKey(PropertyKey.seasonKey) as! String
        let subjectTopicName = aDecoder.decodeObjectForKey(PropertyKey.subjectTopicNameKey) as! String
        let courseTopicName = aDecoder.decodeObjectForKey(PropertyKey.courseTopicNameKey) as! String
        let sectionTopicName = aDecoder.decodeObjectForKey(PropertyKey.sectionTopicNameKey) as! String
        self.init(universityTopicName: universityTopicName, year: year, season: season, subjectTopicName: subjectTopicName,
                  courseTopicName: courseTopicName, sectionTopicName: sectionTopicName)
    }
    
    static func saveSearchFlows(flows: [SearchFlow]) {
        let isSuccessfulSave = NSKeyedArchiver.archiveRootObject(flows, toFile: SearchFlow.ArchiveURL.path!)
        if !isSuccessfulSave {
            print("Failed to save flows...")
        }
    }
    
    func loadSearchFlows() -> [SearchFlow]? {
        return NSKeyedUnarchiver.unarchiveObjectWithFile(SearchFlow.ArchiveURL.path!) as? [SearchFlow]
    }
    
    func buildSubscription() -> Subscription {
        let subscription = Subscription(topicName: sectionTopicName!)
        do {
            // Set section in course
            let courseBuilder = try Course.Builder().mergeFrom(tempCourse!)
            let sections = [tempSection!]
            courseBuilder.setSections(sections)
            let course = try courseBuilder.build()
            
            // Set course in subject
            let subjectBuilder = try Subject.Builder().mergeFrom(tempSubject!)
            let courses = [course]
            subjectBuilder.setCourses(courses)
            let subject = try subjectBuilder.build()
            
            // Set subject in university 
            let universityBuilder = try University.Builder().mergeFrom(tempUniversity!)
            let subjects = [subject]
            universityBuilder.setSubjects(subjects)
            universityBuilder.setAvailableSemesters([self.tempSemester!])
            let university = try universityBuilder.build()
            
            subscription.university = university
        } catch {
            Timber.e("Failed to build subscriptions \(error)")
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
    
    func updateSection(section: Section) {
        var tempUni = university
        var tempSubject = tempUni!.subjects.first!
        var tempCourse = tempSubject.courses.first!
        do {
            tempCourse = try Course.getBuilder().mergeFrom(tempCourse).setSections([section]).build()
            tempSubject = try Subject.getBuilder().mergeFrom(tempSubject).setCourses([tempCourse]).build()
            tempUni = try University.getBuilder().mergeFrom(tempUni!).setSubjects([tempSubject]).build()
        } catch {
            Timber.e("Error when updating section in subscription \(error)")
        }
        
        university = tempUni!
    }
}

