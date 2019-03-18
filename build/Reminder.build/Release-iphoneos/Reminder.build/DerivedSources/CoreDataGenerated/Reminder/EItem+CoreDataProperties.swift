//
//  EItem+CoreDataProperties.swift
//  
//
//  Created by Jason on 2017/12/8.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension EItem {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<EItem> {
        return NSFetchRequest<EItem>(entityName: "EItem")
    }

    @NSManaged public var category: String?
    @NSManaged public var content: String?
    @NSManaged public var cost: Double

}
