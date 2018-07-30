//
//  Notes+CoreDataProperties.swift
//  Notes
//
//  Created by Samiul Hoque Limo on 7/29/18.
//  Copyright © 2018 Samiul Hoque Limo. All rights reserved.
//
//

import Foundation
import CoreData


extension Notes {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Notes> {
        return NSFetchRequest<Notes>(entityName: Notes.entityName)
    }
    
    @nonobjc public class func fetch() -> NSFetchRequest<Notes> {
        let request = NSFetchRequest<Notes>(entityName: Notes.entityName)
        
        request.sortDescriptors = [NSSortDescriptor(key: "modified", ascending: false)]
        
        return request
    }

    @NSManaged public var id: Int16
    @NSManaged public var title: String?
    @NSManaged public var details: String?
    @NSManaged public var modified: String?

}
