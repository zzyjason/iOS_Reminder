//
//  MenuTableViewController.swift
//  Reminder
//
//  Created by Jason on 2017/11/5.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import UIKit

/// The Controller that controls menu bar tableview feature selection
class MenuTableViewController: UITableViewController {

    

    /// Current Feature
    var ToSelect:Int? = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.transitioningDelegate=AppDelegate.CustomTransition
    }
    

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        tableView.reloadData()
        SelectCurrentFeature()

    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        SelectCurrentFeature()

        tableView.frame=tableView.frame.offsetBy(dx: 0, dy: -35)
        MenuBarViewController.checkUserPrioority()
        
        
        tableView.reloadData()
        SelectCurrentFeature()

    }


    /// set select to current feature on the table view
    func SelectCurrentFeature()
    {
        if(ToSelect != -1)
        {
            tableView.selectRow(at: IndexPath(row: ToSelect!, section: 0), animated: false, scrollPosition: .none)
            let cell=tableView.cellForRow(at: IndexPath(row:ToSelect!,section:0))!
            
            
            cell.selectionStyle = .gray
            cell.selectedBackgroundView?.alpha=0.5
            
            
        }
    }

   
    
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell=super.tableView(tableView, cellForRowAt: indexPath)
        if(indexPath.row==5)
        {
            if(ShoppingListServerObject.getUid()==nil || MenuBarViewController.Status == "regular")
            {
                let lock=UIImageView(image: #imageLiteral(resourceName: "lock3"))
                lock.frame=CGRect(x: 85, y: 10, width: 25, height: 25)
                cell.addSubview(lock)
            }
        }
        return cell
    }





}
