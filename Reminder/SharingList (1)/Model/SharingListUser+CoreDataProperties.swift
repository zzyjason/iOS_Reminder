//
//  SharingListUser+CoreDataProperties.swift
//  Reminder
//
//  Created by Yijia Huang on 10/15/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//
//

import Foundation
import CoreData


// MARK: - extension
extension SharingListUser {

    /// fetch request
    ///
    /// - Returns: fetch request
    @nonobjc public class func fetchRequest() -> NSFetchRequest<SharingListUser> {
        return NSFetchRequest<SharingListUser>(entityName: "SharingListUser")
    }

    // MARK: - Variables
    @NSManaged public var lastselectedlist: String?
    @NSManaged public var name: String?
    @NSManaged public var numofnotes: Int16
    @NSManaged public var lists: NSSet?

}

// MARK: Generated accessors for list
extension SharingListUser {
    // MARK: - Variables
    @objc(addListsObject:)
    @NSManaged public func addToLists(_ value: SharingListNoteList)

    @objc(removeListsObject:)
    @NSManaged public func removeFromLists(_ value: SharingListNoteList)

    @objc(addLists:)
    @NSManaged public func addToLists(_ values: NSSet)

    @objc(removeLists:)
    @NSManaged public func removeFromLists(_ values: NSSet)

}
