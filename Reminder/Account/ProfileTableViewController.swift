//
//  ProfileTableViewController.swift
//  Reminder
//
//  Created by Yijia Huang on 11/27/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//

import UIKit
import Firebase

/// profile editor table view controller
class ProfileTableViewController: ReminderStandardTableViewController, UIPickerViewDelegate, UIPickerViewDataSource, UIImagePickerControllerDelegate, UINavigationControllerDelegate, UITextFieldDelegate {
    
    
    // MARK: - Variables
    /// user image
    @IBOutlet weak var userImage: UIImageView!
    
    /// user name
    @IBOutlet weak var userNameTF: UITextField!

    
    /// user email
    @IBOutlet weak var userEmailTF: UITextField!
    
    /// user password
    @IBOutlet weak var userPasswordTF: UITextField!
    
    /// user status
    @IBOutlet weak var userStatus: UITextField!
    {
        didSet{
            userStatus.addToolbar(DoneButton: true, CancelButton: false, AddCategory: false)
        }
    }
    
    /// save buttion
    ///
    /// - Parameter sender: sender data
    @IBAction func saveBut(_ sender: Any) {
        saveImage()
    }
    
    /// current user
    let user = Auth.auth().currentUser
    
    /// user firebase reference
    let userRef = DatabaseService.shared.userRef.child((Auth.auth().currentUser?.uid)!)
    
    /// account view controller
    var userVC: UserViewController?
    
