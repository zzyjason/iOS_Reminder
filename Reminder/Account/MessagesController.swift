//
//  MessagesController.swift
//  Reminder
//
//  Created by Yijia Huang on 10/13/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//

import UIKit
import Firebase

/// messages controller
class MessagesController: ReminderStandardTableViewController {
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        initUIandVar()
        ObserveUserMessages()
    }
    
    /// back to last view
    @objc func handleCancel() {
        self.navigationController?.popViewController(animated: true)
    }
    
    /// cell id
    let cellId = "cellId"
    
    /// current logined user
    var curUser: FbUser? {
        didSet {
            navigationItem.title = curUser?.name
        }
    }
    
    var curGroup: FbGroup?
    
    /// char partners
    var users = [FbUser]()
    
    /// user messages
    var userMessages = [FbMessage]()
    
    /// user message's address
    var userMessageAddress = [ToUserMessageAddress]()
    
    /// initilize UI and variables
    func initUIandVar() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        self.tableView.register(UserMessageCell.self, forCellReuseIdentifier: cellId)
        self.tableView.separatorStyle = UITableViewCellSeparatorStyle.none
        if curGroup != nil && curUser?.status != "regular" {
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Group Chat", style: .plain, target: self, action: #selector(showGroupChatView))
        }
    }
    
    /// show group chat view
    @objc func showGroupChatView() {
            let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
            chatLogController.curGroup = curGroup
            navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    @objc func showGroupChatViewWith(gid: String?, name: String?) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.curGroup = FbGroup(gid: gid, name: name)
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    /// Tells the data source to return the number of rows in a given section of a table view.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - section: section
    /// - Returns: number of rows in the section
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return userMessages.count;
    }
    
    /// Asks the delegate for the height to use for a row in a specified location.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    /// - Returns: height of row
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 72
    }
    
    /// Tells the delegate that the specified row is now selected.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        let message = userMessages[indexPath.row]
        
        guard let chatPartnerId = message.chatPartnerId() else {
            return
        }
        if message.groupName == nil {
            let partnerRef = DatabaseService.shared.userRef.child(chatPartnerId)
            partnerRef.observeSingleEvent(of: .value) { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    let parnter = FbUser(uid: chatPartnerId, dict: dictionary)
                    self.showChatControllerForUser(user: parnter!)
                }
            }
        } else {
            showGroupChatViewWith(gid: message.toId, name: message.groupName)
        }
    }
    
    /// show chat controller with chat partner
    ///
    /// - Parameter user: chat partner
    func showChatControllerForUser(user: FbUser) {
        let chatLogController = ChatLogController(collectionViewLayout: UICollectionViewFlowLayout())
        chatLogController.chatPartner = user
        navigationController?.pushViewController(chatLogController, animated: true)
    }
    
    /// Asks the data source for a cell to insert in a particular location of the table view.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    /// - Returns: view cell
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: cellId, for: indexPath) as! UserMessageCell
        cell.backgroundColor = UIColor.clear
        let message = userMessages[indexPath.row]
        
        var msg: String?
        msg = message.text != nil ? message.text : "[image]"
        if message.groupName == nil {
            let uId = message.chatPartnerId()
            let ref = DatabaseService.shared.userRef.child(uId!)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    cell.textLabel?.text = dictionary["name"] as? String
                    
                    if let profileimageUrl = dictionary["profileImageURL"] as? String {
                        cell.profileImageView.loadImageUsingCacheWithURLString(urlString: profileimageUrl)
                    }
                }
            })
            cell.detailTextLabel?.text = msg
        } else {
            cell.textLabel?.text = "Group: \(message.groupName!)"
            cell.profileImageView.image = #imageLiteral(resourceName: "icons8-Darth Vader-96")
            let ref = DatabaseService.shared.userRef.child(message.fromId!)
            ref.observeSingleEvent(of: .value, with: { (snapshot) in
                if let dictionary = snapshot.value as? [String: Any] {
                    let userName = dictionary["name"] as? String
                    cell.detailTextLabel?.text = message.fromId == Auth.auth().currentUser?.uid ? msg : "\(userName ?? ""): \(msg ?? "")"
                }
            })
        }
        
        let secounds = TimeInterval((Double(message.timestamp!) / 1000.0))
        let timestampDate = NSDate(timeIntervalSince1970: secounds)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "hh:mm:ss a"
        cell.timeLabel.text = dateFormatter.string(from: timestampDate as Date)
        addSeparatorLine(tableView: tableView, cell: cell)
        return cell
    }
    
    /// Asks the delegate for the actions to display in response to a swipe in the specified row.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    /// - Returns: row actions
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let delete = UITableViewRowAction(style: .normal, title: "Delete") { (rowAction: UITableViewRowAction, indexPath: IndexPath) -> Void in
            let message = self.userMessages[indexPath.row]
            DatabaseService.shared.userMessageRef.child((self.curUser?.uid!)!).child(message.chatPartnerId()!).setValue(nil)
            self.userMessages.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
        }
        delete.backgroundColor = UIColor(red:0.84, green:0.45, blue:0.66, alpha:1.0)
        return [delete]
    }
    
    /// add Separator Line
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - cell: cel
    @objc func addSeparatorLine(tableView: UITableView, cell: UITableViewCell) {
        let separatorLineView: UIView = UIView(frame: CGRect(x: 60, y: cell.frame.height - 1, width: tableView.bounds.width, height: 0.5))
        separatorLineView.backgroundColor = tableView.separatorColor
        cell.contentView.addSubview(separatorLineView)
    }
    
    /// show user messages
    func ObserveUserMessages() {
        print("observe")
        DatabaseService.shared.userMessageRef.child((curUser?.uid!)!).observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                guard let userMessagesSnapshot = UserMessageSnapshot(with: snapshot) else { return }
                self.userMessageAddress = userMessagesSnapshot.userMessageAddress
                DatabaseService.shared.messageRef.observe(.value, with: { (snapshot) in
                    guard let userMsgs = MessageSnapshot(with: snapshot, at: self.userMessageAddress) else { return }
                    self.userMessages = userMsgs.userMsgs
                    self.userMessages.sort(by: { (m1, m2) -> Bool in
                        return m1.timestamp! > m2.timestamp!
                    })
                    self.tableView.reloadData()
                }, withCancel: nil)
            } else {
                self.userMessages.removeAll()
                if self.tableView.numberOfRows(inSection: 0) == 1 {
                    self.tableView.deleteRows(at: [IndexPath(row: 0, section: 0)], with: .automatic)
                } else {
                    self.tableView.reloadData()
                }
            }
        }, withCancel: nil)
    }
    
}


