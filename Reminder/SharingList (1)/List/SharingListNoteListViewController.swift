//
//  SharingListNoteListViewController.swift
//  Reminder
//
//  Created by Yijia Huang on 9/28/17.
//  Copyright © 2017 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData
import Firebase

/// list delegate
protocol SLNoteListDelegate {
    func passingUser(user: [SharingListUser]!)
}

/// note list view controller
class SharingListNoteListViewController: ReminderStandardViewController, UITableViewDelegate, UITableViewDataSource,NSFetchedResultsControllerDelegate {
    
    
    // MARK: - Variables
    
    /// dissmiss current view
    ///
    /// - Parameter sender: sender data
    @IBAction func dismissButton(_ sender: UIBarButtonItem) {
        dismiss(animated: true, completion: nil)
    }
    
    /// table view
    @IBOutlet weak var tableView2: UITableView!
    
    /// add new list button
    ///
    /// - Parameter sender: sender data
    @IBAction func createNewListButton(_ sender: Any) {
        performSegue(withIdentifier: "createnewlist", sender: sharingListUsers)
    }
    
    
    // MARK: - variables
    
    /// manage object context
    @objc var manageObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    /// local note
    @objc var sharingListNote: SharingListNote!
    
    /// local users
    @objc var sharingListUsers: [SharingListUser]!
    
    /// fetch result controller
    @objc var fetchedResultsController: NSFetchedResultsController<SharingListNoteList>! {
        didSet {
            fetchedResultsController?.delegate = self
        }
    }
    
    var fbGroup: FbGroup?
    
    /// section titles
    @objc let sectionTitles: [String] = ["All NoteLists"]
    
    /// section iamges
    @objc let sectionImages: [UIImage] = [#imageLiteral(resourceName: "icons8-Microsoft OneNote-64")]
    
    /// list delegate
    var delegate: SLNoteListDelegate?
    
    /// all notes view controller
    @objc var topVC: SLNoteListTVC1?
    
    /// last selected cell
    @objc var lastSelectedCell: UITableViewCell?
    
    // MARK: - Methods
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        if fbGroup != nil {
            let fetchRequest: NSFetchRequest<SharingListUser> = SharingListUser.fetchRequest()
            do {
                sharingListUsers = try manageObjectContext!.fetch(fetchRequest)
            } catch let error { print(error) }
        } else {
            if sharingListNote != nil {
                sharingListUsers = [(sharingListNote.owner?.owner!)!]
            }
        }
        initialVar()
        initialUI()
        reloadData()
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    ///
    /// - Parameter animated: animated bool
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableAnimation()
        reloadData()
    }
    
    /// Sent to the view controller when the app receives a memory warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// initialized variables
    @objc func initialVar() {
        self.tableView2.delegate = self
        self.tableView2.dataSource = self
        guard let firstController = childViewControllers.first as? SLNoteListTVC1 else {
            fatalError("error")
        }
        topVC = firstController
    }
    
    /// initialized UI
    @objc func initialUI() {
        self.tableView2.backgroundColor = UIColor.clear
        self.tableView2.separatorStyle = UITableViewCellSeparatorStyle.none
    }
    
    /// enable animation
    @objc func enableAnimation() {
        tabBarController?.tabBar.isHidden = false
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsOnTap = false
        navigationController?.hidesBarsWhenKeyboardAppears = false
    }
    
    // Mark : - segue!!
    
