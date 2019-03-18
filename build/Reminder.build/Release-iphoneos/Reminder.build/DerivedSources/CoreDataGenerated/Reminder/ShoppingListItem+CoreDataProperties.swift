//
//  ShoppingListItem+CoreDataProperties.swift
//  
//
//  Created by Jason on 2017/12/8.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension ShoppingListItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ShoppingListItem> {
        return NSFetchRequest<ShoppingListItem>(entityName: "ShoppingListItem")
    }

    @NSManaged public var amount: Double
    @NSManaged public var amountUnit: String?
    @NSManaged public var category: String?
    @NSManaged public var done: Bool
    @NSManaged public var dueDate: Date?
    @NSManaged public var id: Int64
    @NSManaged public var itemName: String?
    @NSManaged public var offLineAdded: Bool
    @NSManaged public var offLineDeleted: Bool
    @NSManaged public var updateDate: Date?
    @NSManaged public var username: String?

}
