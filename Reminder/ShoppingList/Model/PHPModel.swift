//
//  PHPModel.swift
//  Reminder
//
//  Created by Jason on 2017/10/7.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import Foundation


protocol PHPModelProtocol:class{
    func ItemDownloaded(items:NSArray)
}

class PHPModel: NSObject {
    
    
    init(TypeObject Type:String) {
        TypeObject=Type
    }
    
    var context=AppDelegate.PersistentContainer.viewContext
    
    weak var delegate:PHPModelProtocol!
    
    var data=Data()
    
    var TypeObject:String
    
    var URLPath:String="http://proj-309-gk-b-2.cs.iastate.edu/service.php"

    func AddUser()->Bool{
        let TargetURL:URL=URL(string: URLPath)!
        let defaultSession=Foundation.URLSession(configuration: .default)
        var result = false
        var wait=true
        print(TargetURL)
        let task=defaultSession.dataTask(with: TargetURL){ (data,response,error) in
            
            if(error != nil){
                
                print("Failed to download data")
                print(error ?? "Error But no Name")
                print("")
                
            }else{
                print("\nData Downloaded\n")
                if(!PHPModel.CheckError(data: data!))
                {
                    result=true
                    
                }else{
                    result=false
                }
                
                
            }
            wait=false
        }
        
        task.resume()
        while wait {
        }
        
        return result
    }
    
    
    
    func FetchItem()->Bool{
        let TargetURL:URL=URL(string: URLPath)!
        let defaultSession=Foundation.URLSession(configuration: .default)
        var result = false
        var wait=true
        print(TargetURL)
        let task=defaultSession.dataTask(with: TargetURL){ (data,response,error) in
            
            if(error != nil){
                
                print("Failed to download data")
                print(error ?? "Error But no Name")
                print("")
                
            }else{
                print("\nData Downloaded\n")
                if(!PHPModel.CheckError(data: data!))
                {
                    result=true
                    self.parseJSON(data!)
                }else{
                    result=false
                }
                
                
            }
            wait=false
        }
        
        task.resume()
        while wait {
        }
        
        return result
    }
    