    /// Notifies the view controller that a segue is about to be performed.
    ///
    /// - Parameters:
    ///   - segue: segue
    ///   - sender: sender
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "embeddedsegue" {
            let embeddedVC = segue.destination as! SLNoteListTVC1
            if sharingListNote != nil {
                embeddedVC.users = [(sharingListNote.owner?.owner!)!]
            } else if sharingListUsers != nil {
                embeddedVC.users = sharingListUsers
            } else {
                let fetchRequest: NSFetchRequest<SharingListUser> = SharingListUser.fetchRequest()
                do {
                    embeddedVC.users = try manageObjectContext!.fetch(fetchRequest)
                } catch let error { print(error) }
            }
        }
        if segue.identifier == "createnewlist" {
            let addListVC = segue.destination as! AddNewListVC
            addListVC.sharingListUsers = sender as! [SharingListUser]!
        }
        if segue.identifier == "editlist" {
            let editListVC = segue.destination as! AddNewListVC
            editListVC.sharingListNoteList = sender as! SharingListNoteList!
        }
    }
    
    /// reload table view data
    ///
    /// - Parameter predicate: predicate
    @objc func reloadData(predicate: NSPredicate? = nil) {
        let fetchRequest: NSFetchRequest<SharingListNoteList> = SharingListNoteList.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "created", ascending: true)
        ]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: manageObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        fetchedResultsController.fetchRequest.predicate = nil
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("There is an error fectching the data")
        }
        self.tableView2.reloadData()
    }
    
    // MARK : - UITableViewDataSource
    
    /// Asks the data source to return the number of sections in the table view.
    ///
    /// - Parameter tableView: table view
    /// - Returns: section number
    func numberOfSections(in tableView: UITableView) -> Int {
        return fetchedResultsController?.sections?.count ?? 1
    }
    
    /// Tells the data source to return the number of rows in a given section of a table view.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - section: section
    /// - Returns: number of rows in the section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return fetchedResultsController.sections?[section].numberOfObjects ?? 0
    }
    
    /// Tells the delegate the table view is about to draw a cell for a particular row.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - cell: cell
    ///   - indexPath: index path
    func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        cell.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
    }
    
    /// Asks the delegate for a view object to display in the header of the specified section of the table view.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - section: section
    /// - Returns: header view in the section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let image = UIImageView(image: sectionImages[section])
        image.frame = CGRect(x: 15, y: 5, width: 35, height: 35)
        view.addSubview(image)
        let label = UILabel()
        label.text = sectionTitles[section]
        label.frame = CGRect(x: 60, y: 5, width: 300, height: 35)
        label.font = label.font.withSize(25)
        label.font = UIFont(name: "Times New Roman", size: label.font.pointSize)
        view.addSubview(label)
        view.backgroundColor = UIColor.init(red:0.86, green:0.96, blue:0.93, alpha:1.0)
        return view
    }
    
    /// Asks the delegate for the height to use for the header of a particular section.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - section: section
    /// - Returns: height for header in the section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 45
    }
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    /// - Returns: view cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "listcell2", for: indexPath) as! SLNoteListCell2
        let sharingListNoteList = fetchedResultsController.object(at: indexPath)
        cell.configureCell(list: sharingListNoteList)
        let separatorLineView: UIView = UIView(frame: CGRect(x: 15, y: cell.frame.height - 1, width: self.tableView2.bounds.width, height: 0.5))
        separatorLineView.backgroundColor = self.tableView2.separatorColor
        cell.contentView.addSubview(separatorLineView)
        var selectedListName: String?
        if sharingListNote != nil {
            selectedListName = sharingListNote.owner?.owner?.lastselectedlist
        } else {
            selectedListName = sharingListUsers[0].lastselectedlist
        }
        if sharingListNoteList.name == selectedListName {
            cell.accessoryType = .checkmark
            lastSelectedCell = cell
        }
        return cell
    }
    
    // MARK :- Cell did selected
    
    /// Tells the delegate that the specified row is now selected.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        self.tableView2.deselectRow(at: indexPath, animated: true)
        let curCell = tableView2.cellForRow(at: indexPath)
        if curCell?.textLabel?.text != sharingListUsers[0].lastselectedlist {
            curCell?.accessoryType = .checkmark
            lastSelectedCell?.accessoryType = .none
        }
        let sharingListNote = fetchedResultsController.object(at: indexPath)
        self.sharingListUsers[0].setValue(sharingListNote.name, forKey: "lastselectedlist")
        manageObjectContextSave()
        dismiss(animated: true, completion: sendBackUser)
    }
    
    /// send back data
    @objc func sendBackUser() {
        delegate?.passingUser(user: sharingListUsers)
    }
    
    // MARK: - swipeable buttons in each cell
    
    /// Asks the delegate for the actions to display in response to a swipe in the specified row.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    /// - Returns: row actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let list = self.fetchedResultsController.object(at: indexPath)
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
            if self.sharingListUsers[0].lastselectedlist == list.name {
                self.sharingListUsers[0].lastselectedlist = nil
            }
            self.sharingListUsers[0].numofnotes -= Int16((list.notes?.count)!)
            for note in list.notes!  {
                self.manageObjectContext?.delete(note as! NSManagedObject)
            }
            self.manageObjectContext?.delete(self.fetchedResultsController.object(at: indexPath))
            self.manageObjectContextSave()
            self.topVC?.updateNumofNotes(num: Int(self.sharingListUsers[0].numofnotes), pickAllNotes: self.sharingListUsers[0].lastselectedlist == list.name)
        }
        delete.backgroundColor = UIColor(red:0.84, green:0.45, blue:0.66, alpha:1.0)
        let edit = UITableViewRowAction(style: .normal, title: "More") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
            let sheet = UIAlertController(title: "More Options", message: "wanna more settings?", preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
            let editAction = UIAlertAction(title: "Edit List name", style: .default) {
                (action: UIAlertAction) -> Void in
                self.performSegue(withIdentifier: "editlist", sender: self.fetchedResultsController.object(at: indexPath))
            }
            sheet.addAction(cancelAction)
            sheet.addAction(editAction)
            self.present(sheet, animated: true, completion: nil)
        }
        edit.backgroundColor = UIColor(red:0.40, green:0.88, blue:0.68, alpha:1.0)
        let share = UITableViewRowAction(style: .normal, title: "Upload") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
            self.uploadListToFirebase(list: list)
        }
        share.backgroundColor = UIColor(red:0.36, green:0.69, blue:0.92, alpha:1.0)
        if self.fetchedResultsController.object(at: indexPath).name == "My First List" {
            return fbGroup == nil ? [edit] : [edit, share]
        }
        
        return fbGroup == nil ? [delete, edit] : [delete, edit, share]
    }
    
    // MARK :- upload local list to Firebase
    
    /// upload list to firebase
    ///
    /// - Parameter list: local list
    @objc func uploadListToFirebase(list: SharingListNoteList) {
        
        guard let name = list.name else {
            print("form wrong")
            return
        }
        let uid = Auth.auth().currentUser?.uid
        // set dummy node
        
        // set List
        let curListRef = DatabaseService.shared.groupRef.child((fbGroup?.gid)!).child("groupList").childByAutoId()
        let listParameters = [
            "lid" : curListRef.key,
            "name" : name,
            "gid" : (fbGroup?.gid)!,
            "uploaded_date" : Int64(NSDate().timeIntervalSince1970 * 1000),
            "uploaded_by_uid" : uid!,
            "notes_num" : list.notes?.allObjects.count ?? 0,
            "notes_done" : 0
            ] as [String : Any]
        curListRef.setValue(listParameters)
        list.fbID = curListRef.key
        // set notes
        let noteRef = curListRef.child("sharingListNote")
        let notes = list.notes?.allObjects as? [SharingListNote]
        for note in notes! {
            let curNoteRef = noteRef.childByAutoId()
            let noteParameters = [
                "nid" : curNoteRef.key,
                "lid" : curListRef.key,
                "gid" : (fbGroup?.gid)!,
                "title" : note.title ?? "",
                "text" : note.text ?? "",
                "done" : note.done,
                "doneby" : note.done ? uid! : "",
                "due" : note.due == nil ? "" : String(describing: note.due),
                "created" : NSDate().timeIntervalSince1970,
                ] as [String : Any]
            curNoteRef.setValue(noteParameters)
        }
        alertMessage = "Upload Successfully"
        alert()
    }
    
    /// alert message
    @objc var alertMessage: String?
    
    /// alert
    @objc func alert() {
        let alert = UIAlertController(title: alertMessage, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    // MARK: - fetch & tableview
    
    /// Notifies the receiver that the fetched results controller is about to start processing of one or more changes due to an add, remove, move, or update.
    ///
    /// - Parameter controller: controller
    public func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView2.beginUpdates()
    }
    
    /// Notifies the receiver of the addition or removal of a section.
    ///
    /// - Parameters:
    ///   - controller: controller
    ///   - sectionInfo: section info
    ///   - sectionIndex: sectiono index
    ///   - type: type
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert:
            tableView2.insertSections([sectionIndex], with: .automatic)
        case .delete:
            tableView2.deleteSections([sectionIndex], with: .automatic)
        default:
            break
        }
    }
    
    /// Notifies the receiver that a fetched object has been changed due to an add, remove, move, or update.
    ///
    /// - Parameters:
    ///   - controller: controller
    ///   - anObject: an object
    ///   - indexPath: index path
    ///   - type: type
    ///   - newIndexPath: new index path
    public func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type {
        case .insert:
            tableView2.insertRows(at: [newIndexPath!], with: .automatic)
        case .delete:
            tableView2.deleteRows(at: [indexPath!], with: .automatic)
        case .update:
            tableView2.reloadRows(at: [indexPath!], with: .automatic)
        case .move:
            tableView2.deleteRows(at: [indexPath!], with: .automatic)
            tableView2.insertRows(at: [newIndexPath!], with: .automatic)
        }
    }
    
    /// Notifies the receiver that the fetched results controller has completed processing of one or more changes due to an add, remove, move, or update.
    ///
    /// - Parameter controller: controller
    public func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView2.endUpdates()
    }
    
    /// manage object context save
    @objc func manageObjectContextSave() {
        do {
            try self.manageObjectContext?.save()
        } catch let error {
            print("Could not save SharingListNote to CoreData: \(error.localizedDescription)")
        }
        reloadData()
    }
    
    
    
}


