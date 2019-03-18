//
//  AccountViewController.swift
//  Reminder
//
//  Created by Yijia Huang on 10/6/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//

import UIKit
import Firebase
import CoreData


/// User account view controller
class GroupViewController: ReminderStandardViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {

    // MARK: - Variables
    /// group member table view
    @IBOutlet weak var groupMemberTV: UITableView!
    
    /// group sharing list table view
    @IBOutlet weak var groupSharingListsTV: UITableView!
    
    /// user cell id
    @objc let userCellId = "usercellId"
    
    /// list cell id
    @objc let listCellId = "listcellId"
    
    /// users firebase data
    var users = [FbUser]()
    
    /// lists firebase data
    var lists = [FbSharingList]()
    
    var userAndGroup: (curUser: FbUser, selectedGroup: FbGroup)?
    
    var userVC: UserViewController?
    
    // MARK: - Methods
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        initialVar()
        initialUI()
        updateUI()
    }
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    ///
    /// - Parameter animated: animated bool
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
    }
    
    /// update UI according to login status
    @objc func updateUI() {
        // user is not logged in
            let uid = Auth.auth().currentUser?.uid
            DatabaseService.shared.userRef.child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    self.userAndGroup?.curUser = FbUser(uid: uid!, dict: dictionary)!
                    self.setupNavBarWithUser(user: self.userAndGroup!.curUser)
                }
            }, withCancel: nil)
            fetchUsersAndLists()
    }
    
    /// diplay message cell on the table view
    @objc func showMessagesController() {
        if userAndGroup?.curUser != nil {
        let messagesController = MessagesController()
        messagesController.curUser = userAndGroup?.curUser
        messagesController.curGroup = userAndGroup?.selectedGroup
        navigationController?.pushViewController(messagesController, animated: true)
        }
    }
    
    /// show chat log view with one chat partner
    ///
    /// - Parameter user: chat partner
    func showChatControllerForUser(user: FbUser) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.chatPartner = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    
    /// initial variables
    @objc func initialVar() {
        groupMemberTV.delegate = self
        groupMemberTV.dataSource = self
        groupMemberTV.register(UserCell.self, forCellReuseIdentifier: userCellId)
        groupSharingListsTV.delegate = self
        groupSharingListsTV.dataSource = self
        groupSharingListsTV.register(ListCell.self, forCellReuseIdentifier: listCellId)
        
        let fetchRequest: NSFetchRequest<SharingListUser> = SharingListUser.fetchRequest()
        do {
            sharingListUsers = try manageObjectContext!.fetch(fetchRequest)
        } catch let error {
            print("Could not fetch users from CoreData:\(error.localizedDescription)")
        }
    }
    
    /// initial UI
    @objc func initialUI() {
        groupMemberTV.backgroundColor = UIColor.clear
        groupMemberTV.separatorStyle = UITableViewCellSeparatorStyle.none
        groupSharingListsTV.backgroundColor = UIColor.clear
        groupSharingListsTV.separatorStyle = UITableViewCellSeparatorStyle.none
        if userAndGroup?.selectedGroup.host == userAndGroup?.curUser.uid || self.userAndGroup?.curUser.status == "Administrator" {
            navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Edit", style: .plain, target: self, action: #selector(EditAction))
        }
    }
    
    @objc func EditAction() {
        let sheet = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let photoLib = UIAlertAction(title: "Edit Group", style: .default) {
            (action: UIAlertAction) -> Void in
            self.EditGroup()
        }
        let camera = UIAlertAction(title: "Dismiss Group", style: .default) {
            (action: UIAlertAction) -> Void in
            self.dismissGroup()
        }
        sheet.addAction(cancelAction)
        sheet.addAction(photoLib)
        sheet.addAction(camera)
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    
    @objc func EditGroup(){
        performSegue(withIdentifier: "EditGroup", sender: self)
    }
    
    @objc func dismissGroup() {
        let alertController = UIAlertController(title: "Are you sure to dismiss this group?", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            
            
            DatabaseService.shared.groupRef.child((self.userAndGroup?.selectedGroup.gid)!).setValue(nil)
            for user in self.users {
                
                DatabaseService.shared.userMessageRef.child(user.uid!).child((self.userAndGroup?.selectedGroup.gid)!).setValue(nil)
                DatabaseService.shared.userGroupsRef.child(user.uid!).child((self.userAndGroup?.selectedGroup.gid)!).setValue(nil)
            }
            self.navigationController?.popViewController(animated: true)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }

    
    /// fetch users data and sharing lists data
    @objc func fetchUsersAndLists() {
        // get users
                DatabaseService.shared.groupRef.child((self.userAndGroup?.selectedGroup.gid)!).child("groupMember").observe(.value, with: { (snapshot) in
                    if snapshot.exists() {
                    guard let snapDict = snapshot.value as? [String: Any] else { return }
                    var userAddresses = [(uid: String?, created: Int64)]()
                    if snapDict[(self.userAndGroup?.curUser.uid)!] == nil && self.userAndGroup?.curUser.status != "Administrator" {
                        self.navigationController?.popViewController(animated: true)
                    }
                    for dict in snapDict {
                        userAddresses.append((dict.key, dict.value as! Int64))
                    }
                    userAddresses.sort(by: { (u1, u2) -> Bool in
                        return u1.created > u2.created
                    })
                    var users = [FbUser]()
                    DatabaseService.shared.userRef.observe(.value, with: { (snapshot) in
                        if snapshot.exists() {
                        guard let dict = snapshot.value as? [String : [String: Any]] else { return }
                        users.removeAll()
                        for address in userAddresses {
                            let user = FbUser(uid: address.uid!, dict: dict[address.uid!]!)
                            users.append(user!)
                        }
                        self.users = users
                        self.groupMemberTV.reloadData()
                        } else {
                            if self.users.count == 0 && self.userAndGroup?.curUser.status != "Administrator" {
                                self.navigationController?.popViewController(animated: true)
                            }
                        }
                    })
                    } else {
                        if self.users.count == 0 && self.userAndGroup?.curUser.status != "Administrator" {
                            self.navigationController?.popViewController(animated: true)
                        }
                    }
                })
        // get lists
        DatabaseService.shared.groupRef.child((userAndGroup?.selectedGroup.gid)!).child("groupList").observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                let listSnapshot = ListsSnapshot(with: snapshot)
                self.lists = (listSnapshot?.lists)!
                self.groupSharingListsTV.reloadData()
            } else {
                self.lists.removeAll()
                if self.groupSharingListsTV.numberOfRows(inSection: 0) == 1 {
                    self.groupSharingListsTV.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                } else {
                    self.groupSharingListsTV.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
    /// check login status
    ///
    /// - Returns: true if user is logined
    @objc func isLogin() -> Bool {
        return Auth.auth().currentUser?.uid != nil;
    }
    
    /// retrun number of sections
    ///
    /// - Parameter tableView: table view
    /// - Returns: number of sections
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    /// Tells the data source to return the number of rows in a given section of a table view.
    ///
    /// - Parameters:
    ///   - tableView: current table view
    ///   - section: current section
    /// - Returns: number of rows in current section
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        var count: Int?
        if tableView == groupMemberTV {
            count = users.count
        }
        if tableView == groupSharingListsTV {
            count = lists.count
        }
        return count ?? 0
    }
    
    /// Asks the delegate for the height to use for a row in a specified location.
    ///
    /// - Parameters:
    ///   - tableView: current table view
    ///   - indexPath: index path
    /// - Returns: height for the current row
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 46
    }
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    ///
    /// - Parameters:
    ///   - tableView: current tableview
    ///   - indexPath: current index path
    /// - Returns: current table view cell
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        var cell: UITableViewCell?
        if Auth.auth().currentUser?.uid == nil {
            cell = UITableViewCell(style: .subtitle, reuseIdentifier: userCellId)
            cell?.backgroundColor = UIColor.clear
        } else {
            if tableView == groupMemberTV {
                let  thisCell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! UserCell
                thisCell.backgroundColor = UIColor.clear
                let user = users[indexPath.row]
                thisCell.textLabel?.text = userAndGroup?.selectedGroup.host == user.uid ? "\(user.name!) (host)" : user.name
                thisCell.detailTextLabel?.text = "Tasks Done: \(user.notes_done!)"
                
                if let profileImageURL = user.profileImageURL {
                    thisCell.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageURL)
                }
                addSeparatorLine(tableView: tableView, cell: thisCell)
                return thisCell
            }
            if tableView == groupSharingListsTV {
                let thisCell = tableView.dequeueReusableCell(withIdentifier: listCellId, for: indexPath) as! ListCell
                thisCell.backgroundColor = UIColor.clear
                let list = lists[indexPath.row]
                thisCell.textLabel?.text = list.name
                DatabaseService.shared.userRef.child(list.uploaded_by_uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: Any] {
                        let detailString = "Created by: \(dictionary["name"]!)  (\(list.notes_done!)\\\(list.notes_num!))"
                        thisCell.detailTextLabel?.text = detailString
                    }
                })
                addSeparatorLine(tableView: tableView, cell: thisCell)
                return thisCell
            }
        }
        return cell!
    }
    
    /// Tells the delegate that the specified row is now selected.
    ///
    /// - Parameters:
    ///   - tableView: current table view
    ///   - indexPath: current index path
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        if tableView == groupMemberTV {
            let user = self.users[indexPath.row]
            showChatControllerForUser(user: user)
        }
        if tableView == groupSharingListsTV {
            let list = lists[indexPath.row]
            self.performSegue(withIdentifier: "AccountToNotes", sender: list)
        }
    }
    
    /// Notifies the view controller that a segue is about to be performed.
    ///
    /// - Parameters:
    ///   - segue: current segue
    ///   - sender: sender data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "AccountToNotes" {
            let sLNoteVC = segue.destination as! SharingListNotesTableViewController
            sLNoteVC.fbList = sender as? FbSharingList
            sLNoteVC.curUser = userAndGroup?.curUser
            sLNoteVC.accountVC = self
        }
        if segue.identifier == "GroupToAddNewList" {
            let newListVC = segue.destination as! AddNewListVC
            newListVC.group = sender as? FbGroup
        }
        if segue.identifier == "GroupToLocalLists" {
            let listVC = segue.destination as! SharingListNoteListViewController
            listVC.fbGroup = sender as? FbGroup
        }
        
        
        if segue.identifier == "EditGroup"
        {
            let EditVC=segue.destination as! AddNewGroupViewController
            EditVC.EditMode=true
            EditVC.CurrentGroup=userAndGroup?.selectedGroup
            EditVC.CurrentGroupMember=users
            EditVC.users=(userVC?.users)!
            EditVC.GroupVC=self
        }
    }
    
    /// add separator between each cell
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - cell: cell
    @objc func addSeparatorLine(tableView: UITableView, cell: UITableViewCell) {
        let separatorLineView: UIView = UIView(frame: CGRect(x: 0, y: cell.frame.height - 1, width: tableView.bounds.width, height: 0.5))
        separatorLineView.backgroundColor = tableView.separatorColor
        cell.contentView.addSubview(separatorLineView)
    }
    
    /// section images arr
    @objc let sectionImages: [UIImage] = [#imageLiteral(resourceName: "icons8-Microsoft OneNote-64"), #imageLiteral(resourceName: "icons8-Darth Vader-96"), #imageLiteral(resourceName: "icons8-Bulleted List-64"), #imageLiteral(resourceName: "chat-40"), #imageLiteral(resourceName: "icons8-add-32")]
    
    /// Asks the delegate for a view object to display in the header of the specified section of the table view.
    ///
    /// - Parameters:
    ///   - tableView: current table view
    ///   - section: current section
    /// - Returns: UI view for Header in section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view: UIView?
        if tableView == groupMemberTV {
            view = UIView()
            let image = UIImageView(image: sectionImages[1])
            image.frame = CGRect(x: 4, y: 2, width: 30, height: 30)
            view?.addSubview(image)
            let label = UILabel()
            label.text = "Group: \((userAndGroup?.selectedGroup.name)!)"
            label.frame = CGRect(x: 38, y: 4, width: 300, height: 30)
            label.font = label.font.withSize(20)
            label.font = UIFont(name: "Times New Roman", size: label.font.pointSize)
            view?.addSubview(label)
            view?.backgroundColor = ReminderStandardViewController.GetCurrentBackGroundThemeColor().SubColor ?? UIColor.lightGray
            
            let chatImage = UIImageView(image: sectionImages[3])
            chatImage.frame = CGRect(x: tableView.frame.size.width - 42, y: 2, width: 30, height: 30)
            chatImage.isUserInteractionEnabled = true
            chatImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMessagesController)))
            view?.addSubview(chatImage)
        }
        if tableView == groupSharingListsTV {
            view = UIView()
            let image = UIImageView(image: sectionImages[2])
            image.frame = CGRect(x: 4, y: 2, width: 30, height: 30)
            view?.addSubview(image)
            let label = UILabel()
            label.text = "Group Sharing Lists"
            label.frame = CGRect(x: 38, y: 4, width: 300, height: 30)
            label.font = label.font.withSize(20)
            label.font = UIFont(name: "Times New Roman", size: label.font.pointSize)
            view?.addSubview(label)
            view?.backgroundColor = ReminderStandardViewController.GetCurrentBackGroundThemeColor().SubColor ?? UIColor.lightGray
            
            let AddListImage = UIImageView(image: sectionImages[4])
            AddListImage.frame = CGRect(x: tableView.frame.size.width - 42, y: 2, width: 30, height: 30)
            AddListImage.isUserInteractionEnabled = true
            AddListImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(addNewList)))
            view?.addSubview(AddListImage)
        }
        return view
    }
    
    @objc func addNewList() {
        let sheet = UIAlertController(title: "Add List?", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let photoLib = UIAlertAction(title: "Upload From Local Lists", style: .default) {
            (action: UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "GroupToLocalLists", sender: self.userAndGroup?.selectedGroup)
        }
        let camera = UIAlertAction(title: "Created New List", style: .default) {
            (action: UIAlertAction) -> Void in
            self.performSegue(withIdentifier: "GroupToAddNewList", sender: self.userAndGroup?.selectedGroup)
        }
        sheet.addAction(cancelAction)
        sheet.addAction(photoLib)
        sheet.addAction(camera)
        self.present(sheet, animated: true, completion: nil)
        
    }
    
    /// Asks the delegate for the height to use for the header of a particular section.
    ///
    /// - Parameters:
    ///   - tableView: current table view
    ///   - section: current section
    /// - Returns: height for header in the section
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 34
    }
    
    // MARK: - Swipeable buttons in each cell
    /// Asks the delegate for the actions to display in response to a swipe in the specified row.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    /// - Returns: table view row actions
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let user = users[indexPath.row]
        if tableView == groupMemberTV {
            let clear = UITableViewRowAction(style: .normal, title: "Clear") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
                let curUserRef = DatabaseService.shared.userRef.child((user.uid)!)
                curUserRef.updateChildValues(["notes_done" : 0])
            }
            clear.backgroundColor = UIColor(red:0.84, green:0.45, blue:0.66, alpha:1.0)
            let delete = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
            
                DatabaseService.shared.userMessageRef.child(user.uid!).child((self.userAndGroup?.selectedGroup.gid)!).setValue(nil)
                DatabaseService.shared.groupRef.child((self.userAndGroup?.selectedGroup.gid)!).child("groupMember").child(user.uid!).setValue(nil)
                DatabaseService.shared.userGroupsRef.child(user.uid!).child((self.userAndGroup?.selectedGroup.gid)!).setValue(nil)
                self.users.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
            }
            if userAndGroup?.curUser.uid != userAndGroup?.selectedGroup.host {
                return []
            }
            if userAndGroup?.selectedGroup.host == user.uid {
                return [clear]
            } else {
                return [clear, delete]
            }
        }
        if tableView == groupSharingListsTV {
            let list = lists[indexPath.row]
            let delete = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
                DatabaseService.shared.groupRef.child((self.userAndGroup?.selectedGroup.gid)!).child("groupList").child(list.lid!).setValue(nil)
                self.lists.remove(at: indexPath.row)
                tableView.deleteRows(at: [indexPath], with: .automatic)
            }
            delete.backgroundColor = UIColor(red:0.84, green:0.45, blue:0.66, alpha:1.0)
            
            let download = UITableViewRowAction(style: .normal, title: "Download") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
                // download list first
                let entity = NSEntityDescription.entity(forEntityName: "SharingListNoteList", in: self.manageObjectContext!)!
                let SLobject = SharingListNoteList(entity: entity, insertInto: self.manageObjectContext!)
                SLobject.setValue(list.name, forKey: "name")
                SLobject.setValue(NSDate(), forKey: "created")
                SLobject.setValue(list.lid, forKey: "fbID")
                self.sharingListUsers[0].addToLists(SLobject)
                // download notes then
                let noteRef = DatabaseService.shared.groupRef.child((self.userAndGroup?.selectedGroup.gid)!).child("groupList").child(list.lid!).child("sharingListNote")
                noteRef.observe(.value, with: { (snapshot) in
                    
                    print(snapshot)
                    
                    if snapshot.exists() {
                        guard let notesSnapshot = NotesSnapshot(with: snapshot) else { print("error in notes sanpshot"); return }
                        self.fbnotes = notesSnapshot.notes
                        
                        print(self.fbnotes.count)
                        
                        if self.fbnotes.count != 0 {
                            for note in self.fbnotes {
                                let sharingListNoteEntity = NSEntityDescription.entity(forEntityName: "SharingListNote", in: self.manageObjectContext!)!
                                let sharingListNoteObject = SharingListNote(entity: sharingListNoteEntity, insertInto: self.manageObjectContext!)
                                let timeInterval = TimeInterval(note.created!)
                                let nsDate = NSDate(timeIntervalSince1970: timeInterval)
                                sharingListNoteObject.setValue(nsDate, forKey: "created")
                                sharingListNoteObject.setValue(nil, forKey: "alarm")
                                sharingListNoteObject.setValue(note.done, forKey: "done")
                                sharingListNoteObject.setValue(note.title, forKey: "title")
                                sharingListNoteObject.setValue(note.text, forKey: "text")
                                SLobject.addToNotes(sharingListNoteObject)
                                self.sharingListUsers[0].numofnotes += 1
                            }
                        }
                        self.manageObjectContextSave()
                    }
                })
                self.alertMessage = "Download Successfully"
                self.alert()
            }
            download.backgroundColor = UIColor(red:0.36, green:0.69, blue:0.92, alpha:1.0)

            return [delete, download]
        }
        return []
    }
    
    /// alert message
    @objc var alertMessage: String?
    
    /// alert message
    @objc func alert() {
        let alert = UIAlertController(title: alertMessage, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    
    /// firebase notes data
    var fbnotes = [FbSharingListNote]()
    
    /// core data users
    @objc var sharingListUsers: [SharingListUser]!
    
    /// manage object context
    @objc var manageObjectContext: NSManagedObjectContext? {
        return (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
    }
    
    /// try save current update to core data
    @objc func manageObjectContextSave() {
        do {
            try self.manageObjectContext?.save()
        } catch let error {
            print("Could not save SharingListNote to CoreData: \(error.localizedDescription)")
        }
    }
    
    /// set up user name and user image on navigation bar
    ///
    /// - Parameter user: current user data
    func setupNavBarWithUser(user: FbUser) {
        let titleView = UIView()
        titleView.frame = CGRect(x: 0, y: 0, width: 100, height: 40)
        
        let containerView = UIView()
        containerView.translatesAutoresizingMaskIntoConstraints = false
        titleView.addSubview(containerView)
        
        let profileImageView = UIImageView()
        profileImageView.translatesAutoresizingMaskIntoConstraints = false
        profileImageView.contentMode = .scaleAspectFit
        profileImageView.layer.cornerRadius = 20
        profileImageView.clipsToBounds = true
        if let profileImageURL = user.profileImageURL {
            profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageURL)
        }
        
        containerView.addSubview(profileImageView)
        profileImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
        
        
        let nameLabel = UILabel()
        containerView.addSubview(nameLabel)
        nameLabel.text = user.name
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8).isActive = true
        nameLabel.centerYAnchor.constraint(equalTo: profileImageView.centerYAnchor).isActive = true
        nameLabel.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
        nameLabel.heightAnchor.constraint(equalTo: profileImageView.heightAnchor).isActive = true
        
        containerView.centerXAnchor.constraint(equalTo: titleView.centerXAnchor).isActive = true
        containerView.centerYAnchor.constraint(equalTo: titleView.centerYAnchor).isActive = true
        self.navigationItem.titleView = titleView

        
    }
    
    
    /// navigate to profile editor view
    @objc func showProfileEditor() {
        performSegue(withIdentifier: "profileEditor", sender: nil)
    }
    
    
    
}




