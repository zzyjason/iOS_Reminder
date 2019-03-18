//
//  MenuAccountLoginViewController.swift
//  Reminder
//
//  Created by Jason on 2017/11/25.
//  Copyright © 2017年 Yijia Huang. All rights reserved.
//

import UIKit
import Firebase


/// Extended from Login View COntroller and made changes to fit Menu Bar
class MenuAccountLoginViewController: LoginViewController {

    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    @objc override func setNavigationBar() {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 60))
        let navItem = UINavigationItem(title: "")
        let doneItem = UIBarButtonItem(image: #imageLiteral(resourceName: "menu-1"), style:.plain, target: nil, action: #selector(stop))
        doneItem.imageInsets=UIEdgeInsets(top: 1, left: -8, bottom: -6, right: 0)

        
        navItem.leftBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)
        navBar.isTranslucent = false
        navBar.barStyle = .black
        navBar.barTintColor = ReminderStandardViewController.GetCurrentBackGroundThemeColor().MainColor
        self.view.addSubview(navBar)
    }
    
    private let MenuVC=MenuBarViewController()
    private let MenuTransit=MenuTransitioning()
    
    
    @objc override func stop(){
        
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let MenuVC=storyboard.instantiateViewController(withIdentifier: "MenuBar") as! MenuBarViewController
        MenuVC.CurrentFeature=4
        MenuVC.transitioningDelegate=MenuTransit
        present(MenuVC, animated: true, completion: nil)
    }
    

    @objc override func handleLogin() {
        guard let email = emailTextField.text, let password = passwordTextField.text else {
            print("form is not valid")
            return
        }
        Auth.auth().signIn(withEmail: email, password: password, completion: ({ (user, error) in
            if error != nil {
                print(error ?? "err")
                return
            }
            self.userVC?.updateUI()
            MenuBarViewController.checkUserPrioority()
            self.Login()
        })
        )
    }
    
    override func handleRegister() {
        guard let email = emailTextField.text, let password = passwordTextField.text, let name = nameTextField.text else {
            print("form is not valid")
            return
        }
        Auth.auth().createUser(withEmail: email, password: password, completion: ({ (user: User?, error) in
            if error != nil {
                print(error ?? "err")
                return
            }
            
            guard let uid = user?.uid else {
                return
            }
            
            // successfully authenticated user
            
            // unique id created by
            let imageName = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.profileImageView.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                
                storageRef.putData(uploadData, metadata: nil, completion: {(metadata, error) in
                    if error != nil {
                        print(error ?? "err")
                        return
                    }
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                        let values = ["name": name, "email": email,
                                      "profileImageURL": profileImageURL,
                                      "created": NSDate().stringValue,
                                      "notes_done": 0, "status" : "regular", "uid" : uid] as [String : Any]
                        
                        self.registerUserIntoDataBaseWithUIDInMenu(uid: uid, values: values)
                    }
                    
                })
            }
        })
        )
    }
    
    
    func registerUserIntoDataBaseWithUIDInMenu(uid: String, values: [String : Any]) {
        let ref = Database.database().reference(fromURL: "https://cs309gkb2.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err ?? "err")
                return
            }
            
            self.userVC?.updateUI()
            ShoppingListServerObject.NewUser(uid)
            self.Login()
        })
    }
    
    let NewFeatureTransit=NewFeatureTransitioning()
    func Login(){
        let storyboard = UIStoryboard(name: "Main", bundle: nil)
        let ProfileVC=storyboard.instantiateViewController(withIdentifier: "MenuProfileEditor")
        
        ProfileVC.transitioningDelegate=NewFeatureTransit
        present(ProfileVC, animated: true, completion: nil)
        
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