// MARK : - Cells & TVC ---------------------------------------------------

/// list table view controller
class SLNoteListTVC1: UITableViewController {
    
    // MARK: - Variables
    /// local users
    @objc var users: [SharingListUser]!
    
    /// list cell
    @IBOutlet weak var noteListCell1: SLNoteListCell1!
    
    
    // MARK: - Methods
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        self.tableView.backgroundColor = UIColor.init(red:0.86, green:0.96, blue:0.93, alpha:1.0)
        if users[0].lastselectedlist == nil {
            noteListCell1.accessoryType = .checkmark
        }
        noteListCell1.textLabel?.text = "All Notes"
        noteListCell1.detailTextLabel?.text = String(users[0].numofnotes) + " notes"
    }
    
    /// Sent to the view controller when the app receives a memory warning.
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    /// Tells the delegate that the specified row is now selected.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            users[0].lastselectedlist = nil
            dismiss(animated: true, completion: nil)
        }
    }
    
    /// update num of notes
    ///
    /// - Parameters:
    ///   - num: num of notes
    ///   - pickAllNotes: all notes option is picked
    @objc func updateNumofNotes(num: Int, pickAllNotes: Bool) {
        noteListCell1.detailTextLabel?.text = String(num) + " notes"
        if (pickAllNotes) {
            noteListCell1.accessoryType = .checkmark
        }
    }
    
}

/// list cell
class SLNoteListCell1: UITableViewCell {
    
    /// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    override func awakeFromNib() {
        super.awakeFromNib()
        self.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
    }
    
    /// Sets the selected state of the cell, optionally animating the transition between states.
    ///
    /// - Parameters:
    ///   - selected: is selected
    ///   - animated: animated
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
}

/// list cell
class SLNoteListCell2: UITableViewCell {
    
    /// Prepares the receiver for service after it has been loaded from an Interface Builder archive, or nib file.
    override func awakeFromNib() {
        super.awakeFromNib()
    }
    
    /// Sets the selected state of the cell, optionally animating the transition between states.
    ///
    /// - Parameters:
    ///   - selected: is selected
    ///   - animated: animated
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
    }
    
    /// configure cell
    ///
    /// - Parameter list: list
    @objc func configureCell(list: SharingListNoteList) {
        self.textLabel?.text = list.name
        self.detailTextLabel?.text =  String(describing: list.notes!.allObjects.count) + " notes"
    }
    
}






