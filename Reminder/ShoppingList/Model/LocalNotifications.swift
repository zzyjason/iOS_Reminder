//
//  LocalNotifications.swift
//  Reminder
//
//  Created by Jason on 2017/10/22.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import Foundation
import CoreData
import UserNotifications


class LocalNotifications:NSObject,UNUserNotificationCenterDelegate {
    

    
    static func AddLocalNotifications(TypeObject:String,ObjectID:Int,Title:String,DateTime:Date)
    {
        let content=UNMutableNotificationContent()
        content.title=NSString.localizedUserNotificationString(forKey: Title, arguments: nil)
        content.subtitle=" "
        content.body=" "
        
        content.sound=UNNotificationSound.default()
        
        content.categoryIdentifier="ShoppingList"
        
        let trigger=UNTimeIntervalNotificationTrigger(timeInterval: DateTime.timeIntervalSinceNow, repeats: false)
        
        
        
        let request=UNNotificationRequest(identifier: "\(TypeObject) \(ObjectID)",content: content, trigger: trigger)
        
        let center=UNUserNotificationCenter.current()
        
        center.add(request) { (error) in
            print(error ?? "err")
        }
        
        
        center.getPendingNotificationRequests(completionHandler: {(List) in print(List)})

        
    }
    
    static func DeleteNotifications(TypeObject:String,ObjectID:Int)
    {
        let center=UNUserNotificationCenter.current()
        
        center.removePendingNotificationRequests(withIdentifiers: ["\(TypeObject) \(ObjectID)"])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, willPresent notification: UNNotification, withCompletionHandler completionHandler: @escaping (UNNotificationPresentationOptions) -> Void) {
        print("Did")
        completionHandler([.alert,.sound,.badge])
    }
    
    func userNotificationCenter(_ center: UNUserNotificationCenter, didReceive response: UNNotificationResponse, withCompletionHandler completionHandler: @escaping () -> Void) {
        
        print("Did Receive")
        
        let Context=AppDelegate.PersistentContainer.viewContext
        
        let id=response.notification.request.identifier.numbers
        
        let request:NSFetchRequest<ShoppingListItem>=ShoppingListItem.fetchRequest()
        if let CurrentObject=try? Context.fetch(request)
        {
            var TargetObject:ShoppingListItem?=nil
            for item in CurrentObject
            {
                if(id==Int(item.id))
                {
                    TargetObject=item
                    break
                }
            }
            if (TargetObject != nil){
                
                if(response.actionIdentifier == "Delay")
                {
                    TargetObject?.dueDate?.addTimeInterval(60*60*24)
                    
                    LocalNotifications.AddLocalNotifications(TypeObject: "ShoppingList", ObjectID: Int(TargetObject!.id), Title: "\(TargetObject!.itemName!) is Due", DateTime: (TargetObject?.dueDate!)!)
                }else if(response.actionIdentifier == "MarkDone")
                {
                    TargetObject?.done=true
                }
                try? Context.save()
                let _=TargetObject?.UpdateToServer()
            }
            else{
                print("Did Not Find Object To edit")
            }
            
        }
        
        completionHandler()
        
    }
}
