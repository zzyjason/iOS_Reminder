//
//  StandardTaskMainTableViewController.swift
//  TodoStanderd
//
//  Created by Geng Sun on 9/30/17.
//  Copyright © 2017 Iowa State University. All rights reserved.
//

import UIKit
import CoreData

class StandardTaskMainTableViewController: ReminderStandardTableViewController,NSFetchedResultsControllerDelegate,PHPModelProtocol {

    
    var context = AppDelegate.PersistentContainer.viewContext // coredata
    var FetchResultController: NSFetchedResultsController<StandardTask>? // coredata bridge



     
    override func viewDidLoad() {
        super.viewDidLoad()
        UpdateUI()
        ServerRequest=PHPModel(TypeObject: "StandardTask")
        refreshController=UIRefreshControl()
        refreshControl=refreshController
        MenuBarViewController.checkUserPrioority()
    }
    
    func UpdateUI(){
        let request: NSFetchRequest<StandardTask> = StandardTask.fetchRequest()
        request.sortDescriptors=[NSSortDescriptor(key:"taskName",ascending:true)]
        
    FetchResultController = NSFetchedResultsController(fetchRequest:request, managedObjectContext: context, sectionNameKeyPath: nil, cacheName: nil)
        FetchResultController?.delegate = self
        try?FetchResultController?.performFetch()
        tableView.reloadData()
    }
    
    func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        switch type {
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default:break
        }
    }
    
    
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        switch type{
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .automatic)
        case.delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case.update:
            tableView.reloadRows(at: [indexPath!], with: .right)
        case.move:
            tableView.deleteRows(at: [indexPath!], with:  .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        tableView.endUpdates()
    }
    
    @IBAction func AddTask(_ sender: UIBarButtonItem) {
        self.performSegue(withIdentifier: "TaskEdit", sender: self)
    }
    
