//
//  SharingListNotesTableViewController.swift
//  Reminder
//
//  Created by Yijia Huang on 9/17/17.
//  Copyright © 2017 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData
import SwipeCellKit
import UserNotifications
import Firebase

//@IBDesignable

/// notes table view controller
class SharingListNotesTableViewController: FetchedResultsTableViewController, SLNoteListDelegate, SwipeTableViewCellDelegate {
    
    /// passing user
    ///
    /// - Parameter user: local users data
    @objc func passingUser(user: [SharingListUser]!) {
        sharingListUsers = user
    }
    
    // MARK: - Buttons & Labels
    /// add new sharing list buttion
    ///
    /// - Parameter sender: sender data
    @IBAction func createNewSharingListNoteButton(_ sender: Any) {
        if fbList == nil {
            performSegue(withIdentifier: "CreateNewSharingListNote", sender: sharingListUsers)
        } else {
            performSegue(withIdentifier: "newfbnote", sender: fbList)
        }
    }
    
    /// to note list button
    @IBOutlet weak var toSharingListNoteListButton: UIButton!
    
    /// to note list button with handler
    ///
    /// - Parameter sender: sender data
    @IBAction func toSharingListNoteListButton(_ sender: Any) {
        if fbList == nil {
            performSegue(withIdentifier: "showNoteListFromNotes", sender: sharingListUsers)
        }
    }
    
    // MARK: - variables
    /// manage object context
    @objc var manageObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    /// local users
    @objc var sharingListUsers: [SharingListUser]!
    
    /// fetch result controller
    @objc var fetchedResultsController: NSFetchedResultsController<SharingListNote>! {
        didSet {
            fetchedResultsController?.delegate = self
        }
    }
    
    /// default options
    var defaultOptions = SwipeTableOptions()
    
    /// is swipe right enabled
    @objc var isSwipRightEnabled: Bool = true
    
    /// button display mode
    var buttonDisplayMode: ButtonDisplayMode = .imageOnly
    
    /// button style
    var buttonStyle: ButtonStyle = .circular
    
    /// local note list
    var fbList: FbSharingList?
    
    /// local notes
    var fbnotes = [FbSharingListNote]()
    
    /// account view controller
    @objc var accountVC: GroupViewController?
    
    /// firebase user
    var curUser: FbUser?
    
