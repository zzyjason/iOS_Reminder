//
//  ShoppingListServerObject.swift
//  Reminder
//
//  Created by Jason on 2017/10/13.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import Foundation
import Firebase

class ShoppingListServerObject:ServerObject{
    
    var itemName:String?
    var dueDate:Date?
    var done:Bool?
    var category:String?
    var amountUnit:String?
    var amount:Double?
    
    
    
    
    static func getUid() -> String? {
        return Auth.auth().currentUser?.uid
    }
    
    static func NewUser(_ uid:String)
    {
        let PHP=PHPModel(TypeObject: "User")
        PHP.URLPath.append("?UserID=\(uid)&TypeOperation=NewUser")
        if(!PHP.AddUser())
        {
            print("Failed Add User")
        }
    }
    
    
    static func DoneLogin()
    {
        if Auth.auth().currentUser?.uid != nil {
            
            
            ShoppingListItem.FetchCurrentUserItemFromServer()

        }
    }
}
