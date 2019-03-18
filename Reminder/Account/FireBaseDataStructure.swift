//
//  User.swift
//  Reminder
//
//  Created by Yijia Huang on 10/7/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//
import Foundation
import UIKit
import Firebase

/// convert firebase user data structure to local user data structure
class FbUser {
    
    // MARK: - Variables
    var userId: String?
    var name: String?
    var email: String?
    var created: String?
    var profileImageURL: String?
    var notes_done: Int?
    var status: String?
    var uid: String?
    
    // MARK: - Methods
    init?(uid: String, dict: [String : Any]) {
        
        self.userId = uid
        
        guard let name = dict["name"] as? String, let email = dict["email"] as? String, let created = dict["created"] as? String, let profileImageURL = dict["profileImageURL"] as? String, let notes_done = dict["notes_done"] as? Int else {return nil}
        
        self.name = name
        self.email = email
        self.created = created
        self.profileImageURL = profileImageURL
        self.notes_done = notes_done
        self.status = dict["status"] as? String
        self.uid = dict["uid"] as? String
    }
}

/// user sanpshot
class UsersSnapshot {
    // MARK: - Variables
    let users: [FbUser]
    // MARK: - Methods
    init?(with snapshot: DataSnapshot) {
        var users = [FbUser]()
        
        guard let snapDict = snapshot.value as? [String: [String: Any]] else {
            return nil
        }
        for snap in snapDict {
            guard let user = FbUser(uid: snap.key, dict: snap.value) else {
                continue
            }
            users.append(user)
        }
        self.users = users
    }
    
}

/// convert firebase sharing list data structure to local data structure
class FbSharingList {
    // MARK: - Variables
    var gid: String?
    var lid: String?
    var name: String?
    var uploaded_date: Int64?
    var uploaded_by_uid: String?
    var notes_num: Int?
    var notes_done: Int?
    // MARK: - Methods
    init?(listId: String, dict: [String : Any]) {
        
        self.lid = listId
        
        guard let name = dict["name"] as? String, let uploaded_date = dict["uploaded_date"] as? Int64, let uploaded_by_uid = dict["uploaded_by_uid"] as? String, let notes_done = dict["notes_done"] as? Int, let notes_num = dict["notes_num"] as? Int, let gid = dict["gid"] as? String else {return nil}
        
        self.gid = gid
        self.name = name
        self.uploaded_date = uploaded_date
        self.uploaded_by_uid = uploaded_by_uid
        self.notes_num = notes_num
        self.notes_done = notes_done
        
    }
}

/// sharing list snapshot
class ListsSnapshot {
    // MARK: - Variables
    let lists: [FbSharingList]
    // MARK: - Methods
    init?(with snapshot: DataSnapshot) {
        var lists = [FbSharingList]()
        
        guard let snapDict = snapshot.value as? [String: [String: Any]] else {
            return nil
        }
        for snap in snapDict {
            guard let list = FbSharingList(listId: snap.key, dict: snap.value) else {
                continue
            }
            lists.append(list)
        }
        lists.sort(by: { (l1, l2) -> Bool in
            return l1.uploaded_date! > l2.uploaded_date!
        })
        self.lists = lists
    }
    
}

/// convert firebase note data structure to local data structure
class FbSharingListNote {
    // MARK: - Variables
    var nid: String?
    var lid: String?
    var gid: String?
    var title: String?
    var text: String?
    var done: Bool?
    var doneby: String?
    var due: String?
    var created: Double?
    // MARK: - Methods
    init?(noteId: String, dict: [String : Any]) {
        
        self.nid = noteId
        
        guard let title = dict["title"] as? String, let text = dict["text"] as? String, let done = dict["done"] as? Bool, let doneby = dict["doneby"] as? String, let due = dict["due"] as? String, let created = dict["created"] as? Double, let lid = dict["lid"] as? String, let gid = dict["gid"] as? String else { print("err in fbsharinglistnote");return nil }
        
        self.title = title
        self.text = text
        self.done = done
        self.doneby = doneby
        self.due = due
        self.created = created
        self.lid = lid
        self.gid = gid
    }
}

/// note snapshot
class NotesSnapshot {
    // MARK: - Variables
    let notes: [FbSharingListNote]
    // MARK: - Methods
    init?(with snapshot: DataSnapshot) {
        var notes = [FbSharingListNote]()
        
        guard let snapDict = snapshot.value as? [String: [String: Any]] else {
            print("err in notessnapshot") ;return nil
        }
        
        for snap in snapDict {
            guard  let note = FbSharingListNote(noteId: snap.key, dict: snap.value) else {
                continue
            }
            notes.append(note)
        }
        notes.sort { (n1, n2) -> Bool in
            return n1.created! > n2.created!
        }
        self.notes = notes
        
    }
    
}

/// convert firebase message data structure to local data structure
class FbMessage {
    // MARK: - Variables
    var messageId: String?
    var fromId: String?
    var toId: String?
    var timestamp: Int64?
    var text: String?
    var imageURL: String?
    var imageWidth: NSNumber?
    var imageHeight: NSNumber?
    var groupName: String?
    // MARK: - Methods
    init?(messageId: String, dict: [String : Any]) {
        
        self.messageId = messageId
        
        guard let fromId = dict["fromId"] as? String, let toId = dict["toId"] as? String, let timestamp = dict["timestamp"] as? Int64 else { print("err in message"); return nil }
        
        self.fromId = fromId
        self.toId = toId
        self.timestamp = timestamp
        self.text = dict["text"] as? String
        self.imageURL = dict["imageURL"] as? String
        self.imageWidth = dict["imageWidth"] as? NSNumber
        self.imageHeight = dict["imageHeight"] as? NSNumber
        self.groupName = dict["groupName"] as? String
    }
    
