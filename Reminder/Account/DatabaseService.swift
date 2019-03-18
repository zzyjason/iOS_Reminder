//
//  DatabaseService.swift
//  Reminder
//
//  Created by Yijia Huang on 10/8/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//

import Foundation
import Firebase

/// Database service
class DatabaseService {
    // MARK: - Variables
    /// shared
    static let shared = DatabaseService()
    private init() {}
    
    
    /// firebase user reference
    let userRef = Database.database().reference().child("users")
    
    /// firebase sharing list reference
    let sharingListRef = Database.database().reference().child("sharingLists")
    
    /// firebase message reference
    let messageRef = Database.database().reference().child("messages")
    
    /// firebase user message reference
    let userMessageRef = Database.database().reference().child("user_messages")
    
    /// firebase group reference
    let groupRef = Database.database().reference().child("groups")
    
    let userGroupsRef = Database.database().reference().child("user_groups")
}
