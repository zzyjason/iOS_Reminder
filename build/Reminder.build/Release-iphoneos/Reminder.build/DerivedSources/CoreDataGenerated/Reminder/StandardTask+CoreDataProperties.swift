//
//  StandardTask+CoreDataProperties.swift
//  
//
//  Created by Jason on 2017/12/8.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension StandardTask {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<StandardTask> {
        return NSFetchRequest<StandardTask>(entityName: "StandardTask")
    }

    @NSManaged public var checkMark: Bool
    @NSManaged public var dueDate: Date?
    @NSManaged public var frequence: String?
    @NSManaged public var id: Int64
    @NSManaged public var reminderTime: Date?
    @NSManaged public var taskName: String?
    @NSManaged public var username: String?

}