    func chatPartnerId() -> String? {
        return self.fromId == Auth.auth().currentUser?.uid ? self.toId : self.fromId
    }
}



/// to chat partner message address
class ToUserMessageAddress {
    // MARK: - Variables
    var toUserMessageId: String?
    var timestamp: Int64?
    // MARK: - Methods
    init?(dict: (key: String, value: Any)) {
        self.toUserMessageId = dict.key
        self.timestamp = dict.value as? Int64
    }
}

/// user message snapshot
class UserMessageSnapshot {
    // MARK: - Variables
    let userMessageAddress: [ToUserMessageAddress]
    // MARK: - Methods
    //msg controller msg addresses
    init?(with snapshot: DataSnapshot) {
        var userMessageAddresses = [ToUserMessageAddress]()
        guard let userMsgSnapDict = snapshot.value as? [String: [String: Any]] else {
            print("err in toIDsnapDict") ;return nil
        }
        for toIDSnapshotDict in userMsgSnapDict {
            var toUserMessageAddresses = [ToUserMessageAddress]()
            for toIDSnap in toIDSnapshotDict.value {
                let toUserMessageAddress = ToUserMessageAddress(dict: toIDSnap)
                toUserMessageAddresses.append(toUserMessageAddress!)
            }
            toUserMessageAddresses.sort(by: { (add1, add2) -> Bool in
                return add1.timestamp! > add2.timestamp!
            })
            userMessageAddresses.append(toUserMessageAddresses[0])
        }
        self.userMessageAddress = userMessageAddresses
    }

    //chat log msg addresses
    init?(withP2P snapshot: DataSnapshot) {
        var userMessageAddress = [ToUserMessageAddress]()
        guard let userMsgSnapDict = snapshot.value as? [String: Any] else {
            print("err in P2PsnapDict") ;return nil
        }
        for msgAddressDict in userMsgSnapDict {
            let toUserMessageAddress = ToUserMessageAddress(dict: msgAddressDict)
            userMessageAddress.append(toUserMessageAddress!)
        }
        self.userMessageAddress = userMessageAddress
    }
}

/// message snapshot
class MessageSnapshot {
    // MARK: - Variables
    let userMsgs: [FbMessage]
    // MARK: - Methods
    init?(with snapshot: DataSnapshot, at userMessageAddress: [ToUserMessageAddress]) {
        var userMsgs = [FbMessage]()
        
        guard let snapDict = snapshot.value as? [String: [String: Any]] else {
            print("err in messagesnapshot"); return nil
        }
        
        for userMsgAddress in userMessageAddress {
            let msgDict = snapDict[userMsgAddress.toUserMessageId!]
            let msg = FbMessage(messageId: userMsgAddress.toUserMessageId!, dict: msgDict!)
            userMsgs.append(msg!)
        }
        self.userMsgs = userMsgs
    }
}

/// user ids snapshot
class UserIdsSnapshot {
    // MARK: - Variables
    let userIds: [String]
    // MARK: - Methods
    init?(with snapshot: DataSnapshot) {
        var userIds = [String]()
        
        guard let snapDict = snapshot.value as? [String : Any] else {
            print("err in userIdssnapshot"); return nil
        }
        
        for dict in snapDict {
            userIds.append(dict.key)
        }
        
        self.userIds = userIds
    }
}

class FbGroup {
    
    // MARK: - Variables
    var gid: String?
    var name: String?
    var created: Int64?
    var host: String?
    
    // MARK: - Methods
    init?(dict: [String : Any]) {
        guard let created = dict["created"] as? Int64 else {
            print("err in group"); return nil
        }
        
        self.gid = dict["gid"] as? String
        self.name = dict["name"] as? String
        self.created = created
        self.host = dict["host"] as? String
    }
    
    init?(gid: String?, name: String?) {
        self.gid = gid
        self.name = name
        self.created = nil
        self.host = nil
    }
}

class UserGroupAddress {
    // MARK: - Variables
    var gid: String?
    var created: Int64?
    // MARK: - Methods
    init?(dict: (key: String, value: Any)) {
        self.gid = dict.key
        self.created = dict.value as? Int64
    }
}

class GroupSnapshot {
    // MARK: - Variables
    let groups: [FbGroup]
    // MARK: - Methods
    init?(with snapshot: DataSnapshot, addresses: [UserGroupAddress]) {
        var groups = [FbGroup]()
        
        guard let groupsSnapDict = snapshot.value as? [String : [String : Any]] else {
            print("err in group snapshot") ;return nil
        }
        for address in addresses {
            if let groupDict = groupsSnapDict[address.gid!] {
                let group = FbGroup(dict: groupDict)
                groups.append(group!)
            }
        }
        self.groups = groups
    }
}

class UserGroupSnapshot {
    // MARK: - Variables
    let gAddresses: [UserGroupAddress]
    // MARK: - Methods
    init?(with snapshot: DataSnapshot) {
        var gAddresses = [UserGroupAddress]()
        
        guard let groupsSnapDict = snapshot.value as? [String: Any] else {
            print("err in group snapshot") ;return nil
        }
        for dict in groupsSnapDict {
            gAddresses.append(UserGroupAddress(dict: dict)!)
        }
        gAddresses.sort { (g1, g2) -> Bool in
            return g1.created! > g2.created!
        }
        self.gAddresses = gAddresses
    }
}






















