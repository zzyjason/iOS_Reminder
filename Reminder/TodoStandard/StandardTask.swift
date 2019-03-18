//
//  StandardTask.swift
//  TodoStanderd
//
//  Created by Geng Sun on 9/30/17.
//  Copyright © 2017 Iowa State University. All rights reserved.
//

import Foundation
import CoreData
import UIKit

class StandardTask: NSManagedObject
{
    func ToDICT()->[String:String?]{
        var DICT:[String:String?]=[:]
        
        DICT["StandardTaskName"] = taskName!
        DICT["StandardTaskFrequency"] = frequence!
        DICT["UserID"] = username!
        if(self.dueDate != nil)
        {
            
            let Formater=DateFormatter()
            Formater.dateFormat="yyyy-MM-dd"
            let DueDateString=Formater.string(from: Date(timeIntervalSince1970: (self.dueDate!.timeIntervalSince1970)))
            
            DICT["StandardTaskDueDate"]=DueDateString
        }
        else{
            DICT["StandardTaskDueDate"]="NULL"
        }
            
        if(self.reminderTime != nil) {
            let Formater=DateFormatter()
            Formater.dateFormat="yyyy-MM-dd"
            let ReminderTimeString=Formater.string(from: Date(timeIntervalSince1970: (self.reminderTime!.timeIntervalSince1970)))
            
            DICT["StandardTaskReminderTime"]=ReminderTimeString
        }
        
        else{
            DICT["StandardTaskReminderTime"]="NULL"
        }
    
        
        if(self.checkMark)
        {
            DICT["StandardTaskCheckMark"]="1"
        }else{
            DICT["StandardTaskCheckMark"]="0"
        }
        return DICT
    }
    
    func AddToServer(){
        
        
        let DICT=ToDICT()
        
        self.id=Int64(StandardTaskSeverObject.AddObjectToServer(TypeOfObject: "StandardTask", Dictionary: DICT) ?? -1)
        
        try? AppDelegate.PersistentContainer.viewContext.save()
    }
    
    func DeleteFromServer()->Bool{
        
        return StandardTaskSeverObject.DeleteObjectFromServer(TypeOfObject: "StandardTask", ObjectID: Int(id))
    }
    
    func UpdateToServer()->Bool{
        
        var Dict=ToDICT()
        Dict["ObjectID"]=String(id)
        return StandardTaskSeverObject.UpdateObjectToServer(TypeOfObject: "StandardTask", Dictionary: Dict)
        
    }
    
}