    func UpdateItem()->Bool{
        let TargetURL:URL=URL(string: URLPath) ?? URL(string:URLPath.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
        let defaultSession=Foundation.URLSession(configuration: .default)
        var wait=true
        var result=false
        
        print(TargetURL)
        
        let task=defaultSession.dataTask(with: TargetURL){ (data,response,error) in
            
            if(error != nil){
                print(TargetURL)
                print("Failed to upDate data")
                print(error ?? "Error But no Name")
                print("")
                
                
            }else{
                
                print("\nUpdated Object,\(String(data: data!, encoding: String.Encoding.utf8)!)")
                result = !PHPModel.CheckError(data: data!)
            }
            wait=false
            
        }
        
        task.resume()
        while wait {
            
        }
        return result
    }
    
    func DeleteItem()->Bool
    {
        let TargetURL:URL=URL(string: URLPath) ?? URL(string:URLPath.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
        let defaultSession=Foundation.URLSession(configuration: .default)
        
        var Result=false
        var Wait=true
        print(TargetURL)
        
        let task=defaultSession.dataTask(with: TargetURL){ (data,response,error) in
            
            if(error != nil){
                print(TargetURL)
                print("Failed to upDate data")
                print(error ?? "Error But no Name")
                print("")
                
                Result=false
            }else{
                
                print("\nDeleted Object,\(String(data: data!, encoding: String.Encoding.utf8)!)")
                
                Result = !PHPModel.CheckError(data: data!)
            }
            Wait=false
        }
        
        task.resume()
        
        while(Wait)
        {
            
        }
        return Result
    }
    
    func AddItem()->Int?{
        
        
        print(URLPath)
        let TargetURL:URL=URL(string: URLPath) ?? URL(string:URLPath.addingPercentEncoding(withAllowedCharacters: .urlFragmentAllowed)!)!
        
        
        let defaultSession=Foundation.URLSession(configuration: .default)
        var result:Int?
        var Wait=true
        
        print(TargetURL)
        
        let task=defaultSession.dataTask(with: TargetURL){ (data,response,error) in
            
            
            
            if(error != nil){
                print(TargetURL)
                print("\nFailed to upDate data")
                print(error ?? "Error But no Name")
                
                Wait=false
            }else{
                print("\nAdded Object")
                
                var DataString=String(data: data!, encoding: String.Encoding.utf8)!
                DataString.characters.removeLast(1)
                DataString.characters.removeFirst(1)
                
            
                
                if(DataString.characters.count>30)
                {
                    
                }else{
                    if(!PHPModel.CheckError(data: data!))
                    {
                        result = Int(DataString)!
                    }
                    else{
                        result = nil
                    }
                    
                    
                }
                Wait=false
            }
            
        }
        
        task.resume()
        
        while(Wait)
        {
            
        }
        
        return result
    }
    
    func parseJSON(_ data:Data)
    {
        var Result=NSArray()
        switch TypeObject {
        case "ShoppingListItem":
            Result=PHPModel.parseJSONforShoppingListItem(data) as NSArray
        case "StandardTask":
            Result=PHPModel.parseJSONforStandardTask(data) as NSArray
        default:
            break;
        }
        
     
        //        let DataString=String(data: data, encoding: String.Encoding.utf8)!
        //
        //        print(DataString)
        

        
        DispatchQueue.main.async(execute: {() ->Void in
            
            self.delegate.ItemDownloaded(items: Result)
        })
        
        
        
    }
    private static func CheckError(data:Data)->Bool{
        if(String(data: data, encoding: String.Encoding.utf8)!.contains("Error"))
        {
            return true
        }
        else{
            return false
        }
    }
    
    private static func parseJSONforShoppingListItem(_ data:Data)->[Any]
    {
        var Result=NSArray()
        do{
            let JsonArray=try JSONSerialization.jsonObject(with: data, options: []) as! [Any]
            for JsonResult in JsonArray{
                let JsonDict = JsonResult as![String:String?]
                
                let ItemName=JsonDict["ItemName"]!
                let UpdateDate=JsonDict["Updatedates"]!
                
                let Done=JsonDict["Done"]!
                let Category=JsonDict["Category"]!
                let AmountUnit=JsonDict["AmountUnit"]!
                let Amount=JsonDict["Amount"]!
                
                
                let Formater=DateFormatter()
                Formater.dateFormat="yyyy-MM-dd HH:mm:ss"
                
                let Object=ShoppingListServerObject(Dictionary: JsonDict, Username: JsonDict["UserID"]!!, ObjectID: Int64(JsonDict["ID"]!!)!, updateDate: Formater.date(from: UpdateDate!)!)
                
                Object.updateDate.addTimeInterval(-(60*60*5))
                
                
                if let Duedate=JsonDict["DueDate"],Duedate != nil
                {
                    Formater.dateFormat="yyyy-MM-dd"
                    let Temp=Formater.date(from: Duedate!)
                    Object.dueDate=Date(timeIntervalSince1970: (Temp?.timeIntervalSince1970)!)
                    
                }
                
                
                Object.itemName=ItemName
                Object.amount=Double(Amount!)!
                Object.amountUnit=AmountUnit
                Object.category=Category
                if(Done=="0")
                {
                    Object.done=false
                }
                else{
                    Object.done=true
                }
                
                Result=Result.adding(Object) as NSArray

            }
                return Result as![Any]
            
        }catch{
            print("Error")
            print(error)
            return []
        }
        

    }
    
    static func parseJSONforStandardTask(_ data:Data)->[Any]{
        var Result=NSArray()
        
        
        do{
            let JsonArray=try JSONSerialization.jsonObject(with: data, options: []) as! [Any]
            for JsonResult in JsonArray{
                let JsonDict = JsonResult as![String:String?]
                
                let TaskName=JsonDict["TaskName"]!
                let UpdateDate=JsonDict["Updatedates"]!
                let CheckMark=JsonDict["CheckMark"]!
                let Frequency=JsonDict["Frequency"]!
                
                
                let Formater=DateFormatter()
                Formater.dateFormat="yyyy-MM-dd HH:mm:ss"
                
                let Object=StandardTaskSeverObject(Dictionary: JsonDict, Username: JsonDict["UserID"]!!, ObjectID: Int64(JsonDict["ID"]!!)!, updateDate: Formater.date(from: UpdateDate!)!)
                
                Object.updateDate.addTimeInterval(-(60*60*5))
                
                
                if let Duedate=JsonDict["DueDate"],Duedate != nil
                {
                    Formater.dateFormat="yyyy-MM-dd"
                    let Temp=Formater.date(from: Duedate!)
                    Object.dueDate=Date(timeIntervalSince1970: (Temp?.timeIntervalSince1970)!)
                    
                }
                let ReminderTime=JsonDict["ReminderTime"]
                Formater.dateFormat="yyyy-MM-dd HH:mm:ss"
                let Temp=Formater.date(from: ReminderTime!!)
                Object.reminderTime=Date(timeIntervalSince1970: (Temp?.timeIntervalSince1970)!)
                
                Object.taskName=TaskName
                Object.frequence = Frequency
                if(CheckMark=="0")
                {
                    Object.checkMark=false
                }
                else{
                    Object.checkMark=true
                }
                
                Result=Result.adding(Object) as NSArray
            }
            
            
        }catch{
            print("Error")
            print(error)
        }
        
        
        return Result as! [Any]
    }
    
    
    
}
