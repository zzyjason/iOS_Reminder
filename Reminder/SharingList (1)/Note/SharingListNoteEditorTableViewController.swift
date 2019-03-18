//
//  SharingListNoteEditorTableViewController.swift
//  Reminder
//
//  Created by Yijia Huang on 9/17/17.
//  Copyright © 2017 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData
import Firebase

/// sharing list note editor table view controller
class SharingListNoteEditorTableViewController: ReminderStandardTableViewController {
    
    // MARK: - Variables
    /// note title
    @IBOutlet weak var SharingListNoteTitle: UITextView!
    
    /// note description
    @IBOutlet weak var SharingListNoteDescription: UITextView!
    
    /// show note list button
    @IBOutlet weak var showSharingListNoteListButton: UIButton!
    
    /// show note list button with handler
    ///
    /// - Parameter sender: sender data
    @IBAction func showSharingListNoteList(_ sender: Any) {
        if sharingListNote != nil {
            performSegue(withIdentifier: "showNoteListFromNoteEditor", sender: sharingListNote)
        } else {
            performSegue(withIdentifier: "showNoteListFromNoteEditor", sender: sharingListUsers)
        }
    }
    
    
    // MARK: - variables
    
    /// manage object context
    @objc var manageObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    /// current note
    @objc var sharingListNote: SharingListNote!
    
    /// local users
    @objc var sharingListUsers: [SharingListUser]!
    
    /// firebase note
    var fbNote: FbSharingListNote!
    
    /// firebase list
    var fbList: FbSharingList!
    
