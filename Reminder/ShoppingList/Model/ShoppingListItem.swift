//
//  ShoppingListItem.swift
//  Reminder
//
//  Created by Jason on 2017/9/10.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData
import UserNotifications
class ShoppingListItem: NSManagedObject
{

    
    static var context=AppDelegate.PersistentContainer.viewContext
    
    static var Tool=ShoppingListItemFetchTool()
    static func FetchCurrentUserItemFromServer()
    {


        Tool.CheckServerUpdatedItem()
    }
    
    func AddNotification()
    {
        if(self.dueDate != nil)
        {
            
            if(self.dueDate!.timeIntervalSinceNow < 0)
            {
                LocalNotifications.AddLocalNotifications(TypeObject: "ShoppingListItem", ObjectID: Int(self.id), Title: "\(self.itemName!) is Due", DateTime: Date().addingTimeInterval(5))
            }else{
                LocalNotifications.AddLocalNotifications(TypeObject: "ShoppingListItem", ObjectID: Int(self.id), Title: "\(self.itemName!) is Due", DateTime: self.dueDate!)
            }
            
        }
    }
    
    
    private func ToDictionary()->[String:String?]
    {
        var Dict:[String:String?]=[:]
        
        Dict["ShoppingListItemAmountUnit"]=amountUnit!
        Dict["ShoppingListItemAmount"]=String(describing: (self.amount))
        Dict["ShoppingListItemCategory"]=category!
        Dict["ShoppingListItemName"]=itemName!
        Dict["UserID"]=username!
        
        
        if(self.done)
        {
            Dict["ShoppingListItemDone"]="1"
        }else{
            Dict["ShoppingListItemDone"]="0"
        }
        
        if(self.dueDate != nil)
        {
            let Formater=DateFormatter()
            Formater.dateFormat="yyyy-MM-dd"
            let DateString=Formater.string(from: Date(timeIntervalSince1970: (self.dueDate!.timeIntervalSince1970)))
            
            Dict["ShoppingListItemDueDate"]=DateString
        }else{
            Dict["ShoppingListItemDueDate"]="NULL"
        }
        
        
        return Dict
    }
    
    func AddToServer(){

        
        let Dict=ToDictionary()

        

        self.id=Int64(ShoppingListServerObject.AddObjectToServer(TypeOfObject: "ShoppingListItem", Dictionary: Dict) ?? -1)
        if id == -1
        {
            self.offLineAdded=true
            print("OffLine Added")
        }

        try? AppDelegate.PersistentContainer.viewContext.save()
        



    }
    
    func DeleteFromServer()->Bool{
        

        return ShoppingListServerObject.DeleteObjectFromServer(TypeOfObject: "ShoppingListItem", ObjectID: Int(id))
    }
    
    func UpdateToServer()->Bool{

        var Dict=ToDictionary()
        Dict["ObjectID"]=String(id)
        return ShoppingListServerObject.UpdateObjectToServer(TypeOfObject: "ShoppingListItem", Dictionary: Dict)
    
    }
    
    static func CompareAndUpdate(Object:ShoppingListServerObject)->Bool
    {
        let request:NSFetchRequest<ShoppingListItem>=ShoppingListItem.fetchRequest()
        request.sortDescriptors=[NSSortDescriptor(key:"id",ascending:true)]
        if let CurrentObjects=try? context.fetch(request) 
        {
            var CorrespondingObject:ShoppingListItem?

            for Item in CurrentObjects {
                if(Item.id==Object.id)
                {
                    CorrespondingObject=Item
                    
                }
                if(Item.offLineAdded)
                {
                    print("\nObject Not In Server Due to OffLine Adding")
                    Item.AddToServer()
                    Item.offLineAdded=false
                    try? context.save()
                    
                }
            }
            
            if(CorrespondingObject==nil)
            {
                print("\nObject Not In Local DataBase")
                AddToCoreData(Object)
                
                return true
            }else if let _=CorrespondingObject?.updateDate ,(CorrespondingObject!.updateDate! > Object.updateDate),!(CorrespondingObject?.updateDate?.timeIntervalSince(Object.updateDate).isLess(than: 10))!{
                
                
                print("\nObject in Server Need to be Update")

                if !CorrespondingObject!.UpdateToServer()
                {
                    print("Error, Trying To Update")
                }
                
                CorrespondingObject?.updateDate=Date()
                CorrespondingObject?.updateDate?.addTimeInterval(-60*60*5)
                CorrespondingObject?.updateDate?.addTimeInterval(5)
                try? context.save()
                return true
                
            }else if let _=CorrespondingObject?.updateDate,(!(CorrespondingObject?.updateDate)!.timeIntervalSince(Object.updateDate).isLess(than: 0)){
                print("\nSame Item, No Need for Update")

            }
            else{
                print("\nOld Item In Local Needed To Update")
                UpdateServerObject(Object, CoreDataObject: CorrespondingObject!)
                return true
            }
        }
        return false
    }
    
    static func AddToCoreData(_ Object:ShoppingListServerObject)
    {
        let NewObjectToAdd=ShoppingListItem(context: context)
        
        NewObjectToAdd.amount=Object.amount!
        NewObjectToAdd.amountUnit=Object.amountUnit!
        NewObjectToAdd.category=Object.category!
        NewObjectToAdd.dueDate=Object.dueDate
        NewObjectToAdd.itemName=Object.itemName
        NewObjectToAdd.done=Object.done!
        NewObjectToAdd.updateDate=Object.updateDate
        NewObjectToAdd.updateDate?.addTimeInterval(5)
        NewObjectToAdd.id=Object.id
        NewObjectToAdd.username=Object.username
        
        try? context.save()
        
    }
    
    static func UpdateServerObject(_ Object:ShoppingListServerObject, CoreDataObject CorrespondingObject:ShoppingListItem)
    {
        CorrespondingObject.amount=Object.amount!
        CorrespondingObject.amountUnit=Object.amountUnit!
        CorrespondingObject.category=Object.category!
        CorrespondingObject.dueDate=Object.dueDate
        CorrespondingObject.itemName=Object.itemName
        CorrespondingObject.done=Object.done!
        CorrespondingObject.updateDate=Object.updateDate
        CorrespondingObject.updateDate?.addTimeInterval(5)
        CorrespondingObject.id=Object.id
        
        try? context.save()
    }
    static func FindExcessObject(_ Objects:[ServerObject])->[ServerObject]
    {
        var Result=Objects
        let request:NSFetchRequest<ShoppingListItem>=ShoppingListItem.fetchRequest()
        request.sortDescriptors=[NSSortDescriptor(key:"id",ascending:true)]
        if let CurrentObjects=try? context.fetch(request)
        {
            
            print("Current Object Count: \(CurrentObjects.count)")
            print("Server Object Count: \(Result.count)")
            for CoreDataObject in CurrentObjects
            {
                var Flag:Bool=true
                
                if(Result.count != 0)
                {
                    for i in 0...Result.count-1{
                        if(Result[i].id == CoreDataObject.id)
                        {
                            if CoreDataObject.offLineDeleted{
                                
                                _=Result.remove(at: i)
                            }
                            
                            Flag=false
                            break
                        }
                    }
                }

                
                if (Flag && !CoreDataObject.offLineAdded){
                    context.delete(CoreDataObject)
                    try? context.save()
                }
                
                if CoreDataObject.offLineDeleted{

                    _=CoreDataObject.DeleteFromServer()
                    context.delete(CoreDataObject)
                    try? context.save()
                }
                
            }
        }
        return Result
    }

    
}
