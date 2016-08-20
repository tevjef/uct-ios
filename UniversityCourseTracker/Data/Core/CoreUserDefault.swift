//
//  CoreUserDefault.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/6/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import CoreData
import CocoaLumberjack


class CoreUserDefault: NSManagedObject {

    class func getUniversity(ctx: NSManagedObjectContext) -> University? {
        let data = getPeristedUniversity(ctx)
        
        if data == nil {
            return nil
        }
        return data!.getUniversity()
    }
    
    class func getSemester(ctx: NSManagedObjectContext) -> Semester? {
        let data = getPeristedUniversity(ctx)
        if data == nil {
            return nil
        }
        return data!.getSemester()
    }
    
    class func saveUniversity(ctx: NSManagedObjectContext, data: University) {
        // Find exisiting CoreUserDefault
        let persistedUniversity = getPeristedUniversity(ctx)
        
        // Update
        if persistedUniversity != nil {
            persistedUniversity!.update(data)
            // Or Insert
        } else {
            let blob = CoreUserDefault(context: ctx)
            blob.insert(data)
        }
    }
    
    // Could possibly be batched with university
    class func saveSemester(ctx: NSManagedObjectContext, data: Semester) {
        // Find exisiting CoreUserDefault
        let persistedSemester = getPeristedUniversity(ctx)
        
        // Update
        if persistedSemester != nil {
            persistedSemester!.update(data)
        } else {
            // Insert
            let blob = CoreUserDefault(context: ctx)
            blob.insert(data)
        }
        
    }

    override class func entityName() -> String {
        return AppConstants.CoreData.userDefaults
    }
    
    private class func requestUserDefault() -> NSFetchRequest {
        let fetchRequest = NSFetchRequest(entityName: CoreUserDefault.entityName())
        return fetchRequest
    }
    
    private func getUniversity() -> University? {
        do {
            if university != nil {
                let uni = try University.parseFromData(university!)
                return uni
            }
        } catch {
            DDLogError("Failed to parse university \(error)")
        }
        return nil
    }
    
    private func getSemester() -> Semester? {
        do {
            if semester != nil {
                let sem = try Semester.parseFromData(semester!)
                return sem
            }
        } catch {
            DDLogError("Failed to parse semester \(error)")
        }
        
        return nil
    }
    
    private func insert(university: University) {
        let data = university.data()
        self.university = data
        do {
            try managedObjectContext?.save()
            DDLogDebug("Insert successful university=\(university.topicName)")
        } catch {
            DDLogError("Failed to insert university \(error)")
        }
    }
    
    private func update(university: University) {
        let data = university.data()
        self.university = data
        do {
            try managedObjectContext?.save()
            DDLogDebug("Update successful university=\(university.topicName)")
        } catch {
            DDLogError("Failed to update university \(error)")
        }
    }
    
    private func insert(semester: Semester) {
        let data = semester.data()
        self.semester = data
        do {
            try managedObjectContext?.save()
            DDLogDebug("Insert successful semester=\(semester.description)")
        } catch {
            DDLogError("Failed to insert semester \(error)")
        }
    }
    
    private func update(semester: Semester) {
        let data = semester.data()
        self.semester = data
        do {
            try managedObjectContext?.save()
            DDLogDebug("Update successful semester=\(semester.description)")
        } catch {
            DDLogError("Failed to update semester \(error)")
        }
    }
    
    private class func getPeristedUniversity(ctx: NSManagedObjectContext) -> CoreUserDefault? {
        
        do {
            let fetchRequest = CoreUserDefault.requestUserDefault()
            let fetchedCoreUserDefaults = try ctx.executeFetchRequest(fetchRequest) as! [CoreUserDefault]
            
            if fetchedCoreUserDefaults.count == 0 {
                DDLogDebug("No university found")
                return nil
            } else if fetchedCoreUserDefaults.count > 1 {
                DDLogError("Multiple user universities!")
            } else {
                return fetchedCoreUserDefaults.first
            }
        } catch {
            DDLogError("Failed to fetch user univerisity: \(error)")
        }
        
        return nil
    }
}
