//
//  SetCoreData.swift
//  Reminder
//
//  Created by Yijia Huang on 9/23/17.
//  Copyright © 2017 Iowa State University Com S 309. All rights reserved.
//

import Foundation
import UIKit
import CoreData

/// initialize core data
class setCoreData {
    // MARK: - Methods
    static func initialCoreData(at manageObjectContext: NSManagedObjectContext?) {
        let fetchRequest: NSFetchRequest<SharingListUser> = SharingListUser.fetchRequest()
        do {
            let sharingListUser = try manageObjectContext!.fetch(fetchRequest)
            if sharingListUser.count == 0 {
                let sharingListUserEntity = NSEntityDescription.entity(forEntityName: "SharingListUser", in: manageObjectContext!)!
                let sharingListUser = SharingListUser(entity: sharingListUserEntity, insertInto: manageObjectContext)
                sharingListUser.setValue("me", forKey: "name")
                sharingListUser.setValue(0 , forKey: "numofnotes")
                let sharingListNoteListEntity = NSEntityDescription.entity(forEntityName: "SharingListNoteList", in: manageObjectContext!)!
                let sharingListNoteList = SharingListNoteList(entity: sharingListNoteListEntity, insertInto: manageObjectContext)
                sharingListNoteList.setValue("My First List", forKey: "name")
                sharingListNoteList.setValue(NSDate(), forKey: "created")
                sharingListUser.addToLists(sharingListNoteList)
                try manageObjectContext?.save()
            }
            
        } catch let error {
            print("Could not initial CoreData:\(error.localizedDescription)")
        }
    }

}
