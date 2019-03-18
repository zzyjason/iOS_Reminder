//
//  ShoppingListItemFetchTool.swift
//  Reminder
//
//  Created by Jason on 2017/11/25.
//  Copyright © 2017年 Yijia Huang. All rights reserved.
//

import Foundation


class ShoppingListItemFetchTool:PHPModelProtocol {
    
    
    func ItemDownloaded(items: NSArray) {
        let ObjectLeft=ShoppingListItem.FindExcessObject(items as! [ServerObject])
        
        
        print("Object Left: \(ObjectLeft.count)")
        for Item in ObjectLeft {
            
            _=ShoppingListItem.CompareAndUpdate(Object: Item as! ShoppingListServerObject)
        }
    }
    
    var ServerRequest=PHPModel(TypeObject: "ShoppingListItem")
    {
        didSet{
            ServerRequest.delegate=self
            let ObjectType="?TypeObject=ShoppingListItem"
            ServerRequest.URLPath.append(ObjectType)
            ServerRequest.URLPath.append("&UserID=\(ShoppingListServerObject.getUid() ?? "Default")")
            
        }
    }
    
    func CheckServerUpdatedItem()
    {
        ServerRequest=PHPModel(TypeObject: "ShoppingListItem")
        
        if(!(ServerRequest.URLPath.contains("&TypeOperation=Fetch")))
        {
            ServerRequest.URLPath.append("&TypeOperation=Fetch")
        }
        
        print(ServerRequest.URLPath)
        if(!(ServerRequest.FetchItem()))
        {
            print("Error, Fetch Failed")
        }
    }
}
