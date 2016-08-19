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
        return String(self)
    }
    
    convenience init(context: NSManagedObjectContext) {
        let eName = self.dynamicType.entityName()
        let entity = NSEntityDescription.entityForName(eName, inManagedObjectContext: context)!
        self.init(entity: entity, insertIntoManagedObjectContext: context)
    }
}