    // MARK: - Methods
    /// check old email and password for crefential
    ///
    /// - Parameters:
    ///   - email: user email
    ///   - password: user password
    ///   - profileImageURL: user image url
    func checkEmailPassword(email: String?, password: String?, profileImageURL: String?) {
        
        if email != nil && password != nil {
            let credential = EmailAuthProvider.credential(withEmail: email!, password: password!)
            user?.reauthenticate(with: credential, completion: { (error) in
                if let err = error {
                    print(err.localizedDescription)
                    self.alert(msg: "Cannot resign in check your old email and old password")
                } else {
                    
                    self.user?.updateEmail(to: self.userEmailTF.text!, completion: { (error) in
                        if let err = error {
                            print(err.localizedDescription)
                            let alert = UIAlertController(title: "Error", message: "Check your email format", preferredStyle: UIAlertControllerStyle.alert)
                            alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                                alert.dismiss(animated: true, completion: nil)
                            }))
                            self.present(alert, animated: true, completion: nil)
                        } else {
                            if self.userPasswordTF.text == nil || self.userPasswordTF.text == "" {
                                self.userRef.updateChildValues(["email": self.userEmailTF.text!,
                                                                "name" : self.userNameTF.text!,
                                                                "status" : self.userStatus.text!])
                                if profileImageURL != nil {
                                    self.userRef.updateChildValues(["profileImageURL": profileImageURL!])
                                }
                                self.alert(msg: "Your account info is updated")
                                self.updateNavigationBar()
                            } else {
                            self.user?.updatePassword(to: self.userPasswordTF.text!, completion: { (error) in
                                if let err = error {
                                    print(err.localizedDescription)
                                    let alert = UIAlertController(title: "Error", message: "Check your password format", preferredStyle: UIAlertControllerStyle.alert)
                                    alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
                                        alert.dismiss(animated: true, completion: nil)
                                    }))
                                    self.present(alert, animated: true, completion: nil)
                                } else {
                                    self.userRef.updateChildValues(["email": self.userEmailTF.text!,
                                                                    "name" : self.userNameTF.text!,
                                                                    "status" : self.userStatus.text!])
                                    if profileImageURL != nil {
                                        self.userRef.updateChildValues(["profileImageURL": profileImageURL!])
                                    }
                                    self.alert(msg: "Your account info is updated")
                                    MenuBarViewController.checkUserPrioority()
                                    self.updateNavigationBar()
                                    
                                    
                                }
                            })
                            }
                        }
                    })
                }
            })
        }
    }
    
    /// save image if needed
    func saveImage() {
        if imageIsChanged! {
            let imageName = NSUUID().uuidString
            
            let storageRef = Storage.storage().reference().child("profile_images").child("\(imageName).jpg")
            
            if let profileImage = self.userImage.image, let uploadData = UIImageJPEGRepresentation(profileImage, 0.1) {
                storageRef.putData(uploadData, metadata: nil, completion: {(metadata, error) in
                    if error != nil {
                        print(error ?? "err")
                        return
                    }
                    if let profileImageURL = metadata?.downloadURL()?.absoluteString {
                        self.saveOthers(profileImageURL: profileImageURL)
                    }
                })
            }
            imageIsChanged = false
        } else {
            self.saveOthers(profileImageURL: nil)
        }
    }
    
    /// save other user info
    ///
    /// - Parameter profileImageURL: user image url
    func saveOthers(profileImageURL: String?) {
        let alertController = UIAlertController(title: "Resign in please", message: nil, preferredStyle: .alert)
        
        let confirmAction = UIAlertAction(title: "Confirm", style: .default) { (_) in
            self.checkEmailPassword(email: alertController.textFields?[0].text, password: alertController.textFields?[1].text, profileImageURL: profileImageURL)
        }
        
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel) { (_) in }
        
        alertController.addTextField { (textField) in
            textField.placeholder = "Old Email"
        }
        alertController.addTextField { (textField) in
            textField.placeholder = "Old Password"
            textField.isSecureTextEntry = true
        }
        
        alertController.addAction(confirmAction)
        alertController.addAction(cancelAction)
        
        self.present(alertController, animated: true, completion: nil)
    }
    
    /// send alert
    ///
    /// - Parameter msg: alert message
    func alert(msg: String) {
        let alert = UIAlertController(title: msg, message: nil, preferredStyle: UIAlertControllerStyle.alert)
        alert.addAction(UIAlertAction(title: "OK", style: UIAlertActionStyle.default, handler: { (action) in
            alert.dismiss(animated: true, completion: nil)
        }))
        self.present(alert, animated: true, completion: nil)
    }
    
    /// update navigation bar
    func updateNavigationBar() {
        userVC?.cleanNaviBar()
        userVC?.updateUI()
    }
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        initVar()
    }
    
    /// user status arr
    var status = ["regular", "VIP", "Administrator"]
    
    /// picker view
    var pickerView: UIPickerView?
    
    /// initialize variables
    func initVar() {
        userNameTF.delegate = self
        userEmailTF.delegate = self
        userPasswordTF.delegate = self
        userPasswordTF.isSecureTextEntry = true
        userStatus.delegate = self
        imageIsChanged = false
        userRef.observe(DataEventType.value) { (snapshot) in
            let user = FbUser(uid: (self.user?.uid)!, dict: (snapshot.value as! [String : Any]))
            self.userNameTF.text = user?.name
            self.userEmailTF.text = user?.email
            self.userImage.loadImageUsingCacheWithURLString(urlString: (user?.profileImageURL)!)
            self.userStatus.text = user?.status
        }
        
        pickerView = UIPickerView()
        pickerView?.delegate = self
        pickerView?.dataSource = self
        pickerView?.backgroundColor = UIColor.black
        userStatus.inputView = pickerView

    }
    
    /// Asks the delegate if the text field should process the pressing of the return button.
    ///
    /// - Parameter textField: text field
    /// - Returns: true if return is pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    /// Tells the delegate when the scroll view is about to start scrolling the content.
    ///
    /// - Parameter scrollView: scroll view
    override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        userEmailTF.resignFirstResponder()
        userNameTF.resignFirstResponder()
        userPasswordTF.resignFirstResponder()
        userStatus.resignFirstResponder()
    }
    
    /// Tells the delegate that the specified row is now selected.
    ///
    /// - Parameters:
    ///   - tableView: table view
    ///   - indexPath: index path
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        if indexPath.section == 0 && indexPath.row == 0 {
            handgleSelectProfileImageView()
        }
    }
    
    /// handle choose user image
    @objc func handgleSelectProfileImageView() {
        let sheet = UIAlertController(title: "Choose Your Profile Image", message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel, handler: nil)
        let photoLib = UIAlertAction(title: "Photo Library", style: .default) {
            (action: UIAlertAction) -> Void in
            self.chooseImageFromLibrary()
        }
        let camera = UIAlertAction(title: "Camera", style: .default) {
            (action: UIAlertAction) -> Void in
            self.cameraImage()
        }
        sheet.addAction(cancelAction)
        sheet.addAction(photoLib)
        sheet.addAction(camera)
        self.present(sheet, animated: true, completion: nil)
    }
    
    /// choose image from library
    func chooseImageFromLibrary() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    /// choose image from camera
    func cameraImage() {
        let picker = UIImagePickerController()
        picker.delegate = self
        picker.sourceType = .camera
        picker.allowsEditing = true
        present(picker, animated: true, completion: nil)
    }
    
    /// image is changed
    var imageIsChanged: Bool?
    
    /// Tells the delegate that the user picked a still image or movie.
    ///
    /// - Parameters:
    ///   - picker: picker controller
    ///   - info: info
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
        
        var selectedImageFromPicker: UIImage?
        
        if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
            selectedImageFromPicker = editedImage
        } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
            selectedImageFromPicker = originalImage
        }
        
        if let selectedImage = selectedImageFromPicker {
            userImage.image = selectedImage
            imageIsChanged = true
        }
        stop()
    }
    
    /// Tells the delegate that the user cancelled the pick operation.
    ///
    /// - Parameter picker: picker controller
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        stop()
    }
    
    /// dimiss current view
    func stop() {
        dismiss(animated: true, completion: nil)
    }
    
    /// dimiss keyboard
    ///
    /// - Parameter guesture: gesture
    func dismissKeyboard(guesture: UIGestureRecognizer) {
        self.view.endEditing(true)
    }
    
    /// Called by the picker view when it needs the title to use for a given row in a given component.
    ///
    /// - Parameters:
    ///   - pickerView: picker view
    ///   - row: row
    ///   - component: component
    /// - Returns: chosen status
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return status[row]
    }
    
    /// Called by the picker view when the user selects a row in a component.
    ///
    /// - Parameters:
    ///   - pickerView: picker view
    ///   - row: row
    ///   - component: component
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        userStatus.text = status[row]
    }
    
    /// Called by the picker view when it needs the number of rows for a specified component.
    ///
    /// - Parameters:
    ///   - pickerView: picker view
    ///   - component: component
    /// - Returns: number of all status
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return status.count
    }
    
    /// Called by the picker view when it needs the styled title to use for a given row in a given component.
    ///
    /// - Parameters:
    ///   - pickerView: picker view
    ///   - row: row
    ///   - component: component
    /// - Returns: attributed string
    func pickerView(_ pickerView: UIPickerView, attributedTitleForRow row: Int, forComponent component: Int) -> NSAttributedString? {
        let title = NSAttributedString(string: status[row], attributes: [NSAttributedStringKey.foregroundColor : UIColor.white])
        return title
    }
    
    /// number of components
    ///
    /// - Parameter pickerView: picker view
    /// - Returns: number of components
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    
    @IBAction func TryLogOut(_ sender: Any) {
        Logout()
    }
    
    
    var NewFeatureTransit=NewFeatureTransitioning()
    
    func Logout(){
        try? Auth.auth().signOut()
        if(Auth.auth().currentUser?.uid==nil)
        {
            var LoginVC:UIViewController
            LoginVC=MenuAccountLoginViewController()
            LoginVC.transitioningDelegate=NewFeatureTransit
            present(LoginVC, animated: true, completion: nil)
        }
    }
    

}






