    // MARK: - Methods
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        setCoreData.initialCoreData(at: manageObjectContext)
        setNotifications()
        initialUI()
        initialVar()
        if fbList != nil {
            fetchFbNotes()
        } else {
            reloadData()
        }
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    ///
    /// - Parameter animated: animated bool
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        enableAnimation()
        if fbList == nil {
            reloadData()
        }
    }
    
    /// initialize variables
    @objc func initialVar() {
        defaultOptions.transitionStyle = .drag
        let fetchRequest: NSFetchRequest<SharingListUser> = SharingListUser.fetchRequest()
        do {
            sharingListUsers = try manageObjectContext!.fetch(fetchRequest)
        } catch let error {
            print("Could not fetch users from CoreData:\(error.localizedDescription)")
        }
        checkListButtonTitle()
    }
    
    /// initialize UI
    @objc func initialUI() {
        self.tableView.estimatedRowHeight = tableView.rowHeight
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        if fbList != nil {
            self.navigationItem.leftBarButtonItem = nil
        }
    }
    
    /// enable animation
    @objc func enableAnimation() {
        tabBarController?.tabBar.isHidden = fbList == nil ? false : true
        navigationController?.hidesBarsOnSwipe = false
        navigationController?.hidesBarsOnTap = false
        navigationController?.hidesBarsWhenKeyboardAppears = false
    }
    
    /// check list button title
    @objc func checkListButtonTitle() {
        if fbList != nil {
            toSharingListNoteListButton.setTitle(fbList?.name, for: .normal)
        } else if sharingListUsers[0].lastselectedlist == nil {
            toSharingListNoteListButton.setTitle("All Notes", for: UIControlState.normal)
        } else {
            toSharingListNoteListButton.setTitle(sharingListUsers[0].lastselectedlist, for: UIControlState.normal)
        }
    }
    
    /// fetch notes data from firebase
    @objc func fetchFbNotes() {
        let noteRef = DatabaseService.shared.groupRef.child((fbList?.gid!)!).child("groupList").child((fbList?.lid!)!).child("sharingListNote")
        noteRef.observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                let notesSnapshot = NotesSnapshot(with: snapshot)
                self.fbnotes = (notesSnapshot?.notes)!
                self.tableView.reloadData()
            } else {
                self.fbnotes.removeAll()
                if self.tableView.numberOfRows(inSection: 0) == 1 {
                    self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                } else {
                    self.tableView.reloadData()
                }
            }
        })
    }
    
    /// reload table view data
    ///
    /// - Parameter predicate: preidcate
    @objc func reloadData(predicate: NSPredicate? = nil) {
        let fetchRequest: NSFetchRequest<SharingListNote> = SharingListNote.fetchRequest()
        fetchRequest.sortDescriptors = [
            NSSortDescriptor(key: "created", ascending: false)
        ]
        fetchedResultsController = NSFetchedResultsController(fetchRequest: fetchRequest, managedObjectContext: manageObjectContext!, sectionNameKeyPath: nil, cacheName: nil)
        if sharingListUsers[0].lastselectedlist != nil {
            fetchedResultsController.fetchRequest.predicate = NSPredicate(format: "owner.name == %@", sharingListUsers[0].lastselectedlist!)
        }
        else {
            fetchedResultsController.fetchRequest.predicate = predicate
        }
        do {
            try fetchedResultsController.performFetch()
        } catch {
            fatalError("There is an error fectching the data")
        }
        checkListButtonTitle()
        self.tableView.reloadData()
    }
    
    // MARK: - Table view data source
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    /// - Returns: view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        if fbList != nil {
            let thisCell = tableView.dequeueReusableCell(withIdentifier: "SharingListNotesCell", for: indexPath) as! SharingListNotesTableViewCell
            thisCell.delegate = self
            thisCell.configureFbCell(note: fbnotes[indexPath.row])
            return thisCell
        } else {
            let thisCell = tableView.dequeueReusableCell(withIdentifier: "SharingListNotesCell", for: indexPath) as! SharingListNotesTableViewCell
            thisCell.delegate = self
            let sharingListnote = fetchedResultsController.object(at: indexPath)
            thisCell.configureCell(note: sharingListnote)
            return thisCell
        }
    }
    
    // MARK: - update white block subview
    
    /// Tells the delegate the table view is about to draw a cell for a particular row.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - cell: cell
    ///   - indexPath: index path
    override func tableView(_ tableView: UITableView, willDisplay cell: UITableViewCell, forRowAt indexPath: IndexPath) {
        if cell.contentView.subviews.count == 4 {
            cell.contentView.subviews[0].removeFromSuperview()
            addCellSubView(cell: cell)
        } else {
            addCellSubView(cell: cell)
        }
    }
    
    /// add cell subview
    ///
    /// - Parameter cell: table view cell
    @objc func addCellSubView(cell: UITableViewCell) {
        let whiteRoundedView : UIView = UIView(frame: CGRect(x: 10, y: 8, width: self.view.frame.size.width - 20, height: cell.frame.height - 12))
        whiteRoundedView.layer.backgroundColor = CGColor(colorSpace: CGColorSpaceCreateDeviceRGB(), components: [1.0, 1.0, 1.0, 1.0])
        whiteRoundedView.layer.masksToBounds = false
        whiteRoundedView.layer.cornerRadius = 6
        whiteRoundedView.layer.shadowOffset = CGSize(width: -1, height: 1)
        whiteRoundedView.layer.shadowOpacity = 0.2
        cell.contentView.addSubview(whiteRoundedView)
        cell.contentView.sendSubview(toBack: whiteRoundedView)
        cell.backgroundColor = UIColor.init(red: 1.0, green: 1.0, blue: 1.0, alpha: 0.0)
    }
    
    // MARK: - UITableViewDelegate
    
    /// Tells the delegate that the specified row is now selected.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.tableView.deselectRow(at: indexPath, animated: true)
        if fbList == nil {
            let sharingListNote = fetchedResultsController.object(at: indexPath)
            self.performSegue(withIdentifier: "ShowSharingListNoteEditor", sender: sharingListNote)
        } else {
            self.performSegue(withIdentifier: "showfbnoteditor", sender: fbnotes[indexPath.row])
        }
    }
    
    // MARK: - give the editor vc its sharingListNote or Users
    
    /// Notifies the view controller that a segue is about to be performed.
    ///
    /// - Parameters:
    ///   - segue: segue
    ///   - sender: sender data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "ShowSharingListNoteEditor" {
            let sLNoteEditorViewController = segue.destination as! SharingListNoteEditorTableViewController
            sLNoteEditorViewController.sharingListNote = sender as! SharingListNote
        }
        if segue.identifier == "CreateNewSharingListNote" {
            let sharingListNoteEditorVC = segue.destination as! SharingListNoteEditorTableViewController
            sharingListNoteEditorVC.sharingListUsers = sender as! [SharingListUser]!
        }
        if segue.identifier == "showNoteListFromNotes" {
            let sharingListNoteListTVC = segue.destination as! SharingListNoteListViewController
            sharingListNoteListTVC.sharingListUsers = sender as! [SharingListUser]!
            sharingListNoteListTVC.delegate = self
        }
        if segue.identifier == "showfbnoteditor" {
            let fbNoteEditorVC = segue.destination as! SharingListNoteEditorTableViewController
            fbNoteEditorVC.fbNote = sender as! FbSharingListNote!
        }
        if segue.identifier == "newfbnote" {
            let fbNoteEditorVc = segue.destination as! SharingListNoteEditorTableViewController
            fbNoteEditorVc.fbList = sender as! FbSharingList!
        }
        
        if (segue.identifier=="SharingListToMenu")
        {
            let ToVC=segue.destination as! MenuBarViewController
            ToVC.CurrentFeature=1
        }
    }
    
    // Swipe Cell Kit functions
    
    /// edit actions for each row
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    ///   - orientation: orientation
    /// - Returns: swipe action
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        if fbList != nil {
            return setFbNotesButtons(tableView: tableView, indexPath: indexPath, orientation: orientation)
        } else {
            let cell = self.tableView.cellForRow(at: indexPath)
            let note = self.fetchedResultsController.object(at: indexPath)
            if orientation == .left {
                return nil
            } else {
                let delete = SwipeAction(style: .default, title: nil) { (rowAction: SwipeAction, indexPath: IndexPath) -> Void in
                    self.sharingListUsers[0].numofnotes -= 1
                    self.manageObjectContext?.delete(self.fetchedResultsController.object(at: indexPath))
                    self.manageObjectContextSave()
                }
                configure(action: delete, with: .trash)
                let alarm = SwipeAction(style: .default, title: "Alarm") { (rowAction: SwipeAction, indexPath: IndexPath) -> Void in
                    if note.alarm == nil {
                        self.setNotification(indexPath: indexPath)
                        note.alarm = NSDate()
                    } else {
                        note.alarm = nil
                    }
                }
                if note.alarm == nil {
                    configure(action: alarm, with: .alarm)
                } else {
                    configure(action: alarm, with: .alarmoff)
                }
                alarm.hidesWhenSelected = true
                let done = SwipeAction(style: .default, title: "Done") { (rowAction: SwipeAction, indexPath: IndexPath) -> Void in
                    if note.done == false {
                        cell?.accessoryType = .checkmark
                        note.done = true
                    } else {
                        cell?.accessoryType = .none
                        note.done = false
                    }
                }
                if note.done == false {
                    configure(action: done, with: .check)
                } else {
                    configure(action: done, with: .cancel)
                }
                done.hidesWhenSelected = true
                return [delete, alarm, done]
            }
        }
    }
    
    //    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
    //        if fbList != nil {
    //            return setFbNotesButtons(tableView: tableView, indexPath: indexPath)
    //        } else {
    //            let cell = self.tableView.cellForRow(at: indexPath)
    //            let note = self.fetchedResultsController.object(at: indexPath)
    //                let delete = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
    //                    self.sharingListUsers[0].numofnotes -= 1
    //                    self.manageObjectContext?.delete(self.fetchedResultsController.object(at: indexPath))
    //                    self.manageObjectContextSave()
    //                }
    //                delete.backgroundColor = UIColor(red:0.84, green:0.45, blue:0.66, alpha:1.0)
    //                let alarm = UITableViewRowAction(style: .normal, title: "Alarm") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
    //                    if note.alarm == nil {
    //                        self.setNotification(indexPath: indexPath)
    //                        note.alarm = NSDate()
    //                    } else {
    //                        note.alarm = nil
    //                    }
    //                }
    //                if note.alarm == nil {
    //
    //                } else {
    //
    //                }
    //                let done = UITableViewRowAction(style: .normal, title: "Done") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
    //                    if note.done == false {
    //                        cell?.accessoryType = .checkmark
    //                        note.done = true
    //                    } else {
    //                        cell?.accessoryType = .none
    //                        note.done = false
    //                    }
    //                }
    //                if note.done == false {
    //
    //                } else {
    //
    //                }
    //                return [delete, alarm, done]
    //        }
    //    }
    //
    //    @objc func setFbNotesButtons(tableView: UITableView, indexPath: IndexPath) -> [UITableViewRowAction]? {
    //        let cell = self.tableView.cellForRow(at: indexPath)
    //        let note = fbnotes[indexPath.row]
    //            let curUserRef = DatabaseService.shared.userRef.child((Auth.auth().currentUser?.uid)!)
    //            curUserRef.observeSingleEvent(of: .value, with: { (snapshot) in
    //                self.user = FbUser(uid: (Auth.auth().currentUser?.uid)!, dict: snapshot.value as! [String : Any])
    //            })
    //            let curListRef = DatabaseService.shared.sharingListRef.child((fbList?.list_id)!)
    //            let curNoteRef = DatabaseService.shared.sharingListRef.child((self.fbList?.list_id)!).child("sharingListNote").child(note.note_id!)
    //            let delete = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
    //                DatabaseService.shared.sharingListRef.child((self.fbList?.list_id)!).child("sharingListNote").child(note.note_id!).setValue(nil)
    //                self.fbnotes.remove(at: indexPath.row)
    //                tableView.deleteRows(at: [indexPath], with: .automatic)
    //                curListRef.updateChildValues(["notes_num" : self.fbnotes.count])
    //            }
    //            let done = UITableViewRowAction(style: .normal, title: "Done") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
    //                if note.done == false {
    //                    cell?.accessoryType = .checkmark
    //                    note.done = true
    //                    note.done_by = Auth.auth().currentUser?.uid
    //
    //                    self.fbList?.notes_done = (self.fbList?.notes_done)! + 1
    //                    self.user?.notes_done = (self.user?.notes_done)! + 1
    //
    //                    curListRef.updateChildValues(["notes_done" : self.fbList?.notes_done ?? 0])
    //                    curUserRef.updateChildValues(["notes_done" : self.user?.notes_done ?? 0])
    //                } else {
    //                    cell?.accessoryType = .none
    //                    note.done = false
    //                    note.done_by = ""
    //
    //                    self.fbList?.notes_done = (self.fbList?.notes_done)! - 1
    //                    self.user?.notes_done = (self.user?.notes_done)! - 1
    //
    //                    curListRef.updateChildValues(["notes_done" : self.fbList?.notes_done ?? 0])
    //                    curUserRef.updateChildValues(["notes_done" : self.user?.notes_done ?? 0])
    //                }
    //                note.setValueToFbRef(curNoteRef: curNoteRef)
    //            }
    //            if note.done == false {
    //
    //            } else {
    //
    //            }
    //            return [delete, done]
    //    }
    
    /// set firebase notes buttons
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    ///   - orientation: orientation
    /// - Returns: swipe action
    func setFbNotesButtons(tableView: UITableView, indexPath: IndexPath, orientation: SwipeActionsOrientation) -> [SwipeAction]? {
        let cell = self.tableView.cellForRow(at: indexPath)
        let note = fbnotes[indexPath.row]
        if orientation == .left {
            return nil
        } else {
            let listRef = DatabaseService.shared.groupRef.child((fbList?.gid!)!).child("groupList").child((fbList?.lid!)!)
            let userRef = DatabaseService.shared.userRef.child((curUser?.uid!)!)
            let delete = SwipeAction(style: .default, title: nil) { (rowAction: SwipeAction, indexPath: IndexPath) -> Void in
                listRef.child("sharingListNote").child(note.nid!).setValue(nil)
                self.fbnotes.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
                self.fbList?.notes_num = (self.fbList?.notes_num)! - 1
                self.fbList?.notes_done = self.fbList?.notes_done != 0 ? (self.fbList?.notes_done)! - 1 : 0
                listRef.updateChildValues(["notes_num" : (self.fbList?.notes_num!)!])
                listRef.updateChildValues(["notes_done" : (self.fbList?.notes_done!)!])
            }
            configure(action: delete, with: .trash)
            let done = SwipeAction(style: .default, title: "Done") { (rowAction: SwipeAction, indexPath: IndexPath) -> Void in
                if note.done == false {
                    cell?.accessoryType = .checkmark
                    self.fbList?.notes_done = (self.fbList?.notes_done)! + 1
                    self.curUser?.notes_done = (self.curUser?.notes_done)! + 1
                    listRef.child("sharingListNote").child(note.nid!).updateChildValues(["doneby" : (Auth.auth().currentUser?.uid)!,
                                                                                         "done" : true])
                    listRef.updateChildValues(["notes_done" : (self.fbList?.notes_done)!])
                    userRef.updateChildValues(["notes_done" : (self.curUser?.notes_done)!])
                } else {
                    cell?.accessoryType = .none
                    self.fbList?.notes_done = (self.fbList?.notes_done)! - 1
                    self.curUser?.notes_done = (self.curUser?.notes_done)! - 1
                    listRef.child("sharingListNote").child(note.nid!).updateChildValues(["doneby" : "",
                                                                                         "done" : false])
                    listRef.updateChildValues(["notes_done" : (self.fbList?.notes_done)!])
                    userRef.updateChildValues(["notes_done" : (self.curUser?.notes_done)!])
                }
            }
            if note.done == false {
                configure(action: done, with: .check)
            } else {
                configure(action: done, with: .cancel)
            }
            done.hidesWhenSelected = true
            return [delete, done]
        }
    }
    
    /// edit actions options for each row
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    ///   - orientation: orientation
    /// - Returns: swipe table options
    func tableView(_ tableView: UITableView, editActionsOptionsForRowAt indexPath: IndexPath, for orientation: SwipeActionsOrientation) -> SwipeTableOptions {
        var options = SwipeTableOptions()
        options.expansionStyle = .none
        options.transitionStyle = defaultOptions.transitionStyle
        
        switch buttonStyle {
        case .backgroundColor:
            options.buttonSpacing = 11
        case .circular:
            options.buttonSpacing = 4
            options.backgroundColor = ReminderStandardViewController.GetCurrentBackGroundThemeColor().MainColor
            
        }
        return options
    }
    
    /// configure each swipe action
    ///
    /// - Parameters:
    ///   - action: action
    ///   - descriptor: descriptor
    func configure(action: SwipeAction, with descriptor: ActionDescriptor) {
        action.title = descriptor.title(forDisplayMode: buttonDisplayMode)
        action.image = descriptor.image(forStyle: buttonStyle, displayMode: buttonDisplayMode)
        
        switch buttonStyle {
        case .backgroundColor:
            action.backgroundColor = descriptor.color
        case .circular:
            action.backgroundColor = .clear
            action.textColor = descriptor.color
            action.font = .systemFont(ofSize: 13)
            action.transitionDelegate = ScaleTransition.default
        }
    }
    
    /// dimiss current view
    @objc func dismiss() {
        dismiss(animated: true, completion: nil)
    }
    
    // MARK: - context save
    
    /// manage object context save
    @objc func manageObjectContextSave() {
        do {
            try self.manageObjectContext?.save()
        } catch let error {
            print("Could not save SharingListNote to CoreData: \(error.localizedDescription)")
        }
    }
    
    
    // MARK: - Notifications -----------
    
    /// set notification
    ///
    /// - Parameter indexPath: index path
    @objc func setNotification(indexPath: IndexPath) {
        let sheet = UIAlertController(title: "Set Notification", message: "Please remind me in", preferredStyle: .actionSheet)
        let fiveSec = UIAlertAction(title: "5 secs", style: .default) {
            (action: UIAlertAction) -> Void in
            self.scheduleNotification(inSeconds: 5, identifier: "5sec", title: self.fetchedResultsController.object(at: indexPath).title!, completion: { success in
                if success {
                    print("Successfully scheduled notfication")
                } else {
                    print("err")
                }
            })
        }
        let tenSec = UIAlertAction(title: "10 secs", style: .default) {
            (action: UIAlertAction) -> Void in
            self.scheduleNotification(inSeconds: 10, identifier: "10sec", title: self.fetchedResultsController.object(at: indexPath).title!, completion: { success in
                if success {
                    print("Successfully scheduled notfication")
                } else {
                    print("err")
                }
            })
        }
        let cancel = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        sheet.addAction(cancel)
        sheet.addAction(fiveSec)
        sheet.addAction(tenSec)
        self.present(sheet, animated: true, completion: nil)
    }
    
    /// set notifiacations
    @objc func setNotifications() {
        UNUserNotificationCenter.current().requestAuthorization(options: [.alert, .badge, .sound], completionHandler: { (granted, error) in
            if granted {
                print("notification access granted")
            } else {
                print(error?.localizedDescription ?? "err")
            }
        })
    }
    
    /// schedule notification
    ///
    /// - Parameters:
    ///   - inSeconds: time interval
    ///   - identifier: id
    ///   - title: titel
    ///   - completion: completion
    @objc func scheduleNotification(inSeconds: TimeInterval, identifier: String, title: String, completion: @escaping (_ success: Bool) -> ()) {
        let notif = UNMutableNotificationContent()
        
        notif.title = "Reminder!!"
        notif.subtitle = "Your project " + title + "is goting to due soon. Please complete it as soon as possible!"
        notif.body = "hihi"
        
        let notifTrigger = UNTimeIntervalNotificationTrigger(timeInterval: inSeconds, repeats: false)
        
        let request = UNNotificationRequest(identifier: identifier, content: notif, trigger: notifTrigger)
        
        UNUserNotificationCenter.current().add(request, withCompletionHandler: { error in
            if error != nil {
                print(error ?? "err")
                completion(false)
            } else {
                completion(true)
            }
        })
    }
    // ---------------------------------
    
}