    // MARK: - Methods
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        initialUI()
        initialVar()
    }
    
    /// initialized variables
    @objc func initialVar() {
        if fbNote != nil {
            self.SharingListNoteTitle.text = fbNote.title
            self.SharingListNoteDescription.text = fbNote.text
        }
        else if sharingListNote != nil {
            // there is a note passed into this class, lets edit
            self.SharingListNoteTitle.text = sharingListNote.value(forKey: "title") as? String
            self.SharingListNoteDescription.text = sharingListNote.value(forKey: "text") as? String
            sharingListUsers = [(sharingListNote.owner?.owner)!]
        } else {
            self.SharingListNoteTitle.text = "Title"
            self.SharingListNoteTitle.textColor = UIColor.lightGray
            self.SharingListNoteDescription.text = "Description starting here"
            self.SharingListNoteDescription.textColor = UIColor.lightGray
        }
        SharingListNoteTitle.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        SharingListNoteDescription.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        if fbNote == nil && fbList == nil {
            checkListButtonTitle()
        }
    }
    
    /// initialize UI
    @objc func initialUI() {
        SharingListNoteTitle.delegate = self
        SharingListNoteDescription.delegate = self
        tabBarController?.tabBar.isHidden = true
        tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        setSaveBarButton()
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    ///
    /// - Parameter animated: animated bool
    override func viewWillAppear(_ animated: Bool) {
        if fbNote == nil && fbList == nil {
            checkListButtonTitle()
            checkListStatus()
            tableView.reloadData()
        }
    }
    
    /// check list status
    @objc func checkListStatus() {
        if sharingListNote != nil && sharingListNote.owner != nil {
            print("yes")
        } else {
            sharingListNote = nil
            initialVar()
        }
    }
    
    /// check list button title
    @objc func checkListButtonTitle() {
        showSharingListNoteListButton.setTitle(sharingListUsers[0].lastselectedlist ?? "My First List", for: UIControlState.normal)
    }
    
    /// Tells the delegate the table view is about to draw a cell for a particular row.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - cell: cell
    ///   - indexPath: index path
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.contentView.subviews.count == 4 {
        } else {
            addCellSubView(cell: cell)
        }
    }
    
    /// add cell subview
    ///
    /// - Parameter cell: cell
    @objc func addCellSubView(cell: UITableViewCell) {
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 18, y: 18, width: self.view.frame.size.width - 36, height: cell.frame.height - 24))
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [0.93, 0.90, 0.69, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 6
        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.6
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubview(toBack: whiteRoundedView)
        cell.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
    }
    
    /// set save bar button
    @objc func setSaveBarButton() {
        var saveBarButton: UIBarButtonItem?
        if fbNote != nil || fbList != nil {
            saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveFbNote))
        } else {
            saveBarButton = UIBarButtonItem(barButtonSystemItem: .save, target: self, action: #selector(self.saveNote))
        }
        navigationItem.leftBarButtonItem = saveBarButton
    }
    
    /// save note data to firebase
    @objc func saveFbNote() {
        if fbNote != nil {
            self.updateFbNote()
        } else {
            if isInputEmpty() {
            } else {
                self.screateNewFbNote()
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    /// create new note on firebase
    @objc func screateNewFbNote() {
        let noteRef = DatabaseService.shared.groupRef.child(fbList.gid!).child("groupList").child(fbList.lid!).child("sharingListNote").childByAutoId()
        let noteParameters = [
            "nid" : noteRef.key,
            "lid" : fbList.lid!,
            "gid" : fbList.gid!,
            "title" : SharingListNoteTitle.text == "Title" ? "" :SharingListNoteTitle.text,
            "text" : SharingListNoteDescription.text == "Description starting here" ? "" : SharingListNoteDescription.text,
            "done" : false,
            "doneby" : "",
            "due" : "",
            "created" : NSDate().timeIntervalSince1970,
            ] as [String : Any]
        noteRef.setValue(noteParameters)
        fbList.notes_num = fbList.notes_num! + 1
        DatabaseService.shared.groupRef.child(fbList.gid!).child("groupList").child(fbList.lid!).updateChildValues(["notes_num" : fbList.notes_num!])
    }
    
    /// update note data on firebase
    @objc func updateFbNote() {
        let curNoteRef = DatabaseService.shared.groupRef.child(fbNote.gid!).child("groupList").child(fbNote.lid!).child("sharingListNote").child(fbNote.nid!)
        fbNote.text = SharingListNoteDescription.text
        fbNote.title = SharingListNoteTitle.text
        curNoteRef.updateChildValues(["text" : fbNote.text!,
                                      "title" : fbNote.title!])
    }
    
    /// save note to local coredata
    @objc func saveNote() {
        if sharingListNote != nil {
            self.updateSharingListNote()
        } else {
            if isInputEmpty() {
            } else {
                self.createNewSharingListNote()
            }
        }
        self.navigationController?.popViewController(animated: true)
    }
    
    /// inout is empty
    ///
    /// - Returns: true if input is empty
    @objc func isInputEmpty() -> Bool {
        return (SharingListNoteDescription.text == "Description starting here" || SharingListNoteDescription.text!.isEmpty) && (SharingListNoteTitle.text == "Title"
        || SharingListNoteTitle.text!.isEmpty)
    }
    
    // create new note
    
    /// create new local note
    @objc func createNewSharingListNote() {
        let sharingListNoteEntity = NSEntityDescription.entity(forEntityName: "SharingListNote", in: self.manageObjectContext!)!
        let sharingListNoteObject = SharingListNote(entity: sharingListNoteEntity, insertInto: self.manageObjectContext!)
        if SharingListNoteTitle.text != "Title" {
            sharingListNoteObject.setValue(self.SharingListNoteTitle.text, forKey: "title")
        }
        if SharingListNoteDescription.text != "Description starting here" {
            sharingListNoteObject.setValue(self.SharingListNoteDescription.text, forKey: "text")
        }
        sharingListNoteObject.setValue(NSDate(), forKey: "created")
        sharingListNoteObject.setValue(nil, forKey: "alarm")
        sharingListNoteObject.setValue(false, forKey: "done")
        let lists = sharingListUsers[0].lists?.allObjects as! [SharingListNoteList]
        for list in lists {
            if list.name == showSharingListNoteListButton.titleLabel?.text {
                list.addToNotes(sharingListNoteObject)
            }
        }
        sharingListUsers[0].numofnotes += 1
        manageObjectContextSave()
    }
    
    // save back to core data
    
    /// update local note
    @objc func updateSharingListNote() {
        checkListButtonTitle()
        sharingListNote.setValue(self.SharingListNoteTitle.text, forKey: "title")
        sharingListNote.setValue(self.SharingListNoteDescription.text, forKey: "text")
        if sharingListNote.owner?.name == showSharingListNoteListButton.titleLabel?.text {
        } else {
            let lists = sharingListUsers[0].lists?.allObjects as! [SharingListNoteList]
            for list in lists {
                if list.name == sharingListNote.owner?.name {
                    list.removeFromNotes(sharingListNote)
                }
            }
            for list in lists {
                if list.name == showSharingListNoteListButton.titleLabel?.text {
                    list.addToNotes(sharingListNote)
                }
            }
        }
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
    
    // MARK: - Table View Interaction
    
    /// no use interaction each row
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    /// - Returns: current index path
    override func tableView(_ tableView: UITableView, willSelectRowAt indexPath: IndexPath) -> IndexPath? {
        return nil
    }
    
    /// Notifies the view controller that a segue is about to be performed.
    ///
    /// - Parameters:
    ///   - segue: segue
    ///   - sender: sender data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "showNoteListFromNoteEditor" {
            let sharingListNoteListTVC = segue.destination as! SharingListNoteListViewController
            if sharingListNote != nil {
                sharingListNoteListTVC.sharingListNote = sender as! SharingListNote
            } else {
                sharingListNoteListTVC.sharingListUsers = sender as! [SharingListUser]!
            }
        }
    }
}


// MARK: - UITextFieldDelegate, UITextViewDelegate
extension SharingListNoteEditorTableViewController : UITextFieldDelegate, UITextViewDelegate {
    // MARK: - UITextFieldDelegate
    
    /// Asks the delegate if the text field should process the pressing of the return button.
    ///
    /// - Parameter textField: text field
    /// - Returns: bool
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // dismiss the keyboard
        SharingListNoteTitle.resignFirstResponder()
        return true
    }
    
    // MARK: - UIScrollViewDelegate
    
    /// Tells the delegate when the scroll view is about to start scrolling the content.
    ///
    /// - Parameter scrollView: scroll view
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        SharingListNoteTitle.resignFirstResponder()
        SharingListNoteDescription.resignFirstResponder()
    }
    
    
    // placeholder text
    
    /// Tells the delegate that editing of the specified text view has begun.

    ///
    /// - Parameter textView: text view
    func textViewDidBeginEditing(_ textView: UITextView) {
        if textView.text == "Title" {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder()
        
        if textView.text == "Description starting here" {
            textView.text = ""
            textView.textColor = .black
        }
        textView.becomeFirstResponder()
        
    }
}
















