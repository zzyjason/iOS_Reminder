//
//  SettingBackGroundColorSelectorViewController.swift
//  Reminder
//
//  Created by Jason on 2017/11/26.
//  Copyright © 2017年 Yijia Huang. All rights reserved.
//

import UIKit

/// The selection view controller that allow user to select a different theme or tint color
class SettingBackGroundColorSelectorViewController: UIViewController {

    
    /// The controller that called this view controller
    var LastVC:SettingTableViewController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationController?.navigationBar.isHidden=true
        
        if(SelectButtonTint)
        {
            PopUpWindow.frame=PopUpWindow.frame.offsetBy(dx: 0, dy: 45)
            PopUpWindowPointer.frame=PopUpWindowPointer.frame.offsetBy(dx: 0, dy: 45)
            
            Default.setBackgroundImage(#imageLiteral(resourceName: "TintDefault"), for: .normal)
            Option1s.setBackgroundImage(#imageLiteral(resourceName: "TintOption1"), for: .normal)
            Option2s.setBackgroundImage(#imageLiteral(resourceName: "TintOption2"), for: .normal)
            Option3s.setBackgroundImage(#imageLiteral(resourceName: "TintOption3"), for: .normal)
            Option4s.setBackgroundImage(#imageLiteral(resourceName: "TintOption4"), for: .normal)
        }else{
            

            
            Default.setBackgroundImage(#imageLiteral(resourceName: "ThemeDefault"), for: .normal)
            Option1s.setBackgroundImage(#imageLiteral(resourceName: "ThemeOption1"), for: .normal)
            Option2s.setBackgroundImage(#imageLiteral(resourceName: "ThemeOption2"), for: .normal)
            Option3s.setBackgroundImage(#imageLiteral(resourceName: "ThemeOption3"), for: .normal)
            Option4s.setBackgroundImage(#imageLiteral(resourceName: "ThemeOption4"), for: .normal)
            
        }
        // Do any additional setup after loading the view.
    }
    
    @IBOutlet weak var Default: UIButton!
    
    @IBOutlet weak var Option1s: UIButton!
    
    @IBOutlet weak var Option2s: UIButton!
    
    @IBOutlet weak var Option3s: UIButton!
    
    @IBOutlet weak var Option4s: UIButton!
    
    
    /// Is this selection for Tint
    var SelectButtonTint=false
    
    @IBOutlet weak var PopUpWindowPointer: DesignableView!
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var PopUpWindow: DesignableView!
    
    @IBAction func Dismiss(_ sender: Any) {
        dismiss(animated: true, completion:nil)
    }
    
    /// Change Tint Color base on the selection from user
    static func ChangeTintColor(){
        
        
        var Color = UIColor(red: 0, green: 122/255, blue: 255/255, alpha: 1)
        switch (UserDefaults.standard.object(forKey: "Tint") as? String) ?? "Default"
        {
        case "Option1":
            Color = UIColor(red: 0, green: 0, blue: 0, alpha: 1)
        case "Option2":
            Color = UIColor(red: 237/255, green: 28/255, blue: 36/255, alpha: 1)
        case "Option3":
            Color = UIColor(red: 34/255, green: 177/255, blue: 76/255, alpha: 1)
        case "Option4":
            Color = UIColor(red: 163/255, green: 73/255, blue: 164/255, alpha: 1)
        default:
            break
            
        }
        
        UIApplication.shared.keyWindow?.tintColor=Color
    }
    
    /// Store the selection to the program
    ///
    /// - Parameter BackGroundOption: Users Selection
    private func StoreSetting(_ BackGroundOption:String)
    {
        if(!SelectButtonTint){
            UserDefaults.standard.set(BackGroundOption, forKey: "BackGroundTheme")
            LastVC?.ChangeTheme()
        }else{
            
            UserDefaults.standard.set(BackGroundOption,forKey:"Tint")
            
            SettingBackGroundColorSelectorViewController.ChangeTintColor()
            
        }
        LastVC?.updateUI()
    }
    
    /// Default Option of User Selection
    ///
    /// - Parameter sender: Any
    @IBAction func DefaultOption(_ sender: Any) {
        StoreSetting("Default")
        Dismiss(self)
    }
    
    /// Option 1 of User Selection
    ///
    /// - Parameter sender: Any
    @IBAction func Option1(_ sender: Any) {
        StoreSetting("Option1")
        Dismiss(self)
    }
    
    /// Option 2 of User Selection
    ///
    /// - Parameter sender: Any
    @IBAction func Option2(_ sender: Any) {
        StoreSetting("Option2")
        Dismiss(self)
    }
    
    
    /// Option 3 of User Selection
    ///
    /// - Parameter sender: Any
    @IBAction func Option3(_ sender: Any) {
        StoreSetting("Option3")
        Dismiss(self)
    }
    
    /// Option 4 for User Selection
    ///
    /// - Parameter sender: Any
    @IBAction func Option4(_ sender: Any) {
        StoreSetting("Option4")
        Dismiss(self)
    }
    
    
    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
