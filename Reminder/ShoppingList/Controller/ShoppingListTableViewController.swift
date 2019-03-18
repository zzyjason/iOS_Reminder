//
//  ShoppingListTableViewController.swift
//  Reminder
//
//  Created by Jason on 2017/9/10.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import CoreData

class ShoppingListTableViewController: UITableViewController,NSFetchedResultsControllerDelegate,PHPModelProtocol {

    
    
    private var ServerRequest:PHPModel?
    {
        didSet{
            
            ServerRequest?.delegate=self
            
            let ObjectType="?TypeObject=ShoppingListItem"
            ServerRequest?.URLPath.append(ObjectType)
            ServerRequest?.URLPath.append("&UserID=\(ShoppingListServerObject.getUid() ?? "Default")")
            
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

        refreshController?.endRefreshing()

    }
    
    
    @objc var refreshController:UIRefreshControl?
    {
        didSet{

            refreshController?.addTarget(self, action: #selector(self.CheckServerUpdatedItem(_:)), for:.valueChanged)

        }
    }
    
    
    func ItemDownloaded(items: NSArray) {
        
        let ObjectLeft=ShoppingListItem.FindExcessObject(items as! [ServerObject])

        
        print("Object Left: \(ObjectLeft.count)")
        for Item in ObjectLeft {

            _=ShoppingListItem.CompareAndUpdate(Object: Item as! ShoppingListServerObject)
        }
    }
    

    override var tableView: UITableView!
    {
        didSet{
            updateUI()
        }
    }
    
    
    var context = AppDelegate.PersistentContainer.viewContext
    {
        didSet{
            updateUI()
        }
    }
    

    
    var fetchedResultController:NSFetchedResultsController<ShoppingListItem>?

    func updateUI()
    {
        let request:NSFetchRequest<ShoppingListItem>=ShoppingListItem.fetchRequest()

        request.sortDescriptors = [NSSortDescriptor(key:"category", ascending: true),  NSSortDescriptor(key:"itemName",ascending:true)]
        request.predicate=NSPredicate(format: "offLineDeleted == %@", NSNumber(value:false))
        
        fetchedResultController=NSFetchedResultsController(fetchRequest: request, managedObjectContext: context, sectionNameKeyPath: "category", cacheName: nil)
        fetchedResultController?.delegate=self
        
        try? fetchedResultController?.performFetch()
        
        tableView.reloadData()
    }
    
     func controllerWillChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.beginUpdates()
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange sectionInfo: NSFetchedResultsSectionInfo, atSectionIndex sectionIndex: Int, for type: NSFetchedResultsChangeType) {
        
        switch type{
        case .insert: tableView.insertSections([sectionIndex], with: .fade)
        case .delete: tableView.deleteSections([sectionIndex], with: .fade)
        default: break
        }
        
    }
    
    func controller(_ controller: NSFetchedResultsController<NSFetchRequestResult>, didChange anObject: Any, at indexPath: IndexPath?, for type: NSFetchedResultsChangeType, newIndexPath: IndexPath?) {
        
        switch type{
        case .insert:
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        case .delete:
            tableView.deleteRows(at: [indexPath!], with: .fade)
        case .update:
            
            tableView.reloadRows(at: [indexPath!], with: .fade)
        case .move:
            tableView.deleteRows(at: [indexPath!], with: .fade)
            tableView.insertRows(at: [newIndexPath!], with: .fade)
        }
        

    }
    
    func controllerDidChangeContent(_ controller: NSFetchedResultsController<NSFetchRequestResult>) {
        
        tableView.endUpdates()

    }

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        updateUI()
        
        ServerRequest=PHPModel(TypeObject: "ShoppingListItem")


        self.navigationController?.setToolbarHidden(true, animated: true)

        // Uncomment the following line to preserve selection between presentations
        // self.clearsSelectionOnViewWillAppear = false
        
        // Uncomment the following line to display an Edit button in the navigation bar for this view controller.
        // self.navigationItem.rightBarButtonItem = self.editButtonItem()
    }


    // MARK: - Table view data source

    override func numberOfSections(in tableView: UITableView) -> Int {

        return fetchedResultController?.sections?.count ?? 1
    }


    
    
    override func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        return fetchedResultController?.sections?[section].name ?? "None"
    }
    

    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {

        
        if let result = fetchedResultController?.sections, result.count>0
        {
            
            return result[section].numberOfObjects
        }
        
        
        return 0
    }

    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {

        

        let cell = tableView.dequeueReusableCell(withIdentifier: "ShoppingListItemCell", for: indexPath)
        
        let result = cell as! ShoppingListItemCellTableViewCell
        
        if let newShoppingListItem = fetchedResultController?.object(at: indexPath)
        {
            

            result.ItemName.text = (newShoppingListItem.itemName!)
            


            if let Amount=newShoppingListItem.amount.toInt()
            {
                result.AmountAndUnit.text=String(Amount) + " " + newShoppingListItem.amountUnit!
            }
            else{
                result.AmountAndUnit.text=String(newShoppingListItem.amount) + " " + newShoppingListItem.amountUnit!
            }

            if(newShoppingListItem.dueDate == nil)
            {
                result.NeedBy.isHidden=true
            }
            else
            {
                result.NeedBy.isHidden=false
                let DayLeft=(Double((newShoppingListItem.dueDate?.timeIntervalSince(Date()))!)/3600.0/24).rounded().toInt()
                if(DayLeft!<=0 && !newShoppingListItem.done)
                {
                    result.NeedBy.textColor=UIColor.red
                }
                else{
                    result.NeedBy.textColor=UIColor.black
                }
                if(DayLeft==0)
                {
                    result.NeedBy.text="Need It in: Today!"
                }else if (DayLeft!>0){
                    result.NeedBy.text="Need It in: \(DayLeft!) Day"
                }else if(DayLeft!<0)
                {
                    result.NeedBy.text="Pass Due:   \(abs(DayLeft!)) Day"
                    
                }

            }
            if(newShoppingListItem.done)
            {

                    result.CheckMark.setOn(true, animated: true)

            }else{
                

                    result.CheckMark.setOn(true, animated: false)
                    result.CheckMark.setOn(false, animated: true)


            }

            result.Item=newShoppingListItem
        }
        
        
        return result
    }
    


   
    /*
    // Override to support rearranging the table view.
    override func tableView(_ tableView: UITableView, moveRowAt fromIndexPath: IndexPath, to: IndexPath) {

    }
    */

    /*
    // Override to support conditional rearranging of the table view.
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the item to be re-orderable.
        return true
    }
    */

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
