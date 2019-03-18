//
//  UserViewController.swift
//  Reminder
//
//  Created by Yijia Huang on 12/2/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//


import UIKit
import Firebase
import CoreData


/// User account view controller
class UserViewController: ReminderStandardViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    // MARK: - Variables
    /// group member table view
    @IBOutlet weak var userTV: UITableView!
    
    /// group sharing list table view
    @IBOutlet weak var groupTV: UITableView!
    
    /// user cell id
    @objc let userCellId = "usercellId"
    
    /// list cell id
    @objc let groupCellId = "gcellId"
    
    /// current user firebase data
    var curUser: FbUser?
    
    /// users firebase data
    var users = [FbUser]()
    
    var groups = [FbGroup]()
    
    /// messages firebase data
    var messages = [FbMessage]()
    
    
    // MARK: - Methods
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        initialVar()
        initialUI()
        updateUI()
        CheckLogin()
    }
    
    func CheckLogin()
    {
        let currentUserID=Auth.auth().currentUser?.uid
        if(currentUserID==nil)
        {
            handleLogout()
        }
    }
    
    var LoginReturned:Bool=false
    
    /// Notifies the view controller that its view is about to be added to a view hierarchy.
    ///
    /// - Parameter animated: animated bool
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        self.tabBarController?.tabBar.isHidden = false
        if(!LoginReturned)
        {
            CheckLogin()
        }else{
            LoginReturned=false
        }
    }
    
    /// update UI according to login status
    @objc func updateUI() {
        // user is not logged in
        if Auth.auth().currentUser?.uid == nil {
            cleanNaviBar()
        } else {
            self.navigationItem.rightBarButtonItem?.title = "Logout"
            
            let uid = Auth.auth().currentUser?.uid
            DatabaseService.shared.userRef.child(uid!).observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    self.curUser = FbUser(uid: uid!, dict: dictionary)
                    self.setupNavBarWithUser(user: self.curUser!)
                }
            }, withCancel: nil)
            DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1/100), execute: {
                self.fetchUsersAndGroups()
            })
        }
    }
    
    /// cleadn navigation controller bar if user logout
    @objc func cleanNaviBar() {
        self.navigationItem.rightBarButtonItem?.title = "Login"
        self.navigationItem.title = ""
        self.navigationItem.titleView?.subviews[0].removeFromSuperview()
        if self.navigationItem.rightBarButtonItems?.count == 2 {
            self.navigationItem.rightBarButtonItems?.remove(at: 1)
        }
        self.users.removeAll()
        self.groups.removeAll()
        self.userTV.reloadData()
        self.groupTV.reloadData()
    }
    
    /// diplay message cell on the table view
    @objc func showMessagesController() {
        if curUser != nil {
            let messagesController = MessagesController()
            messagesController.curUser = self.curUser
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
        userTV.delegate = self
        userTV.dataSource = self
        userTV.register(UserCell.self, forCellReuseIdentifier: userCellId)
        groupTV.delegate = self
        groupTV.dataSource = self
        groupTV.register(ListCell.self, forCellReuseIdentifier: groupCellId)
        
        let fetchRequest: NSFetchRequest<SharingListUser> = SharingListUser.fetchRequest()
        do {
            sharingListUsers = try manageObjectContext!.fetch(fetchRequest)
        } catch let error {
            print("Could not fetch users from CoreData:\(error.localizedDescription)")
        }
    }
    
    /// initial UI
    @objc func initialUI() {
        userTV.backgroundColor = UIColor.clear
        userTV.separatorStyle = UITableViewCellSeparatorStyle.none
        groupTV.backgroundColor = UIColor.clear
        groupTV.separatorStyle = UITableViewCellSeparatorStyle.none
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Login", style: .plain, target: self, action: #selector(handleLogout))
    }
    
    
    /// fetch users data and sharing lists data
    @objc func fetchUsersAndGroups() {
        // get users
        DatabaseService.shared.userRef.observe(.value,  with: { (snapshot) in
            if snapshot.exists() {
                guard let usersSnapshot = UsersSnapshot(with: snapshot) else { return }
                self.users = usersSnapshot.users
                self.users.sort(by: { $0.created?.compare($1.created!) == .orderedDescending })
                DatabaseService.shared.userRef.child(Auth.auth().currentUser!.uid).observeSingleEvent(of: .value, with: { (snapshot) in
                    if snapshot.exists() {}
                    else {
                        self.handleLogout()
                    }
                }, withCancel: nil)
                
                guard let snapshotDict = snapshot.value as? [String : [String : Any]] else { return }
                self.curUser = FbUser(uid: (Auth.auth().currentUser?.uid)!, dict: snapshotDict[(Auth.auth().currentUser?.uid)!]!)
                self.userTV.reloadData()
            } else {
                self.users.removeAll()
                if self.userTV.numberOfRows(inSection: 0) == 1 {
                    self.userTV.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                } else {
                    self.userTV.reloadData()
                }
            }
        }, withCancel: nil)
        // get groups
        if curUser?.status != "Administrator" {
            DatabaseService.shared.userGroupsRef.child((Auth.auth().currentUser?.uid)!).observe(.value, with: { (snapshot) in
                if snapshot.exists() {
                    let userGroupAddresses = (UserGroupSnapshot(with: snapshot))?.gAddresses
                    DatabaseService.shared.groupRef.observe(DataEventType.value, with: { (snapshot) in
                        let groupSnapShot = GroupSnapshot(with: snapshot, addresses: userGroupAddresses!)
                        if let groups = groupSnapShot?.groups {
                            self.groups = groups
                            self.groupTV.reloadData()
                        }
                    })
                } else {
                    self.groups.removeAll()
                    if self.groupTV.numberOfRows(inSection: 0) == 1 {
                        self.groupTV.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    } else {
                        self.groupTV.reloadData()
                    }
                }
            }, withCancel: nil)
        } else {
            DatabaseService.shared.groupRef.observe(DataEventType.value, with: { (snapshot) in
                if snapshot.exists() {
                    guard let groupsSnapDict = snapshot.value as? [String : [String : Any]] else { return }
                    var groups = [FbGroup]()
                    for dict in groupsSnapDict {
                        let group = FbGroup(dict: dict.value)
                        groups.append(group!)
                    }
                    self.groups = groups
                    self.groupTV.reloadData()
                } else {
                    self.groups.removeAll()
                    if self.groupTV.numberOfRows(inSection: 0) == 1 {
                        self.groupTV.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                    } else {
                        self.groupTV.reloadData()
                    }
                }
            })
        }
    }
    
    
    
    /// hande login/logoour button
    @objc func handleLogout() {
        if isLogin() {
            self.cleanNaviBar()
            do {
                print("signout successfully")
                try Auth.auth().signOut()
            } catch let logoutError {
                print(logoutError)
            }
        }
        let loginController = LoginViewController()
        loginController.userVC = self
        present(loginController, animated: true, completion: nil)
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
        if tableView == userTV {
            count = users.count
        }
        if tableView == groupTV {
            count = groups.count
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
            cell?.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        } else {
            if tableView == userTV {
                let  thisCell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! UserCell
                thisCell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
                let user = users[indexPath.row]
                
                thisCell.textLabel?.text = user.name
                if user.status == "Administrator" {
                    thisCell.statusImageView.image = #imageLiteral(resourceName: "icons8-crown-24")
                }
                
                thisCell.detailTextLabel?.text = "\(user.email!)"
                
                if let profileImageURL = user.profileImageURL {
                    thisCell.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageURL)
                }
                addSeparatorLine(tableView: tableView, cell: thisCell)
                return thisCell
            }
            if tableView == groupTV {
                let thisCell = tableView.dequeueReusableCell(withIdentifier: groupCellId, for: indexPath) as! ListCell
                thisCell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
                let group = groups[indexPath.row]
                thisCell.textLabel?.text = group.name
                DatabaseService.shared.userRef.child(group.host!).observeSingleEvent(of: .value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: Any] {
                        let detailString = "host: \(dictionary["name"]!)"
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
        if tableView == userTV {
            let user = self.users[indexPath.row]
            showChatControllerForUser(user: user)
        }
        if tableView == groupTV {
            let group = groups[indexPath.row]
            self.performSegue(withIdentifier: "UserToGroup", sender: (curUser, group))
        }
    }
    
    /// Notifies the view controller that a segue is about to be performed.
    ///
    /// - Parameters:
    ///   - segue: current segue
    ///   - sender: sender data
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "UserToGroup" {
            let groupVC = segue.destination as! GroupViewController
            groupVC.userAndGroup = sender as? (curUser: FbUser, selectedGroup: FbGroup)
            groupVC.userVC = self
        }
        if segue.identifier == "profileEditor" {
            let profileVC = segue.destination as! ProfileTableViewController
            profileVC.userVC = self
        }
        if segue.identifier == "CreateNewGroup" {
            let addNewGroupVC = segue.destination as! AddNewGroupViewController
            addNewGroupVC.users = users
            addNewGroupVC.userVC = self
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
    @objc let sectionImages: [UIImage] = [#imageLiteral(resourceName: "icons8-Microsoft OneNote-64"), #imageLiteral(resourceName: "icons8-Darth Vader-96"), #imageLiteral(resourceName: "icons8-Bulleted List-64"), #imageLiteral(resourceName: "chat-40"), #imageLiteral(resourceName: "icons8-add-32"), #imageLiteral(resourceName: "icons8-user-groups-40")]
    
    /// Asks the delegate for a view object to display in the header of the specified section of the table view.
    ///
    /// - Parameters:
    ///   - tableView: current table view
    ///   - section: current section
    /// - Returns: UI view for Header in section
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        var view: UIView?
        if tableView == userTV {
            view = UIView()
            let image = UIImageView(image: sectionImages[1])
            image.frame = CGRect(x: 4, y: 2, width: 30, height: 30)
            view?.addSubview(image)
            let label = UILabel()
            label.text = "Users"
            label.frame = CGRect(x: 38, y: 4, width: 300, height: 30)
            label.font = label.font.withSize(20)
            label.font = UIFont(name: "Times New Roman", size: label.font.pointSize)
            view?.addSubview(label)
            view?.backgroundColor = ReminderStandardViewController.GetCurrentBackGroundThemeColor().SubColor ?? UIColor.lightGray
            
            let groupChatImage = UIImageView(image: sectionImages[3])
            groupChatImage.frame = CGRect(x: tableView.frame.size.width - 42, y: 2, width: 30, height: 30)
            groupChatImage.isUserInteractionEnabled = true
            groupChatImage.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showMessagesController)))
            view?.addSubview(groupChatImage)
        }
        if tableView == groupTV {
            view = UIView()
            let image = UIImageView(image: sectionImages[5])
            image.frame = CGRect(x: 4, y: 2, width: 30, height: 30)
            view?.addSubview(image)
            let label = UILabel()
            label.text = curUser?.status != "Adminstrator" ? "My Groups" : "All Groups"
            label.frame = CGRect(x: 38, y: 4, width: 300, height: 30)
            label.font = label.font.withSize(20)
            label.font = UIFont(name: "Times New Roman", size: label.font.pointSize)
            view?.addSubview(label)
            view?.backgroundColor = ReminderStandardViewController.GetCurrentBackGroundThemeColor().SubColor ?? UIColor.lightGray
            
            let createNewGroupBut = UIImageView(image: sectionImages[4])
            createNewGroupBut.frame = CGRect(x: tableView.frame.size.width - 42, y: 2, width: 30, height: 30)
            createNewGroupBut.isUserInteractionEnabled = true
            createNewGroupBut.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showAddNewGroupController)))
            view?.addSubview(createNewGroupBut)
        }
        return view
    }
    
    @objc func showAddNewGroupController() {
        if curUser != nil {
            if curUser?.status != "regular" {
            performSegue(withIdentifier: "CreateNewGroup", sender: curUser)
            } else {
                alertMessage = "Please Upgrade Your Account"
                alert()
            }
        }
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
    
    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        if(tableView == userTV && indexPath.row < users.count)
        {
            let UserForCellAt=users[indexPath.row]
            if(UserForCellAt.uid==curUser?.uid || UserForCellAt.status! == "Administrator" || curUser?.status! != "Administrator")
            {
                return []
            }
            var AdjustTitle="Demote"
            if(UserForCellAt.status! != "VIP")
            {
                AdjustTitle="Upgrade"
            }
            let AdjustPriorityAction=UITableViewRowAction(style: .normal, title: AdjustTitle, handler: AdjustPriority)
            
            return [AdjustPriorityAction]
            

        }
        return []
    }
    
    func AdjustPriority(_ Action:UITableViewRowAction,row:IndexPath)->Void
    {
        let User=DatabaseService.shared.userRef.child(users[row.row].uid!)
        
        
        if(Action.title=="Demote")
        {
            User.updateChildValues(["status":"regular"])
        }else{
            User.updateChildValues(["status":"VIP"])
        }
        
        
        
    }
    
    
    // MARK: - Swipeable buttons in each cell
    /// Asks the delegate for the actions to display in response to a swipe in the specified row.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    /// - Returns: table view row actions