/// message cell
class UserMessageCell: UITableViewCell {
    
    // MARK: - Variables
    /// profile image view
    @objc let profileImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage(named: "White_Scarf_Tattoo")
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.layer.cornerRadius = 24
        imageView.layer.masksToBounds = true
        imageView.contentMode = .scaleAspectFill
        return imageView
    }()
    
    /// time label
    @objc let timeLabel: UILabel = {
        let label = UILabel()
        label.text = "HH: MM: SS"
        label.font = UIFont.systemFont(ofSize: 13)
        label.textColor = UIColor.darkGray
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Methods
    /// layout subviews
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = CGRect(x: 64, y: (textLabel?.frame.origin.y)! - 2, width: (textLabel?.frame.width)!, height: (textLabel?.frame.height)!)
        detailTextLabel?.frame = CGRect(x: 64, y: (detailTextLabel?.frame.origin.y)! + 2, width: (detailTextLabel?.frame.width)!, height: (detailTextLabel?.frame.height)!)
    }
    
    /// Initializes a table cell with a style and a reuse identifier and returns it to the caller.
    ///
    /// - Parameters:
    ///   - style: cell style
    ///   - reuseIdentifier: reuse id
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .subtitle, reuseIdentifier: reuseIdentifier)
        addSubview(profileImageView)
        addSubview(timeLabel)
        
        // ios constraint anchors
        // need x, y, width, height anchors
        profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
        profileImageView.centerYAnchor.constraint(equalTo: self.centerYAnchor).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 44).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 44).isActive = true
        
        //x,y, jfkdls
        timeLabel.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
        timeLabel.topAnchor.constraint(equalTo: self.topAnchor, constant: 18).isActive = true
        timeLabel.widthAnchor.constraint(equalToConstant: 100).isActive = true
        timeLabel.heightAnchor.constraint(equalTo: (textLabel?.heightAnchor)!).isActive = true
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
