//
//  SharingListNotesTableViewCell.swift
//  Reminder
//
//  Created by Yijia Huang on 9/17/17.
//  Copyright © 2017 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit

/// sharing list note cell
class SharingListNotesTableViewCell: SwipeTableViewCell {

    // MARK: - Variables
    /// note created date
    @IBOutlet weak var sharingListNoteCreated: UILabel!
    
    /// note title
    @IBOutlet weak var sharingListNoteTitle: UILabel!
    
    /// note description
    @IBOutlet weak var sharingListNoteDescription: UILabel!
    
    // MARK: - Methods
    /// configure cell
    ///
    /// - Parameter note: note
    @objc func configureCell(note: SharingListNote) {
        self.sharingListNoteCreated.text = note.created?.stringValue
        self.sharingListNoteTitle.text = note.title
        self.sharingListNoteDescription.text = note.text
        if note.done == true {
            self.accessoryType = .checkmark
        } else {
            self.accessoryType = .none
        }
    }
    
    /// configure
    ///
    /// - Parameter note: firebase note
    func configureFbCell(note: FbSharingListNote) {
        self.sharingListNoteTitle.text = note.title
        self.sharingListNoteDescription.text = note.text
        if note.done == true {
            self.accessoryType = .checkmark
            DatabaseService.shared.userRef.child(note.doneby!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    self.sharingListNoteCreated.text = "Done by: \(dictionary["name"] as? String ?? "")"
                }
            }, withCancel: nil)
        } else {
            self.accessoryType = .none
            self.sharingListNoteCreated.text = NSDate(timeIntervalSince1970: TimeInterval(note.created!)).stringValue
        }
    }
    
}

// MARK: - extension of NSDate
extension NSDate {
    @objc var stringValue: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "MM/dd/yyyy HH:mm"
        return formatter.string(from: self as Date)
    }
}