/// cell used to display users
class UserCell: UITableViewCell {
    
    /// Lays out subviews.
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 40, y: (textLabel?.frame.origin.y)!, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 40, y: (detailTextLabel?.frame.origin.y)!, width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
    }
    
    /// user image view
    @objc let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "White_Scarf_Tattoo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    @objc let statusImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "White_Scarf_Tattoo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 2
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    
    /// Initializes a table cell with a style and a reuse identifier and returns it to the caller.
    ///
    /// - Parameters:
    ///   - style: cell style
    ///   - reuseIdentifier: reuse id
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(statusImageView)
        // ios constraint anchors
        // need x, y, width, height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 30).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        // xywh
        statusImageView.leftAnchor.constraint(equalTo: (self.textLabel?.rightAnchor)!, constant: 4).isActive = true
        statusImageView.centerYAnchor.constraint(equalTo: (self.textLabel?.centerYAnchor)!).isActive = true
        statusImageView.widthAnchor.constraint(equalToConstant: 12).isActive = true
        statusImageView.heightAnchor.constraint(equalToConstant: 12).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}

/// cell used to display lists
class ListCell: UITableViewCell {
    
    /// Lays out subviews.
    override func layoutSubviews() {
        super.layoutSubviews()
    }
    
    
    /// Initializes a table cell with a style and a reuse identifier and returns it to the caller.
    ///
    /// - Parameters:
    ///   - style: cell style
    ///   - reuseIdentifier: reuse id
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}





