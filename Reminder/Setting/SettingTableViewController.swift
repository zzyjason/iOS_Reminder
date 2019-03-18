//
//  SettingTableViewController.swift
//  Reminder
//
//  Created by Jason on 2017/11/23.
//  Copyright © 2017年 Yijia Huang. All rights reserved.
//

import UIKit



/// Controller that manage setting option
class SettingTableViewController: ReminderStandardTableViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        updateUI()
        

    }




    
    // MARK: - Table view data source

    
    /// Update Display color for current theme and tint color
    func updateUI()
    {
        switch (UserDefaults.standard.object(forKey: "BackGroundTheme") ?? "Any") as! String
        {
        case "Option1":
            ThemeSelector.setBackgroundImage(#imageLiteral(resourceName: "ThemeOption1"), for: .normal)
        case "Option2":
            ThemeSelector.setBackgroundImage(#imageLiteral(resourceName: "ThemeOption2"), for: .normal)
        case "Option3":
            ThemeSelector.setBackgroundImage(#imageLiteral(resourceName: "ThemeOption3"), for: .normal)
        case "Option4":
            ThemeSelector.setBackgroundImage(#imageLiteral(resourceName: "ThemeOption4"), for: .normal)
        default:
            ThemeSelector.setBackgroundImage(#imageLiteral(resourceName: "ThemeDefault"), for: .normal)
        }
        
        switch (UserDefaults.standard.object(forKey: "Tint") ?? "Any") as! String
        {
        case "Option1":
            TintSelector.setBackgroundImage(#imageLiteral(resourceName: "TintOption1"), for: .normal)
        case "Option2":
            TintSelector.setBackgroundImage(#imageLiteral(resourceName: "TintOption2"), for: .normal)
        case "Option3":
            TintSelector.setBackgroundImage(#imageLiteral(resourceName: "TintOption3"), for: .normal)
        case "Option4":
            TintSelector.setBackgroundImage(#imageLiteral(resourceName: "TintOption4"), for: .normal)
        default:
            TintSelector.setBackgroundImage(#imageLiteral(resourceName: "TintDefault"), for: .normal)
        }
        
        if((UserDefaults.standard.object(forKey: "BackGroundTheme")as? String)=="Default")
        {
            tableView.backgroundColor=UIColor.white
            navigationController?.navigationBar.backgroundColor=UIColor.lightGray
        }
    }
    
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        if(section == 0)
        {
            return 0.01
        }
        return 12
    }

    @IBOutlet weak var ThemeSelector: UIButton!
    
    @IBOutlet weak var TintSelector: UIButton!
    
    

    /*
    // Override to support conditional editing of the table view.
    override func tableView(_ tableView: UITableView, canEditRowAt indexPath: IndexPath) -> Bool {
        // Return false if you do not want the specified item to be editable.
        return true
    }
    */

    /*
    // Override to support editing the table view.
    override func tableView(_ tableView: UITableView, commit editingStyle: UITableViewCellEditingStyle, forRowAt indexPath: IndexPath) {
        if editingStyle == .delete {
            // Delete the row from the data source
            tableView.deleteRows(at: [indexPath], with: .fade)
        } else if editingStyle == .insert {
            // Create a new instance of the appropriate class, insert it into the array, and add a new row to the table view
        }    
    }
    */

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

    @IBAction func SelectButtonTintColor(_ sender: Any) {
        performSegue(withIdentifier: "Setting Button Tint Color", sender: self)
    }
    
    
    @IBAction func SelectTheme(_ sender: Any) {
        performSegue(withIdentifier: "Setting Theme", sender: self)
    }
    
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
        
        if(segue.identifier=="SettingToMenu")
        {
            let ToVC=segue.destination as! MenuBarViewController
            ToVC.CurrentFeature=5
        }
        
        if(segue.identifier=="Setting Button Tint Color")
        {
            let ToVC=segue.destination as! SettingBackGroundColorSelectorViewController
            ToVC.SelectButtonTint=true
            ToVC.LastVC=self
        }
        if(segue.identifier=="Setting Theme")
        {
            let ToVC=segue.destination as! SettingBackGroundColorSelectorViewController

            ToVC.LastVC=self
        }
 
    }
 

}
