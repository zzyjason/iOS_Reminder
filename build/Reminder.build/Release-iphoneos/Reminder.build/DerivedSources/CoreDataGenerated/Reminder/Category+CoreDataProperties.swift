//
//  Category+CoreDataProperties.swift
//  
//
//  Created by Jason on 2017/12/8.
//
//  This file was automatically generated and should not be edited.
//

import Foundation
import CoreData


extension Category {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<Category> {
        return NSFetchRequest<Category>(entityName: "Category")
    }

    @NSManaged public var title: String?

}
