//
//  SharingListNote+CoreDataProperties.swift
//  Reminder
//
//  Created by Yijia Huang on 10/15/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//
//

import Foundation
import CoreData


// MARK: - extension
extension SharingListNote {

    /// fetch request
    ///
    /// - Returns: fetch request
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SharingListNote> {
        return NSFetchRequest<SharingListNote>(entityName: "SharingListNote")
    }

    // MARK: - Variables
    @NSManaged public var alarm: NSDate?
    @NSManaged public var created: NSDate?
    @NSManaged public var done: Bool
    @NSManaged public var due: NSDate?
    @NSManaged public var lastupdated: NSDate?
    @NSManaged public var text: String?
    @NSManaged public var title: String?
    @NSManaged public var owner: SharingListNoteList?

}
