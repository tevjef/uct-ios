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

    class func getUniversity(_ ctx: NSManagedObjectContext) -> University? {
        let data = getPeristedUniversity(ctx)
        
        if data == nil {
            return nil
        }
        return data!.getUniversity()
    }
    
    class func getSemester(_ ctx: NSManagedObjectContext) -> Semester? {
        let data = getPeristedUniversity(ctx)
        if data == nil {
            return nil
        }
        return data!.getSemester()
    }
    
    class func saveUniversity(_ ctx: NSManagedObjectContext, data: University) {
        // Find exisiting CoreUserDefault
        let persistedUniversity = getPeristedUniversity(ctx)
        
        // Update
        if persistedUniversity != nil {
            persistedUniversity!.update(data)
            // Or Insert
        } else {
            let blob = CoreUserDefault(context: ctx, dummy: "")
            blob.insert(data)
        }
    }
    
    // Could possibly be batched with university
    class func saveSemester(_ ctx: NSManagedObjectContext, data: Semester) {
        // Find exisiting CoreUserDefault
        let persistedSemester = getPeristedUniversity(ctx)
        
        // Update
        if persistedSemester != nil {
            persistedSemester!.update(data)
        } else {
            // Insert
            let blob = CoreUserDefault(context: ctx, dummy: "")
            blob.insert(data)
        }
        
    }

    override class func entityName() -> String {
        return AppConstants.CoreData.userDefaults
    }
    
    fileprivate class func requestUserDefault() -> NSFetchRequest<NSFetchRequestResult> {
        return NSFetchRequest(entityName: CoreUserDefault.entityName())
    }
    
    fileprivate func getUniversity() -> University? {
        do {
            if self.university != nil {
                let uni = try University.parseFrom(data: self.university! as Data)
                return uni
            }
        } catch {
            DDLogError("Failed to parse university \(error)")
        }
        return nil
    }
    
    fileprivate func getSemester() -> Semester? {
        do {
            if semester != nil {
                let sem = try Semester.parseFrom(data: self.semester! as Data)
                return sem
            }
        } catch {
            DDLogError("Failed to parse semester \(error)")
        }
        
        return nil
    }
    
    func insert(_ university: University) {
        let data = university.data()
        self.university = data as NSData
        do {
            try managedObjectContext?.save()
            DDLogDebug("Insert successful university=\(university.topicName)")
        } catch {
            DDLogError("Failed to insert university \(error)")
        }
    }
    
    fileprivate func update(_ university: University) {
        let data = university.data()
        self.university = data as NSData
        do {
            try managedObjectContext?.save()
            DDLogDebug("Update successful university=\(university.topicName)")
        } catch {
            DDLogError("Failed to update university \(error)")
        }
    }
    
    fileprivate func insert(_ semester: Semester) {
        let data = semester.data()
        self.semester = data as NSData
        do {
            try managedObjectContext?.save()
            DDLogDebug("Insert successful semester=\(semester.description)")
        } catch {
            DDLogError("Failed to insert semester \(error)")
        }
    }
    
    fileprivate func update(_ semester: Semester) {
        let data = semester.data()
        self.semester = data as NSData
        do {
            try managedObjectContext?.save()
            DDLogDebug("Update successful semester=\(semester.description)")
        } catch {
            DDLogError("Failed to update semester \(error)")
        }
    }
    
    fileprivate class func getPeristedUniversity(_ ctx: NSManagedObjectContext) -> CoreUserDefault? {
        
        do {
            let fetchRequest = CoreUserDefault.requestUserDefault()
            let fetchedCoreUserDefaults = try ctx.fetch(fetchRequest) as! [CoreUserDefault]
            
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
