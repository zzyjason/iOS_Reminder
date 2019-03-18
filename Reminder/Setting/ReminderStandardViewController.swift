//
//  ReminderStandardViewController.swift
//  Reminder
//
//  Created by Jason on 2017/11/27.
//  Copyright © 2017年 Yijia Huang. All rights reserved.
//

import UIKit

class ReminderStandardViewController: UIViewController {

    
    
    /// Methods that return Current Theme Color
    ///
    /// - Returns: return 3 color, main color, sub color and nav color.
    static func GetCurrentBackGroundThemeColor()->(MainColor:UIColor?,SubColor:UIColor?,NavColor:UIColor?)
    {
        let CurrentTheme=UserDefaults.standard.object(forKey: "BackGroundTheme")
        return ReminderStandardViewController.Theme((CurrentTheme ?? "Default") as! String)
        
    }
    
    /// Get any Theme Color with an imput of which Theme Option
    ///
    /// - Parameter ThemeTemplate: Theme Option
    /// - Returns: return 3 color, main color, sub color and nav color
    static func Theme(_ ThemeTemplate:String)->(MainColor:UIColor?,SubColor:UIColor?,NavColor:UIColor?)
    {
        
        switch ThemeTemplate
        {
            case "Default":
                return (UIColor.init(red: 0.95, green: 0.95, blue: 0.95, alpha: 1),UIColor.white,UIColor.white)
            case "Option1":
                return (UIColor.init(red:0.86, green:0.96, blue:0.93, alpha:1.0),UIColor(red:0.55, green:0.92, blue:0.75, alpha:1.0),UIColor(red:0.47, green:0.79, blue:0.65, alpha:1.0))
            case "Option2":
                return (UIColor.init(red:198/255, green:228/255, blue:252/255, alpha:1.0),UIColor.init(red:255/255, green:213/255, blue:137/255, alpha:1),UIColor.init(red:255/255, green:165/255, blue:0/255, alpha:1))
            case "Option3":
                return (UIColor.init(red:252/255, green:219/255, blue:255/255, alpha:1.0),UIColor(red:244/255, green:232/255, blue:171/255, alpha:1.0),UIColor.init(red:250/255, green:255/255, blue:130/255, alpha:1))
            case "Option4":
                return (UIColor.init(red:1, green:220/255, blue:220/255, alpha:1.0),UIColor.init(red:219/255, green:155/255, blue:253/255, alpha:1),UIColor.init(red:179/255, green:252/255, blue:248/255, alpha:1))

            default:
                return (UIColor.lightGray,UIColor.white,UIColor.white)
        }
        

    }
    
    /// Perform Change Theme depends on the value of user selection saved in the program
    func ChangeTheme()
    {
        let CurrentTheme=UserDefaults.standard.object(forKey: "BackGroundTheme")
        let ThemeColor=ReminderStandardViewController.Theme((CurrentTheme ?? "Default") as! String)
        if(ThemeColor.SubColor != nil)
        {

            self.navigationController?.navigationBar.backgroundColor=ThemeColor.NavColor
        }
        if(ThemeColor.MainColor != nil)
        {

            self.view.backgroundColor=ThemeColor.MainColor
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChangeTheme()
        SettingBackGroundColorSelectorViewController.ChangeTintColor()
        // Do any additional setup after loading the view.
    }

}

/// Standard TableView Controller that implements Theme Change feature
class ReminderStandardTableViewController:UITableViewController{
    
    func ChangeTheme()
    {
        let CurrentTheme=UserDefaults.standard.object(forKey: "BackGroundTheme")
        
        let ThemeColor=ReminderStandardViewController.Theme((CurrentTheme ?? "Default") as! String)
        
        if(ThemeColor.SubColor != nil)
        {
            self.navigationController?.navigationBar.backgroundColor=ThemeColor.SubColor
        }
        if(ThemeColor.MainColor != nil)
        {
            self.tableView.backgroundColor=ThemeColor.MainColor
        }
        
        
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        SettingBackGroundColorSelectorViewController.ChangeTintColor()
        ChangeTheme()
    }
}


/// Standard Collection view Controller that implements Theme Change feature
class ReminderSTandardUICollectionViewController:UICollectionViewController{
    func ChangeTheme()
    {
        let CurrentTheme=UserDefaults.standard.object(forKey: "BackGroundTheme")
        let ThemeColor=ReminderStandardViewController.Theme((CurrentTheme ?? "Default") as! String)
        if(ThemeColor.SubColor != nil)
        {
            self.navigationController?.navigationBar.backgroundColor=ThemeColor.SubColor
        }
        if(ThemeColor.MainColor != nil)
        {
            
            self.view.backgroundColor=ThemeColor.MainColor
        }
        
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ChangeTheme()
        SettingBackGroundColorSelectorViewController.ChangeTintColor()
        // Do any additional setup after loading the view.
    }
}
