//
//  CoreUserDefault.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/6/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import CoreData


class CoreUserDefault: NSManagedObject {

    class func getUniversity(ctx: NSManagedObjectContext) -> Common.University? {
        let data = getPeristedUniversity(ctx)
        
        if data == nil {
            return nil
        }
        return data!.getUniversity()
    }
    
    class func getSemester(ctx: NSManagedObjectContext) -> Common.Semester? {
        let data = getPeristedUniversity(ctx)
        if data == nil {
            return nil
        }
        return data!.getSemester()
    }
    
    class func saveUniversity(ctx: NSManagedObjectContext, data: Common.University) {
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
    class func saveSemester(ctx: NSManagedObjectContext, data: Common.Semester) {
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
    
    private func getUniversity() -> Common.University? {
        do {
            if university != nil {
                let uni = try Common.University.parseFromData(university!)
                return uni
            }
        } catch {
            Timber.e("Failed to parse university \(error)")
        }
        return nil
    }
    
    private func getSemester() -> Common.Semester? {
        do {
            if semester != nil {
                let sem = try Common.Semester.parseFromData(semester!)
                return sem
            }
        } catch {
            Timber.e("Failed to parse semester \(error)")
        }
        
        return nil
    }
    
    private func insert(university: Common.University) {
        let data = university.data()
        self.university = data
        do {
            try managedObjectContext?.save()
            Timber.d("Insert successful university=\(university.topicName)")
        } catch {
            Timber.e("Failed to insert university \(error)")
        }
    }
    
    private func update(university: Common.University) {
        let data = university.data()
        self.university = data
        do {
            try managedObjectContext?.save()
            Timber.d("Update successful university=\(university.topicName)")
        } catch {
            Timber.e("Failed to update university \(error)")
        }
    }
    
    private func insert(semester: Common.Semester) {
        let data = semester.data()
        self.semester = data
        do {
            try managedObjectContext?.save()
            Timber.d("Insert successful semester=\(semester.description)")
        } catch {
            Timber.e("Failed to insert semester \(error)")
        }
    }
    
    private func update(semester: Common.Semester) {
        let data = semester.data()
        self.semester = data
        do {
            try managedObjectContext?.save()
            Timber.d("Update successful semester=\(semester.description)")
        } catch {
            Timber.e("Failed to update semester \(error)")
        }
    }
    
    private class func getPeristedUniversity(ctx: NSManagedObjectContext) -> CoreUserDefault? {
        
        do {
            let fetchRequest = CoreUserDefault.requestUserDefault()
            let fetchedCoreUserDefaults = try ctx.executeFetchRequest(fetchRequest) as! [CoreUserDefault]
            
            if fetchedCoreUserDefaults.count == 0 {
                Timber.d("No university found")
                return nil
            } else if fetchedCoreUserDefaults.count > 1 {
                Timber.e("Multiple user universities!")
            } else {
                return fetchedCoreUserDefaults.first
            }
        } catch {
            Timber.e("Failed to fetch user univerisity: \(error)")
        }
        
        return nil
    }
}