//    func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
//        var buttons: [UITableViewRowAction]?
//        if tableView == userTV {
//            let clear = UITableViewRowAction(style: .normal, title: "Clear") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
//                let curUserRef = DatabaseService.shared.userRef.child((Auth.auth().currentUser?.uid)!)
//                curUserRef.updateChildValues(["notes_done" : 0])
//            }
//            clear.backgroundColor = UIColor(red:0.84, green:0.45, blue:0.66, alpha:1.0)
//            let delete = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
//                let user = self.users[indexPath.row]
//                DatabaseService.shared.userRef.child(user.uid!).setValue(nil)
//                DatabaseService.shared.groupRef.child("group1").child("groupMembers").child(user.uid!).setValue(nil)
//                self.users.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: UITableViewRowAnimation.automatic)
//            }
//            buttons = [clear]
//            if curUser?.status == "Administrator" && self.users[indexPath.row].uid != self.curUser?.uid {
//                buttons = [clear, delete]
//            }
//        }
//        if tableView == groupTV {
//            let group = groups[indexPath.row]
//
//
//            let delete = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
//                DatabaseService.shared.sharingListRef.child(list.list_id!).setValue(nil)
//                self.groups.remove(at: indexPath.row)
//                tableView.deleteRows(at: [indexPath], with: .automatic)
//            }
//            delete.backgroundColor = UIColor(red:0.84, green:0.45, blue:0.66, alpha:1.0)
//
//
//            let edit = UITableViewRowAction(style: .normal, title: "More") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
//                let sheet = UIAlertController(title: "More Options", message: "wanna more settings?", preferredStyle: .actionSheet)
//                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
//                let editAction = UIAlertAction(title: "Edit List name", style: .default) {
//                    (action: UIAlertAction) -> Void in
//                }
//                sheet.addAction(cancelAction)
//                sheet.addAction(editAction)
//                self.present(sheet, animated: true, completion: nil)
//            }
//            edit.backgroundColor = UIColor(red:0.40, green:0.88, blue:0.68, alpha:1.0)
//
//            let download = UITableViewRowAction(style: .normal, title: "Download") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
//                // download list first
//                let entity = NSEntityDescription.entity(forEntityName: "SharingListNoteList", in: self.manageObjectContext!)!
//                let SLobject = SharingListNoteList(entity: entity, insertInto: self.manageObjectContext!)
//                SLobject.setValue(list.listname, forKey: "name")
//                SLobject.setValue(NSDate(), forKey: "created")
//                SLobject.setValue(list.list_id, forKey: "fbID")
//                self.sharingListUsers[0].addToLists(SLobject)
//                // download notes then
//                let noteRef = DatabaseService.shared.sharingListRef.child(list.list_id!).child("sharingListNote")
//                noteRef.observe(.value, with: { (snapshot) in
//                    if snapshot.exists() {
//                        guard let notesSnapshot = NotesSnapshot(with: snapshot) else { print("error in notes sanpshot"); return }
//                        self.fbnotes = notesSnapshot.notes
//                        if self.fbnotes.count != 0 {
//                            for note in self.fbnotes {
//                                let sharingListNoteEntity = NSEntityDescription.entity(forEntityName: "SharingListNote", in: self.manageObjectContext!)!
//                                let sharingListNoteObject = SharingListNote(entity: sharingListNoteEntity, insertInto: self.manageObjectContext!)
//                                let timeInterval = TimeInterval(note.created!)
//                                let nsDate = NSDate(timeIntervalSince1970: timeInterval)
//                                sharingListNoteObject.setValue(nsDate, forKey: "created")
//                                sharingListNoteObject.setValue(nil, forKey: "alarm")
//                                sharingListNoteObject.setValue(note.done, forKey: "done")
//                                sharingListNoteObject.setValue(note.title, forKey: "title")
//                                sharingListNoteObject.setValue(note.text, forKey: "text")
//                                SLobject.addToNotes(sharingListNoteObject)
//                                self.sharingListUsers[0].numofnotes += 1
//                            }
//                        }
//                        self.manageObjectContextSave()
//                    }
//                })
//                self.alertMessage = "Download Successfully"
//                self.alert()
//            }
//            download.backgroundColor = UIColor(red:0.36, green:0.69, blue:0.92, alpha:1.0)
//            buttons = [delete, edit, download]
//        }
//        return buttons
//    }
    
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