//    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
//         self.performSegue(withIdentifier: "TaskEdit", sender: self)
//    }
//
//    func prepare(for segue: UIStoryboardSegue, sender: Any?) {
//        if (segue.identifier == "TaskEdit")
//        {
//            let EditVC=segue.destination as!TaskEditViewController
//            EditVC.
//        }
//    }

    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {
        return (FetchResultController?.sections?.count)!
    }

    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // #warning Incomplete implementation, return the number of rows
        return FetchResultController?.sections?[section].numberOfObjects ?? 0
        

    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "StandardTaskCell", for: indexPath) as! StandardTaskCell
        let CoreDataTask = FetchResultController?.sections?[indexPath.section].objects![indexPath.row] as! StandardTask
        let result = cell as! StandardTaskCell
        let newShoppingListItem = FetchResultController?.object(at: indexPath)
        // Configure the cell...
        cell.TaskName.text = CoreDataTask.taskName
        cell.repeatFreqence.text = CoreDataTask.frequence
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateStyle = .medium
        dateFormatter.timeStyle = .none
        dateFormatter.locale = Locale(identifier: "en_US")
        cell.Data.text = dateFormatter.string(from: CoreDataTask.dueDate!)
        
        let DayLeft=(Double((newShoppingListItem?.dueDate?.timeIntervalSince(Date()))!)/3600.0/24).rounded().toInt()
        if(DayLeft!<=0)
        {
            result.TimeLeft.textColor=UIColor.red
        }
        else{
            result.TimeLeft.textColor=UIColor.black
        }
        if(DayLeft==0)
        {
            result.TimeLeft.text="Need It in: Today!"
        }else if (DayLeft!>0){
            result.TimeLeft.text="Need It in: \(DayLeft!) Day"
        }else if(DayLeft!<0)
        {
            result.TimeLeft.text="Pass Due:   \(abs(DayLeft!)) Day"
            
        }

        return cell
    }
 
   

    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 80
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 1
    }
    

    
    

    // delete
    
    
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        
        let Delete=UITableViewRowAction(style: .normal, title: "Delete", handler: DeleteStandardTaskItem)
        Delete.backgroundColor=UIColor.red
        
        return [Delete]
    }

    
    func DeleteStandardTaskItem(_ Action:UITableViewRowAction,row:IndexPath)->Void{
        let ToDeleteCoreDataObject = FetchResultController!.sections?[row.section].objects?[row.row] as! StandardTask
        ToDeleteCoreDataObject.DeleteFromServer()
        context.delete(ToDeleteCoreDataObject)
    
        try? context.save()
    }
    
    private var ServerRequest:PHPModel?
    {
        didSet{
            
            ServerRequest?.delegate=self
            
            let ObjectType="?TypeObject=StandardTask&UserID=Default"
            
            ServerRequest?.URLPath.append(ObjectType)
            
        }
    }
    
    @objc func CheckServerUpdatedItem(_ sender:Any)
    {
        refreshController?.beginRefreshing()
        if(!(ServerRequest?.URLPath.contains("&TypeOperation=Fetch"))!)
        {
            ServerRequest?.URLPath.append("&TypeOperation=Fetch")
        }
        
        print(ServerRequest?.URLPath ?? "Request is Null")
        if(!(ServerRequest?.FetchItem())!)
        {
            print("Error, Fetch Failed")
        }
        
        let RequestObject: NSFetchRequest<StandardTask> = StandardTask.fetchRequest()
         RequestObject.sortDescriptors=[NSSortDescriptor(key:"taskName",ascending:true)]
        var CoreDataArray:[StandardTask]?=try? context.fetch(RequestObject)
        if (CoreDataArray?.count ?? 0 > 0){
            for content in CoreDataArray!{
                context.delete(content)
            }
        }
        
        
        
        refreshController?.endRefreshing()
        
    }
    
    
    @objc var refreshController:UIRefreshControl?
        {
        didSet{
            refreshController?.addTarget(self, action: #selector(self.CheckServerUpdatedItem(_:)), for:.valueChanged)
        }
    }
//    let cell = tableView.dequeueReusableCell(withIdentifier: "StandardTaskTableViewCell", for: indexPath)
//
//    let result = cell as! StandardTaskTableViewCell
//
//    if let newShoppingListItem = fetchedResultController?.object(at: indexPath)
//    {
//        result.ItemName.text = (newShoppingListItem.itemName!)
//        
//
//        if let Amount=newShoppingListItem.amount.toInt()
//        {
//            result.AmountAndUnit.text=String(Amount) + " " + newShoppingListItem.amountUnit!
//        }
//        else{
//            result.AmountAndUnit.text=String(newShoppingListItem.amount) + " " + newShoppingListItem.amountUnit!
//        }
//
//        if(newShoppingListItem.dueDate == nil)
//        {
//            result.NeedBy.isHidden=true
//        }
//        else
//        {
//            result.NeedBy.isHidden=false
//            let DayLeft=(Double((newShoppingListItem.dueDate?.timeIntervalSince(Date()))!)/3600.0/24).rounded().toInt()
//            if(DayLeft!<=0 && !newShoppingListItem.done)
//            {
//                result.NeedBy.textColor=UIColor.red
//            }
//            else{
//                result.NeedBy.textColor=UIColor.black
//            }
//            if(DayLeft==0)
//            {
//                result.NeedBy.text="Need It in: Today!"
//            }else if (DayLeft!>0){
//                result.NeedBy.text="Need It in: \(DayLeft!) Day"
//            }else if(DayLeft!<0)
//            {
//                result.NeedBy.text="Pass Due:   \(abs(DayLeft!)) Day"
//
//            }
//
//        }
//        if(newShoppingListItem.done)
//        {
//            result.CheckMark.setOn(true, animated: true)
//        }else{
//            result.CheckMark.setOn(false, animated: true)
//        }
//
//        result.Item=newShoppingListItem
//    }
//
//
//    return result

    func ItemDownloaded(items: NSArray) {
        
        
        let ServerObjects=items as! [StandardTaskSeverObject]
        print(ServerObjects[0])
    
        for ServerObjectsToreplace in ServerObjects{
            
        let ChangeTask = StandardTask(context:context)
            
        ChangeTask.dueDate = ServerObjectsToreplace.dueDate
        ChangeTask.reminderTime = ServerObjectsToreplace.reminderTime
        ChangeTask.frequence = ServerObjectsToreplace.frequence
        ChangeTask.taskName = ServerObjectsToreplace.taskName
        ChangeTask.id=ServerObjectsToreplace.id
            try? context.save()
        }
    }

    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.

        if segue.identifier == "StandardTaskToMenu"
        {
            let ToVC=segue.destination as!MenuBarViewController
            ToVC.CurrentFeature=0
        }

        // Pass the selected object to the new view controller.
    }
    

}
