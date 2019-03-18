//
//  ChatLogController.swift
//  Reminder
//
//  Created by Yijia Huang on 10/12/17.
//  Copyright © 2017 Yi Huang. All rights reserved.
//

import UIKit
import Firebase

/// chat log view controller
class ChatLogController: ReminderSTandardUICollectionViewController, UITextFieldDelegate, UICollectionViewDelegateFlowLayout, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    // MARK: - Variables
    /// chat partner
    var chatPartner: FbUser? {
        didSet {
            navigationItem.title = chatPartner?.name
        }
    }
    
    var curGroup: FbGroup?
    
    /// chat messages
    var userMessages = [FbMessage]()
    
    /// messages' addresses
    var userMessageAddress = [ToUserMessageAddress]()
    
    // MARK: - Methods
    /// load messages in the table view
    func observeMessages() {
        let uid = Auth.auth().currentUser?.uid
        let toId = chatPartner != nil ? chatPartner?.userId : curGroup?.gid; DatabaseService.shared.userMessageRef.child(uid!).child(toId!).observe(.value, with: { (snapshot) in
            if snapshot.exists() {
                guard let userMessagesSnapshot = UserMessageSnapshot(withP2P: snapshot) else { return }
                self.userMessageAddress = userMessagesSnapshot.userMessageAddress
                DatabaseService.shared.messageRef.observe(.value, with: { (snapshot) in
                    guard let userMsgs = MessageSnapshot(with: snapshot, at: self.userMessageAddress) else { return }
                    self.userMessages = userMsgs.userMsgs
                    self.userMessages.sort(by: { (m1, m2) -> Bool in
                        return m1.timestamp! < m2.timestamp!
                    })
                    self.collectionView?.reloadData()
                    // scroll to the last index
                    let indexPath = IndexPath(item: self.userMessages.count - 1, section: 0)
                    self.collectionView?.scrollToItem(at: indexPath, at: .bottom, animated: true)
                }, withCancel: nil)
            } else {
                
            }
        }, withCancel: nil)
    }
        
        /// message controller
        var msgController: MessagesController?
        
        /// input text field
        @objc lazy var inputTextField: UITextField = {
            let tf = UITextField()
            tf.placeholder = "Enter message"
            tf.translatesAutoresizingMaskIntoConstraints = false
            tf.delegate = self
            return tf
        }()
        
        /// cell id
        let cellId = "cellId"
        
        /// Called after the controller's view is loaded into memory.
        override func viewDidLoad() {
            super.viewDidLoad()
            
            tabBarController?.tabBar.isHidden = true
            
            // important! gaps between each chat block
            collectionView?.contentInset = UIEdgeInsets(top: 8, left: 0, bottom: 58, right: 0)
            collectionView?.scrollIndicatorInsets = UIEdgeInsets(top: 0, left: 0, bottom: 50, right: 0)
            collectionView?.backgroundColor = UIColor.clear
            collectionView?.register(ChatMessageCell.self, forCellWithReuseIdentifier: cellId)
            collectionView?.alwaysBounceVertical = true
            
            collectionView?.keyboardDismissMode = .interactive
            setupInputComponents()
            setupKeyboardObservers()
            
            if curGroup != nil {
                navigationItem.title = "Group Chat"
            }
            observeMessages()
        }
        
        /// set up keyboard observers, and let input text field moves as keyboard pops up
        func setupKeyboardObservers() {
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardDidShow), name: NSNotification.Name.UIKeyboardDidShow, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillShow), name: NSNotification.Name.UIKeyboardWillShow, object: nil)
            
            NotificationCenter.default.addObserver(self, selector: #selector(handleKeyboardWillHide), name: NSNotification.Name.UIKeyboardWillHide, object: nil)
        }
        
        /// Notifies the view controller that its view was removed from a view hierarchy.
        ///
        /// - Parameter animated: animated bool
        override func viewDidDisappear(_ animated: Bool) {
            super.viewDidDisappear(animated)
            // important for removing the observer
            NotificationCenter.default.removeObserver(self)
        }
        
        /// handle when keyboard pops up
        @objc func handleKeyboardDidShow() {
            if userMessages.count > 0 {
                let indexPath = IndexPath(item: userMessages.count - 1, section: 0)
                collectionView?.scrollToItem(at: indexPath, at: .top, animated: true)
            }
        }
        
        /// hande keyboard will show
        ///
        /// - Parameter notification: notification
        @objc func handleKeyboardWillShow(notification: NSNotification) {
            let userInfo = notification.userInfo!
            let keyboardScreenEndFrame = (userInfo[UIKeyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
            let keyboardFrame = view.convert(keyboardScreenEndFrame, from: view.window)
            let keyboardDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            // move up input area
            containerViewBottomAnchor?.constant = -keyboardFrame.height
            UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded()
            }
        }
        
        /// handle keyboard will hide
        ///
        /// - Parameter notification: notification
        @objc func handleKeyboardWillHide(notification: NSNotification) {
            let userInfo = notification.userInfo!
            let keyboardDuration = userInfo[UIKeyboardAnimationDurationUserInfoKey] as! Double
            // move down input area
            containerViewBottomAnchor?.constant = 0
            UIView.animate(withDuration: keyboardDuration) {
                self.view.layoutIfNeeded()
            }
        }
        
        /// Asks your data source object for the number of items in the specified section.
        ///
        /// - Parameters:
        ///   - collectionView: collection view
        ///   - section: section
        /// - Returns: numbers of items in the section
        override func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
            return userMessages.count
        }
        
        /// Asks your data source object for the cell that corresponds to the specified item in the collection view.
        ///
        /// - Parameters:
        ///   - collectionView: collection view
        ///   - indexPath: index path
        /// - Returns: view cell
        override func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
            let cell = collectionView.dequeueReusableCell(withReuseIdentifier: cellId, for: indexPath) as! ChatMessageCell
            let message = userMessages[indexPath.item]
            setupCell(cell: cell, message: message)
            return cell
        }
        
        /// setup cell
        ///
        /// - Parameters:
        ///   - cell: cell
        ///   - message: message
        private func setupCell(cell: ChatMessageCell, message: FbMessage) {
            cell.textView.text = message.text
            if message.text != nil {
                cell.bubbleWidthAnchor?.constant = estimateFrameForText(text: message.text!).width + 32
            } else if message.imageURL != nil {
                cell.bubbleWidthAnchor?.constant = 200
            }
            if chatPartner != nil {
                if let profileImageURL = self.chatPartner?.profileImageURL {
                    cell.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageURL)
                }
            } else {
                let userRef = DatabaseService.shared.userRef.child(message.fromId!)
                userRef.observe(.value, with: { (snapshot) in
                    if let dictionary = snapshot.value as? [String: Any] {
                        if let profileImageURL = dictionary["profileImageURL"] as? String {
                        cell.profileImageView.loadImageUsingCacheWithURLString(urlString: profileImageURL)
                        }
                    }
                })
            }
            if message.fromId == Auth.auth().currentUser?.uid {
                //outgoing blue
                cell.bubbleView.backgroundColor = ChatMessageCell.blueColor
                cell.textView.textColor = UIColor.white
                cell.profileImageView.isHidden = true
                
                cell.bubbleViewRightAnchor?.isActive = true
                cell.bubbleViewLeftAnchor?.isActive = false
            } else {
                // gray
                cell.bubbleView.backgroundColor = ChatMessageCell.grayColor
                cell.textView.textColor = UIColor.white
                cell.profileImageView.isHidden = false
                
                cell.bubbleViewRightAnchor?.isActive = false
                cell.bubbleViewLeftAnchor?.isActive = true
            }
            if let messageImageURL = message.imageURL {
                cell.messageImageView.loadImageUsingCacheWithURLString(urlString: messageImageURL)
                cell.messageImageView.isHidden = false
                cell.bubbleView.backgroundColor = UIColor.clear
            } else {
                cell.messageImageView.isHidden = true
                cell.bubbleView.isHidden = false
            }
        }
        
        /// Notifies the container that the size of its view is about to change.
        ///
        /// - Parameters:
        ///   - size: container size
        ///   - coordinator: coordinator
        override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
            collectionView?.collectionViewLayout.invalidateLayout()
        }
        
        /// Asks the delegate for the size of the specified item’s cell.
        ///
        /// - Parameters:
        ///   - collectionView: collection view
        ///   - collectionViewLayout: layout
        ///   - indexPath: index path
        /// - Returns: size
        func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
            var height: CGFloat = 80
            let message = userMessages[indexPath.item]
            if let text = message.text {
                height = estimateFrameForText(text: text).height + 20
            } else if let imageWidth = message.imageWidth?.floatValue, let imageHeight = message.imageHeight?.floatValue {
                // h1/w1 = h2/w2
                height = CGFloat(imageHeight / imageWidth * 200)
            }
            let width = UIScreen.main.bounds.width
            return CGSize(width: width, height: height)
        }
        
        /// estimate frame of the input text
        ///
        /// - Parameter text: input text
        /// - Returns: frame of input text
        private func estimateFrameForText(text: String) -> CGRect {
            let size = CGSize(width: 200, height: 1000)
            let options = NSStringDrawingOptions.usesFontLeading.union(.usesLineFragmentOrigin)
            return NSString(string: text).boundingRect(with: size, options: options, attributes: [NSAttributedStringKey.font: UIFont.systemFont(ofSize: 16)], context: nil)
        }
        
        /// container bottom anchor
        var containerViewBottomAnchor: NSLayoutConstraint?
        
        /// setup input components
        @objc func setupInputComponents() {
            let containerView = UIView()
            containerView.backgroundColor = ReminderStandardViewController.GetCurrentBackGroundThemeColor().MainColor
            containerView.translatesAutoresizingMaskIntoConstraints = false
            
            view.addSubview(containerView)
            
            //x, y, w, h
            containerView.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            containerViewBottomAnchor = containerView.bottomAnchor.constraint(equalTo: view.bottomAnchor)
            containerViewBottomAnchor?.isActive = true
            containerView.widthAnchor.constraint(equalTo: view.widthAnchor).isActive = true
            containerView.heightAnchor.constraint(equalToConstant: 50).isActive = true
            
            let uploadImageView = UIImageView()
            uploadImageView.isUserInteractionEnabled = true
            uploadImageView.image = UIImage(named: "icons8-add-image (2)")
            uploadImageView.translatesAutoresizingMaskIntoConstraints = false
            uploadImageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handleUploadTap)))
            containerView.addSubview(uploadImageView)
            //x, y, w, h
            uploadImageView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            uploadImageView.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            uploadImageView.widthAnchor.constraint(equalToConstant: 40).isActive = true
            uploadImageView.heightAnchor.constraint(equalToConstant: 40).isActive = true
            
            let sendButton = UIButton(type: .system)
            sendButton.setTitle("Send", for: .normal)
            sendButton.translatesAutoresizingMaskIntoConstraints = false
            sendButton.addTarget(self, action: #selector(handleSend), for: .touchUpInside)
            containerView.addSubview(sendButton)
            
            // xywh
            sendButton.rightAnchor.constraint(equalTo: containerView.rightAnchor).isActive = true
            sendButton.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            sendButton.widthAnchor.constraint(equalToConstant: 80).isActive = true
            sendButton.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
            
            
            containerView.addSubview(inputTextField)
            
            //xywh
            inputTextField.leftAnchor.constraint(equalTo: uploadImageView.rightAnchor, constant: 8).isActive = true
            inputTextField.centerYAnchor.constraint(equalTo: containerView.centerYAnchor).isActive = true
            //        inputTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
            inputTextField.rightAnchor.constraint(equalTo: sendButton.leftAnchor).isActive = true
            inputTextField.heightAnchor.constraint(equalTo: containerView.heightAnchor).isActive = true
            
            let separatorLineView = UIView()
            separatorLineView.backgroundColor = UIColor.lightGray
            separatorLineView.translatesAutoresizingMaskIntoConstraints = false
            containerView.addSubview(separatorLineView)
            
            //xywh
            separatorLineView.leftAnchor.constraint(equalTo: containerView.leftAnchor).isActive = true
            separatorLineView.topAnchor.constraint(equalTo: containerView.topAnchor).isActive = true
            separatorLineView.widthAnchor.constraint(equalTo: containerView.widthAnchor).isActive = true
            separatorLineView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        }
        
        /// handle upload tap
        @objc func handleUploadTap() {
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
        ///   - picker: picker
        ///   - info: info
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
            var selectedImageFromPicker: UIImage?
            
            if let editedImage = info["UIImagePickerControllerEditedImage"] as? UIImage {
                selectedImageFromPicker = editedImage
            } else if let originalImage = info["UIImagePickerControllerOriginalImage"] as? UIImage {
                selectedImageFromPicker = originalImage
            }
            
            if let selectedImage = selectedImageFromPicker {
                uploadToFireBaseStrogageUsingImage(image: selectedImage)
            }
            dismiss(animated: true, completion: nil)
        }
        
        /// upload meta data to firebase strogage
        ///
        /// - Parameter image: image data
        private func uploadToFireBaseStrogageUsingImage(image: UIImage) {
            let imageName = NSUUID().uuidString
            let ref = Storage.storage().reference().child("message_images").child(imageName)
            if let uploadData = UIImageJPEGRepresentation(image, 0.2) {
                ref.putData(uploadData, metadata: nil, completion: { (metadata, error) in
                    if error != nil {
                        print("failed to upload image ", error ?? "err")
                        return
                    }
                    if let imageURL = metadata?.downloadURL()?.absoluteString {
                        self.sendMsgWithImageURL(imageURL: imageURL, image: image)
                        print("upload to firebase")
                    }
                })
            }
        }
        
        /// send image message
        ///
        /// - Parameters:
        ///   - imageURL: image url
        ///   - image: image data
        private func sendMsgWithImageURL(imageURL: String, image: UIImage) {
            let ref = Database.database().reference().child("messages")
            let childRef = ref.childByAutoId()
            let toId = chatPartner != nil ? chatPartner?.userId! : curGroup?.gid
            let fromId = Auth.auth().currentUser?.uid
            let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000.0)
            let values: [String : Any]?
            if chatPartner != nil {
            values = ["imageURL": imageURL, "imageWidth": image.size.width, "imageHeight": image.size.height, "toId": toId!, "fromId": fromId!, "timestamp": timestamp] as [String : Any]
            } else {
            values = ["imageURL": imageURL, "imageWidth": image.size.width, "imageHeight": image.size.height, "toId": toId!, "fromId": fromId!, "timestamp": timestamp, "groupName" : (curGroup?.name)!] as [String : Any]
            }
            childRef.updateChildValues(values as Any as! [String : Any])
            if chatPartner != nil {
                setupUserMessagesNodes(primaryId: fromId!, secondrayId: toId!, messageId: childRef.key, timestamp: timestamp)
                setupUserMessagesNodes(primaryId: toId!, secondrayId: fromId!, messageId: childRef.key, timestamp: timestamp)
            } else {
                let groupMemberRef = DatabaseService.shared.groupRef.child((curGroup?.gid)!).child("groupMember")
                groupMemberRef.observe(DataEventType.value, with: { (snapshot) in
                    if snapshot.exists() {
                    self.userIds = UserIdsSnapshot(with: snapshot)?.userIds
                    for id in self.userIds! {
                        self.setupUserMessagesNodes(primaryId: id, secondrayId: toId!, messageId: childRef.key, timestamp: timestamp)
                    }
                    }
                })
                
            }
            inputTextField.text = nil
            inputTextField.resignFirstResponder()
        }
        
        /// Tells the delegate that the user cancelled the pick operation.
        ///
        /// - Parameter picker: picker controller
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            dismiss(animated: true, completion: nil)
        }
        
        /// user ids
        var userIds: [String]?
        
        /// handle send button
        @objc func handleSend() {
            if inputTextField.text != "" {
                let ref = Database.database().reference().child("messages")
                let childRef = ref.childByAutoId()
                let toId = chatPartner != nil ? chatPartner?.userId! : curGroup?.gid
                let fromId = Auth.auth().currentUser?.uid
                let timestamp = Int64(NSDate().timeIntervalSince1970 * 1000.0)
                let values: [String : Any]?
                if chatPartner != nil {
                values = ["text": inputTextField.text!, "toId": toId!, "fromId": fromId!, "timestamp": timestamp] as [String : Any]
                } else {
                    values = ["text": inputTextField.text!, "toId": toId!, "fromId": fromId!, "timestamp": timestamp, "groupName" : (curGroup?.name)!] as [String : Any]
                }
                childRef.updateChildValues(values as Any as! [String : Any])
                if chatPartner != nil {
                    setupUserMessagesNodes(primaryId: fromId!, secondrayId: toId!, messageId: childRef.key, timestamp: timestamp)
                    setupUserMessagesNodes(primaryId: toId!, secondrayId: fromId!, messageId: childRef.key, timestamp: timestamp)
                } else {
                    let groupMemberRef = DatabaseService.shared.groupRef.child((curGroup?.gid)!).child("groupMember")
                    groupMemberRef.observe(DataEventType.value, with: { (snapshot) in
                        if snapshot.exists() {
                        self.userIds = UserIdsSnapshot(with: snapshot)?.userIds
                        for id in self.userIds! {
                            self.setupUserMessagesNodes(primaryId: id, secondrayId: toId!, messageId: childRef.key, timestamp: timestamp)
                        }
                        }
                    })
                    
                }
            }
            inputTextField.text = nil
            inputTextField.resignFirstResponder()
        }
        
        /// setup user message nodes
        ///
        /// - Parameters:
        ///   - primaryId: from id
        ///   - secondrayId: to id
        ///   - messageId: message id
        ///   - timestamp: time stamp
        func setupUserMessagesNodes(primaryId: String, secondrayId: String, messageId: String, timestamp: Int64) {
            DatabaseService.shared.userMessageRef.child(primaryId).child(secondrayId).updateChildValues([messageId : timestamp])
        }
        
        /// Asks the delegate if the text field should process the pressing of the return button.
        ///
        /// - Parameter textField: input text field
        /// - Returns: true if return is pressed
        func textFieldShouldReturn(_ textField: UITextField) -> Bool {
            handleSend()
            return true
        }
        
        /// Tells the delegate when the scroll view is about to start scrolling the content.
        ///
        /// - Parameter scrollView: scroll view
        override func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
            inputTextField.resignFirstResponder()
        }
    }
    
    /// chat message cell
    class ChatMessageCell: UICollectionViewCell {
        // MARK: - Variables
        /// input text filed view
        let textView: UITextView = {
            let tv = UITextView()
            tv.text = "fdsafda"
            tv.font = UIFont.systemFont(ofSize: 16)
            tv.textColor = UIColor.white
            tv.translatesAutoresizingMaskIntoConstraints = false
            tv.backgroundColor = UIColor.clear
            tv.isEditable = false
            return tv
        }()
        
        /// blue color
        static let blueColor = UIColor(red:0.30, green:0.52, blue:0.86, alpha:1.0)
        
        /// gray color
        static let grayColor = UIColor(red:0.62, green:0.68, blue:0.77, alpha:1.0)
        
        /// bubble view
        let bubbleView: UIView = {
            let view = UIView()
            view.backgroundColor = blueColor
            view.translatesAutoresizingMaskIntoConstraints = false
            view.layer.cornerRadius = 16
            view.layer.masksToBounds = true
            return view
        }()
        
        /// profile image view
        let profileImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 16
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        /// image message view
        let messageImageView: UIImageView = {
            let imageView = UIImageView()
            imageView.translatesAutoresizingMaskIntoConstraints = false
            imageView.layer.cornerRadius = 16
            imageView.layer.masksToBounds = true
            imageView.contentMode = .scaleAspectFill
            return imageView
        }()
        
        /// bubble with anchor
        var bubbleWidthAnchor: NSLayoutConstraint?
        
        /// bubble view right anchor
        var bubbleViewRightAnchor: NSLayoutConstraint?
        
        /// bubble view left anchor
        var bubbleViewLeftAnchor: NSLayoutConstraint?
        
        // MARK: - Methods
        /// Initializes and returns a newly allocated view object with the specified frame rectangle.
        ///
        /// - Parameter frame: frame size
        override init(frame: CGRect) {
            super.init(frame: frame)
            addSubview(bubbleView)
            addSubview(textView)
            addSubview(profileImageView)
            
            bubbleView.addSubview(messageImageView)
            messageImageView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor).isActive = true
            messageImageView.topAnchor.constraint(equalTo: bubbleView.topAnchor).isActive = true
            messageImageView.widthAnchor.constraint(equalTo: bubbleView.widthAnchor).isActive = true
            messageImageView.heightAnchor.constraint(equalTo: bubbleView.heightAnchor).isActive = true
            
            //xywh
            profileImageView.leftAnchor.constraint(equalTo: self.leftAnchor, constant: 8).isActive = true
            profileImageView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            profileImageView.widthAnchor.constraint(equalToConstant: 32).isActive = true
            profileImageView.heightAnchor.constraint(equalToConstant: 32).isActive = true
            
            //xywh
            bubbleViewRightAnchor = bubbleView.rightAnchor.constraint(equalTo: self.rightAnchor, constant: -8)
            bubbleViewRightAnchor?.isActive = true
            
            bubbleViewLeftAnchor = bubbleView.leftAnchor.constraint(equalTo: profileImageView.rightAnchor, constant: 8)
            bubbleViewLeftAnchor?.isActive = false
            
            bubbleView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            bubbleWidthAnchor = bubbleView.widthAnchor.constraint(equalToConstant: 200)
            bubbleWidthAnchor?.isActive = true
            bubbleView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
            
            //xywh
            //        textView.rightAnchor.constraint(equalTo: self.rightAnchor).isActive = true
            textView.leftAnchor.constraint(equalTo: bubbleView.leftAnchor, constant: 8).isActive = true
            textView.topAnchor.constraint(equalTo: self.topAnchor).isActive = true
            //        textView.widthAnchor.constraint(equalToConstant: 200).isActive = true
            textView.rightAnchor.constraint(equalTo: bubbleView.rightAnchor).isActive = true
            textView.heightAnchor.constraint(equalTo: self.heightAnchor).isActive = true
        }
        
        required init?(coder aDecoder: NSCoder) {
            fatalError("init has bot been implemented")
        }
}




































