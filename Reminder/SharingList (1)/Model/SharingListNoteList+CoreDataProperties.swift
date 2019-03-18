//
//  SharingListNoteList+CoreDataProperties.swift
//  Reminder
//
//  Created by Yijia Huang on 10/15/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//
//

import Foundation
import CoreData


// MARK: - extension
extension SharingListNoteList {

    /// fetch request
    ///
    /// - Returns: fetch request
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SharingListNoteList> {
        return NSFetchRequest<SharingListNoteList>(entityName: "SharingListNoteList")
    }

    // MARK: - Variables
    @NSManaged public var created: NSDate?
    @NSManaged public var fbID: String?
    @NSManaged public var lastupdated: NSDate?
    @NSManaged public var name: String?
    @NSManaged public var notes: NSSet?
    @NSManaged public var owner: SharingListUser?

}

// MARK: Generated accessors for notes
extension SharingListNoteList {

    // MARK: - Variables
    @objc(addNotesObject:)
    @NSManaged public func addToNotes(_ value: SharingListNote)

    @objc(removeNotesObject:)
    @NSManaged public func removeFromNotes(_ value: SharingListNote)

    @objc(addNotes:)
    @NSManaged public func addToNotes(_ values: NSSet)

    @objc(removeNotes:)
    @NSManaged public func removeFromNotes(_ values: NSSet)

}
