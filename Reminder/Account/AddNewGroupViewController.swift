//
//  NewGroupViewController.swift
//  Reminder
//
//  Created by Jason on 2017/12/2.
//  Copyright © 2017年 Yijia Huang. All rights reserved.
//

import UIKit
import Firebase

class AddNewGroupViewController: ReminderStandardViewController, UITableViewDelegate, UITableViewDataSource, UIGestureRecognizerDelegate {
    
    

    
    let MemberSelectionTableViewController=SelectionTableViewController()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        initialVarUI()
        
        if(EditMode)
        {
            EditModeSetUp()
        }
        // Do any additional setup after loading the view.
    }
    
    
    var EditMode:Bool=false
    
    var CurrentGroup:FbGroup?
    
    var CurrentGroupMember:[FbUser]?
    
    
    
    func EditModeSetUp(){
        if CurrentGroupMember?.count != 0
        {
            selectedUsers=CurrentGroupMember!
        }
        GroupName.text=CurrentGroup?.name
    }
    
    
    var GroupVC:GroupViewController?
    
    @IBOutlet weak var GroupName: UITextField!
    
    @IBOutlet weak var MemberSelection: UITableView!
    
    var users = [FbUser]()
    
    var userVC: UserViewController?
    
    var selectedUsers = [FbUser]()
    
    @objc let userCellId = "usercellId"
    
    @objc func initialVarUI() {
        initialUsersArray()
        GroupName.text = ""
        GroupName.placeholder = "Name"
        MemberSelection.delegate = self
        MemberSelection.dataSource = self
        MemberSelection.register(UserCell.self, forCellReuseIdentifier: userCellId)
        MemberSelection.backgroundColor = UIColor.clear
        MemberSelection.separatorStyle = UITableViewCellSeparatorStyle.none
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(save))
    }
    
    func initialUsersArray() {
        var idx = 0
        for user in users {
            if user.uid == Auth.auth().currentUser?.uid {
                users.remove(at: idx)
                return
            }
            idx += 1
        }
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return users.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let  thisCell = tableView.dequeueReusableCell(withIdentifier: userCellId, for: indexPath) as! UserCell
        thisCell.backgroundColor = UIColor(red: 1, green: 1, blue: 1, alpha: 0)
        let user = users[indexPath.row]
        thisCell.textLabel?.text = user.name
        thisCell.detailTextLabel?.text = "\(user.email!)"
        if let profileImageURL = user.profileImageURL {
            thisCell.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageURL)
        }
        addSeparatorLine(tableView: tableView, cell: thisCell)
        
        if(EditMode && CurrentGroupMember?.count != 0)
        {
            for member in CurrentGroupMember!
            {
                if(member.uid == user.uid)
                {
                    thisCell.accessoryType = .checkmark
                    break
                }
            }
        }
        return thisCell
    }
    
    @objc func addSeparatorLine(tableView: UITableView, cell: UITableViewCell) {
        let separatorLineView: UIView = UIView(frame: CGRect(x: 0, y: cell.frame.height - 1, width: tableView.bounds.width, height: 0.5))
        separatorLineView.backgroundColor = tableView.separatorColor
        cell.contentView.addSubview(separatorLineView)
    }
    
    @objc let sectionImages: [UIImage] = [#imageLiteral(resourceName: "icons8-Darth Vader-96")]
    
    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let view = UIView()
        let image = UIImageView(image: sectionImages[0])
        image.frame = CGRect(x: 4, y: 2, width: 30, height: 30)
        view.addSubview(image)
        let label = UILabel()
        label.text = "Users"
        label.frame = CGRect(x: 38, y: 4, width: 300, height: 30)
        label.font = label.font.withSize(20)
        label.font = UIFont(name: "Times New Roman", size: label.font.pointSize)
        view.addSubview(label)
        view.backgroundColor = UIColor(red:0.65, green:0.89, blue:0.78, alpha:1.0)
        return view
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: false)
        let cell = tableView.cellForRow(at: indexPath)
        if cell?.accessoryType == UITableViewCellAccessoryType.none {
            cell?.accessoryType = .checkmark
            selectedUsers.append(users[indexPath.row])
            print(selectedUsers.count)
        } else {
            cell?.accessoryType = .none
            removeUserFromSelectedArray(uid: users[indexPath.row].uid)
            print(selectedUsers.count)
        }
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
    
    func removeUserFromSelectedArray(uid: String?) {
        var idx = 0
        for user in selectedUsers {
            if user.uid == uid {
                selectedUsers.remove(at: idx)
                return
            }
            idx += 1
        }
    }
    
    @objc func save() {
        if GroupName.text == nil || GroupName.text == "" {
            alert(msg: "Please enter a group name")
        } else if selectedUsers.count == 0 {
            alert(msg: "Please add someone")
        }else if (EditMode)
        {
            EditSave()
            
        }else {
            let curUid = Auth.auth().currentUser?.uid
            let groupRef = DatabaseService.shared.groupRef.childByAutoId()
            let gid = groupRef.key
            
            let gDict = [
                "host" : curUid!,
                "name" : GroupName.text!,
                "created" : Int64(NSDate().timeIntervalSince1970 * 1000.0),
                "gid" : gid,
                "numOfAllMembers" : selectedUsers.count + 1
                ] as [String : Any]
            groupRef.setValue(gDict)
            groupRef.child("groupMember").updateChildValues([curUid! : Int64(NSDate().timeIntervalSince1970 * 1000.0)])
            for user in selectedUsers {
                DatabaseService.shared.userGroupsRef.child(user.uid!).updateChildValues([gid : Int64(NSDate().timeIntervalSince1970 * 1000.0)])
                groupRef.child("groupMember").updateChildValues([user.uid! : Int64(NSDate().timeIntervalSince1970 * 1000.0)])
            }
            DatabaseService.shared.userGroupsRef.child(curUid!).updateChildValues([gid : Int64(NSDate().timeIntervalSince1970 * 1000.0)])
            userVC?.updateUI()
            navigationController?.popViewController(animated: true)
        }
    }
    
    func EditSave(){
        
        let groupRef = DatabaseService.shared.groupRef.child((CurrentGroup?.gid!)!)
        
        groupRef.updateChildValues([
            "name" : GroupName.text!,
            "numOfAllMembers" : selectedUsers.count + 1
            ] as [String : Any])
        
        
        groupRef.child("groupMember").setValue(nil)
        
        groupRef.child("groupMember").updateChildValues([(Auth.auth().currentUser?.uid)! : Int64(NSDate().timeIntervalSince1970 * 1000.0)])
        for user in selectedUsers {
            DatabaseService.shared.userGroupsRef.child(user.uid!).updateChildValues([groupRef.key : Int64(NSDate().timeIntervalSince1970 * 1000.0)])
            groupRef.child("groupMember").updateChildValues([user.uid! : Int64(NSDate().timeIntervalSince1970 * 1000.0)])
        }
        DatabaseService.shared.userGroupsRef.child((Auth.auth().currentUser?.uid)!).updateChildValues([groupRef.key: Int64(NSDate().timeIntervalSince1970 * 1000.0)])
        
        userVC?.updateUI()
        
        navigationController?.popViewController(animated: true)
        
        
    }
    
    
    func alert(msg: String) {
        let alert = UIAlertController(title: msg, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
}































