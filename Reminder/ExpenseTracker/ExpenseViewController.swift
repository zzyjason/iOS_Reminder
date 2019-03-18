//
//  ViewController.swift
//  ExpenseTracker
//
//  Created by Bei Zhao on 11/25/17.
//  Copyright © 2017 Bei Zhao. All rights reserved.
//

import UIKit
import os.log

class ExpenseViewController: ReminderStandardViewController, UITableViewDataSource, UITableViewDelegate{
    
    @IBOutlet weak var tableView: UITableView!
    
    var items : [EItem] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.dataSource = self
        tableView.delegate = self
    }
    
    override func viewWillAppear(_ animated: Bool) {
        //get the data from core data
        getData()
        
        //reload the table view
        tableView.reloadData()
    }
    
    
    //Initialize the number of rows in the table view.
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }

    //MARK: -View Management
    
   func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 100
    }

    // Update the data of the table view cells
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "ExpenseTableViewCell", for: indexPath) as? ExpenseTableViewCell else {
            fatalError("The dequeued cell is not an instance of ExpenseTableViewCell.")
        }
        let item = items[indexPath.row]
        cell.CategoryImage.image = UIImage(named: item.category!)
        cell.ItemCategory.text = item.category
        cell.ItemCost.text = String(item.cost)
        cell.ItemDescription.text = item.content
        return cell
    }
    
    // Get data from the core data database
    func getData(){
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        do{
        items = try context.fetch(EItem.fetchRequest())
        }
        catch{
            print("Fetching Failed")
        }
    }

    // Delete specific row of the table view app
    func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        let context = (UIApplication.shared.delegate as! AppDelegate).persistentContainer.viewContext
        if editingStyle == .delete {
            let item = items[indexPath.row]
            context.delete(item)
            (UIApplication.shared.delegate as! AppDelegate).saveContext()
            do{
                items = try context.fetch(EItem.fetchRequest())
            }
            catch{
                print("Fetching Failed")
            }
        }
        tableView.reloadData()
    }
    
    //Segue implementation
    
    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        super.prepare(for: segue, sender: sender)
        
        // To decide which segue to occur
        switch(segue.identifier ?? ""){
            
        case "AddItem":
            os_log("Adding a new item", log: OSLog.default, type: .debug)
        case "ShowChart":
             os_log("Showing the pie chart", log: OSLog.default, type: .debug)
            
        case "ExpenseTrackerToMenu":
            let ToVC=segue.destination as!MenuBarViewController
            ToVC.CurrentFeature=3
            
        default:
            fatalError("Unexpected Segue Identifier: \(String(describing: segue.identifier))")
        }
    }
    
}










