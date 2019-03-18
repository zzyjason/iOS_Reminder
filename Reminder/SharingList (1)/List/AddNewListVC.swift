//
//  AddNewListVC.swift
//  Reminder
//
//  Created by Yijia Huang on 9/28/17.
//  Copyright © 2017 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData
import Firebase
/// add new list view controller
class AddNewListVC: ReminderStandardViewController {

    // MARK: - Variables
    /// dismiss current pop up
    ///
    /// - Parameter sender: sender data
    @IBAction func dismissPopup(_ sender: UIButton) {
        dismiss()
    }
    
    /// list name
    @IBOutlet weak var newListName: UITextField!
    
    /// list title
    @IBOutlet weak var editTitle: UILabel!
    
    /// save button
    ///
    /// - Parameter sender: sender data
    @IBAction func saveButton(_ sender: UIButton) {
        if group != nil {
            if newListName.text != "" && newListName.text != nil {
                saveNewListToFirebase()
                dismiss()
            }
        } else if !checkDuplicate() {
            if sharingListNoteList != nil {
                self.updateList()
                dismiss()
            } else {
                if !((newListName.text?.isEmpty)!) {
                    self.addList()
                }
                dismiss()
            }
        } else {
            createAlert()
        }
    }
    
    var group: FbGroup?
    
    /// note list
    @objc var sharingListNoteList: SharingListNoteList!
    
    /// local users
    @objc var sharingListUsers: [SharingListUser]!
    
    /// manage object context
    @objc var manageObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    // MARK: - Methods
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        if sharingListNoteList != nil {
            newListName.text = sharingListNoteList.name
            editTitle.text = "Edit your list name"
            sharingListUsers = [(sharingListNoteList.owner)!]
        } else {
            newListName.text = ""
            editTitle.text = "Create your new List"
        }
        newListName.delegate = self
    }
    
    /// dismiss the current view
    @objc func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    func saveNewListToFirebase() {
        let listRef = DatabaseService.shared.groupRef.child((group?.gid)!).child("groupList").childByAutoId()
        let listParameters = [
            "lid" : listRef.key,
            "name" : newListName.text!,
            "gid" : group?.gid! ?? "",
            "uploaded_date" : Int64(NSDate().timeIntervalSince1970 * 1000),
            "uploaded_by_uid" : Auth.auth().currentUser?.uid ?? "",
            "notes_num" : 0,
            "notes_done" : 0
            ] as [String : Any]
        listRef.setValue(listParameters)
    }
    
    /// add list
    @objc func addList() {
            let entity = NSEntityDescription.entity(forEntityName: "SharingListNoteList", in: self.manageObjectContext!)!
            let SLobject = SharingListNoteList(entity: entity, insertInto: self.manageObjectContext!)
            SLobject.setValue(self.newListName.text, forKey: "name")
            SLobject.setValue(NSDate(), forKey: "created")
            sharingListUsers[0].addToLists(SLobject)
            manageObjectContextSave()
    }
    
    /// check duplicate
    ///
    /// - Returns: ture if there is a duplicate
    @objc func checkDuplicate() -> Bool {
        for list in (sharingListUsers[0].lists?.allObjects as! [SharingListNoteList]) {
            if list.name == newListName.text {
                if sharingListNoteList != nil , sharingListNoteList.name == newListName.text {
                    return false
                }
                return true
            }
        }
        return false
    }
    
    /// create alert
    @objc func createAlert() {
        let alert = UIAlertController(title: "List already exists", message: "Please give a new name", preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// update list
    @objc func updateList() {
            sharingListNoteList.setValue(self.newListName.text, forKey: "name")
            manageObjectContextSave()
    }
    
    /// manage object context save
    @objc func manageObjectContextSave() {
        do {
            try self.manageObjectContext?.save()
        } catch let error {
            print("Could not save SharingListNote to CoreData: \(error.localizedDescription)")
        }
    }

}

// MARK: - UITextFieldDelegate
extension AddNewListVC : UITextFieldDelegate {
    // MARK: - UITextFieldDelegate
    
    /// Asks the delegate if the text field should process the pressing of the return button.
    ///
    /// - Parameter textField: text field
    /// - Returns: bool
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        newListName.resignFirstResponder()
        return true
    }
}


