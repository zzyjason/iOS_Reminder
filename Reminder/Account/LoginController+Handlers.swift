//
//  LoginController+Handlers.swift
//  Reminder
//
//  Created by Yijia Huang on 10/7/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//

import UIKit
import Firebase

// MARK: - UIImagePickerControllerDelegate, UINavigationControllerDelegate
extension LoginViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Methods
    /// handle register
    @objc func handleRegister() {
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
                        
                        self.registerUserIntoDataBaseWithUID(uid: uid, values: values)
                    }
                    
                })
            }
        })
        )
    }
    
    /// register user into firebase database with uid
    ///
    /// - Parameters:
    ///   - uid: user id
    ///   - values: attributes of a user
    private func registerUserIntoDataBaseWithUID(uid: String, values: [String : Any]) {
        let ref = Database.database().reference(fromURL: "https://cs309gkb2.firebaseio.com/")
        let userReference = ref.child("users").child(uid)
        userReference.updateChildValues(values, withCompletionBlock: { (err, ref) in
            if err != nil {
                print(err ?? "err")
                return
            }
            
            self.userVC?.updateUI()
            ShoppingListServerObject.NewUser(uid)
            self.dismiss(animated: true, completion: nil)
        })
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
            profileImageView.image = selectedImage
        }
        dismiss(animated: true, completion: nil)
    }
    
    /// Tells the delegate that the user cancelled the pick operation.
    ///
    /// - Parameter picker: picker controller
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        print("canceled picker")
        dismiss(animated: true, completion: nil)
    }
    
}
