//
//  CoreDataExtensions.swift
//  UniversityCourseTracker
//
//  Created by Tevin Jeffrey on 8/6/16.
//  Copyright © 2016 Tevin Jeffrey. All rights reserved.
//

import Foundation
import CoreData

extension NSManagedObject {
    
    // Returns the unqualified class name, i.e. the last component.
    // Can be overridden in a subclass.
    class func entityName() -> String {
        return String(describing: self)
    }
    
    
    convenience init(context: NSManagedObjectContext, dummy: String = "") {
        let eName = type(of: self).entityName()
        let entity = NSEntityDescription.entity(forEntityName: eName, in: context)!
        self.init(entity: entity, insertInto: context)
    }
}