/// enum for action descriptor
///
/// - more: <#more description#>
/// - trash: <#trash description#>
/// - check: <#check description#>
/// - cancel: <#cancel description#>
/// - alarm: <#alarm description#>
/// - alarmoff: <#alarmoff description#>
enum ActionDescriptor {
    case more, trash, check, cancel, alarm, alarmoff
    
    /// title
    ///
    /// - Parameter displayMode: display mode
    /// - Returns: name
    func title(forDisplayMode displayMode: ButtonDisplayMode) -> String? {
        guard displayMode != .imageOnly else { return nil }
        
        switch self {
        case .more: return "More"
        case .trash: return "Trash"
        case .check: return "Done"
        default: return ""
        }
    }
    
    /// buttom image
    ///
    /// - Parameters:
    ///   - style: style
    ///   - displayMode: mode
    /// - Returns: UI image
    func image(forStyle style: ButtonStyle, displayMode: ButtonDisplayMode) -> UIImage? {
        guard displayMode != .titleOnly else { return nil }
        
        let name: String
        switch self {
        case .more: name = "More-circle"
        case .trash: name = "Trash-circle"
        case .check: name = "icons8-Ok-56"
        case .cancel: name = "icons8-Cancel-54"
        case .alarm: name = "icons8-Alarm on Filled-50"
        case .alarmoff: name = "icons8-Alarm off Filled-50"
        }
        
        return UIImage(named: style == .backgroundColor ? name : name)
    }
    
    /// color
    var color: UIColor {
        switch self {
        case .more: return #colorLiteral(red: 0.7803494334, green: 0.7761332393, blue: 0.7967314124, alpha: 1)
        case .trash: return #colorLiteral(red: 1, green: 0.2352941176, blue: 0.1882352941, alpha: 1)
        default: return .gray
        }
    }
}

/// enum for button display mode
///
/// - titleAndImage: <#titleAndImage description#>
/// - titleOnly: <#titleOnly description#>
/// - imageOnly: <#imageOnly description#>
enum ButtonDisplayMode {
    case titleAndImage, titleOnly, imageOnly
}

/// enum for button style
///
/// - backgroundColor: <#backgroundColor description#>
/// - circular: <#circular description#>
enum ButtonStyle {
    case backgroundColor, circular
}

