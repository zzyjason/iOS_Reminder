//
//  MenuProfileEditorViewController.swift
//  Reminder
//
//  Created by Jason on 2017/12/2.
//  Copyright © 2017年 Yijia Huang. All rights reserved.
//

import UIKit

/// Extended from Profile Editor and made changes so that it fits menu bar
class MenuProfileEditorViewController: ReminderStandardViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @IBOutlet weak var ContentViews: UIView!
    
    
    @objc func setNavigationBar() {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 60))
        let navItem = UINavigationItem(title: "")
        let doneItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu-1"), style:.plain, target: nil, action: #selector(ToMenu))
        
        doneItem.imageInsets=UIEdgeInsets(top: 1, left: -8, bottom: -6, right: 0)

        
        navItem.leftBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)
        navBar.isTranslucent = false
        navBar.barStyle = .black
        navBar.barTintColor = ReminderStandardViewController.GetCurrentBackGroundThemeColor().MainColor
        self.view.addSubview(navBar)
        
        self.view.bringSubview(toFront: navBar)
        
    }
    
    let MenuVC=MenuBarViewController()
    let MenuTransit=MenuTransitioning()
    @objc func ToMenu(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let MenuVC=storyboard.instantiateViewController(withIdentifier: "MenuBar") as! MenuBarViewController
        MenuVC.CurrentFeature=4
        MenuVC.transitioningDelegate=MenuTransit
        present(MenuVC, animated: true, completion: nil)
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
