//
//  MenuBarViewController.swift
//  Reminder
//
//  Created by Jason on 2017/11/4.
//  Copyright © 2017年 Iowa State University Com S 309. All rights reserved.
//

import UIKit
import Firebase

/// View Controller For Menu Bar
class MenuBarViewController: UIViewController,UITableViewDelegate{

    ///Shows which Feature Menu Bar Got Call from
    var CurrentFeature:Int? = -1
    
    override func awakeFromNib() {
        super.awakeFromNib()
        self.transitioningDelegate=AppDelegate.CustomTransition
        
        MenuBarViewController.checkUserPrioority()
    }

    /// The Content View that will display the menu option to different feature
    @IBOutlet weak var TableContentView: UIView!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        
        
        self.view.layer.shadowOpacity = 1
        self.view.layer.shadowRadius = 5
        TableContentView.clipsToBounds=true

        if let ThemeColor=ReminderStandardViewController.Theme((UserDefaults.standard.object(forKey: "BackGroundTheme") ?? "Default") as! String).SubColor
        {
            MenuBarView.backgroundColor=ThemeColor
        }
        

    }
    
    

    @IBAction func Dismiss(_ sender: Any) {
        

        dismiss(animated: true, completion: nil)

        
    }
    
    /// the actully view that menubar will exitst in
    @IBOutlet weak var MenuBarView: UIView!
    
    

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()

    }
    
    /// An Instance of Custom Transitioning to different feature.
    var NewFeatureTransit=NewFeatureTransitioning()

    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {

        if(section == 0)
        {

            return 0.1
        }
        return 35
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {

        if (indexPath.row == CurrentFeature!)
        {
            dismiss(animated: true, completion: nil)
            return
        }
        
        switch indexPath.row{
        case 0:
            performSegue(withIdentifier: "StandardTask", sender: self)
        case 1:
            performSegue(withIdentifier: "SharingList", sender: self)
        case 2:
            performSegue(withIdentifier: "ShoppingList", sender: self)
        case 3:
            performSegue(withIdentifier: "ExpenseTracker", sender: self)
        case 4:
            
            var LoginVC:UIViewController
            if(ShoppingListServerObject.getUid() == nil)
            {
                LoginVC=MenuAccountLoginViewController()
                LoginVC.transitioningDelegate=NewFeatureTransit
                present(LoginVC, animated: true, completion: nil)

            }else{
                let storyboard = UIStoryboard(name: "Main", bundle: nil)
                let ProfileVC=storyboard.instantiateViewController(withIdentifier: "MenuProfileEditor")

                ProfileVC.transitioningDelegate=NewFeatureTransit
                present(ProfileVC, animated: true, completion: nil)
            }
            



        case 5:

            MenuBarViewController.checkUserPrioority()

            if(MenuBarViewController.Status != "regular")
            {
                performSegue(withIdentifier: "Setting", sender: self)
                break;
            }
            
            
            alert(msg: "Please Upgrade Your Account")

            break;
            

        default:
            break
        }
    }
    
    

    /// The Current Status User
    static var Status:String="regular"
    
    
    /// Check Fire Base User Priority and save the result in static variable Status
    static func checkUserPrioority(){

        if(ShoppingListServerObject.getUid() != nil)
        {
            let userRef = DatabaseService.shared.userRef.child((Auth.auth().currentUser?.uid)!)


            userRef.observe(DataEventType.value, with: {(snapshot) in
                let CurrentUser = FbUser(uid: (ShoppingListServerObject.getUid())!, dict: (snapshot.value as! [String : Any]))
                self.Status=CurrentUser?.status ?? "regular"

                if self.Status=="regular"
                {
                    UserDefaults.standard.set("Default", forKey: "BackGroundTheme")
                }

            })

        }else{
            UserDefaults.standard.set("Default", forKey: "BackGroundTheme")
        }
    }
    
    
    /// Give out an System Alert depends on the input msg
    ///
    /// - Parameter msg: the message that is going to show to user
    func alert(msg: String) {
        let alert = UIAlertController(title: msg, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }


    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {

        if(segue.identifier=="EmbedSegue")
        {
            let ToVC=segue.destination as! MenuTableViewController
            ToVC.tableView.delegate=self
            ToVC.ToSelect=CurrentFeature
  
            

        }else{
            segue.destination.transitioningDelegate=AppDelegate.NewFeatureTransition
        }
        

    }
 

}
