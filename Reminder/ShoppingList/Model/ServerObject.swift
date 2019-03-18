//
//  ServerObject.swift
//  Reminder
//
//  Created by Jason on 2017/10/8.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import Foundation


class ServerObject{
    
    init(Dictionary Dict: [String : String?], Username UserID: String, ObjectID: Int64, updateDate ObjectUpdatedDate: Date) {
        id=ObjectID
        dictionary=Dict
        
        username=UserID
        updateDate=ObjectUpdatedDate
        
    }
    
    var id:Int64
    var updateDate:Date
    var username:String
    var dictionary:[String:String?]
    
    static func AddObjectToServer(TypeOfObject:String,Dictionary:[String:String?])->Int?
    {
        
        let Request=PHPModel(TypeObject: TypeOfObject)
        Request.URLPath.append("?TypeObject=\(TypeOfObject)&TypeOperation=Add")
        
        for Set in Dictionary {
            if(Set.value != nil)
            {
                Request.URLPath.append("&\(Set.key)=\(Set.value!)")
            }else{
                Request.URLPath.append("&\(Set.key)=NULL")
            }
        }
        return Request.AddItem()
    }
    
    static func UpdateObjectToServer(TypeOfObject:String,Dictionary:[String:String?])->Bool
    {
        let Request=PHPModel(TypeObject: TypeOfObject)
        Request.URLPath.append("?TypeObject=\(TypeOfObject)&TypeOperation=Update")
        for Set in Dictionary {
            if(Set.value != nil)
            {
                Request.URLPath.append("&\(Set.key)=\(Set.value!)")
            }else{
                Request.URLPath.append("&\(Set.key)=NULL")
            }
        }
        
        return Request.UpdateItem()
    }
    
    static func DeleteObjectFromServer(TypeOfObject:String,ObjectID:Int)->Bool
    {
        let Request=PHPModel(TypeObject: TypeOfObject)
        Request.URLPath.append("?TypeObject=\(TypeOfObject)&TypeOperation=Delete&ObjectID=\(ObjectID)")
        return Request.DeleteItem()
    }
    
}

