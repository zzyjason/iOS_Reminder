//
//  LoginViewController.swift
//  Reminder
//
//  Created by Yijia Huang on 10/5/17.
//  Copyright © 2017 Yijia Huang. All rights reserved.
//

import UIKit
import Firebase

/// login & register view controller
class LoginViewController: ReminderStandardViewController {
    
    override func awakeFromNib() {
        super.awakeFromNib()

    }
    
    
    // MARK: - Variables
    /// account view controller
    @objc var userVC: UserViewController?
    
    /// input container view
    @objc let inputsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        view.layer.cornerRadius = 5
        view.layer.masksToBounds = true
        return view
    }()
    
    /// login buttion
    @objc let loginRegisterButton: UIButton = {
        let button = UIButton(type: UIButtonType.system)
        // todo
        button.backgroundColor = UIColor.init(red:0.59, green:0.89, blue:0.78, alpha:1.0)
        button.setTitle("Register", for: UIControlState.normal)
        button.setTitleColor(UIColor.white, for: .normal)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16)
        button.translatesAutoresizingMaskIntoConstraints = false
        
        button.addTarget(self, action: #selector(handleLoginRegister), for: .touchUpInside)
        
        return button
    }()
    
    /// handle login & register
    @objc func handleLoginRegister() {
        if loginRegisterSegmentedControl.selectedSegmentIndex == 0 {
            handleLogin()
        } else {
            handleRegister()
        }
    }
    
    
    
    /// profile default image
    var profileDefaultImage: [UIImage] = [#imageLiteral(resourceName: "al"), #imageLiteral(resourceName: "ft"), #imageLiteral(resourceName: "hy"), #imageLiteral(resourceName: "ra"), #imageLiteral(resourceName: "te"), #imageLiteral(resourceName: "zerg")]
    
    /// index
    var randIdx: Int?
    
    /// profile image view
    @objc lazy var profileImageView: UIImageView = {
        randIdx = Int(arc4random_uniform(6))
        let imageView = UIImageView()
        imageView.image = profileDefaultImage[randIdx!].withRenderingMode(UIImageRenderingMode.alwaysTemplate)
        imageView.tintColor = UIColor.init(red:0.61, green:0.45, blue:0.71, alpha:1.0)
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.contentMode = .scaleAspectFit
        //
        imageView.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(handgleSelectProfileImageView)))
        imageView.isUserInteractionEnabled = true
        return imageView
    }()
    
    
    /// login register segment control
    @objc let loginRegisterSegmentedControl: UISegmentedControl = {
        let sc = UISegmentedControl(items: ["Login", "Register"])
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.tintColor = UIColor.init(red:0.59, green:0.89, blue:0.78, alpha:1.0)
        sc.selectedSegmentIndex = 1
        sc.addTarget(self, action: #selector(handleLoginRegisterChange), for: .valueChanged)
        return sc
    }()
    
    // MARK: - Methods
    /// handle login button
    @objc func handleLogin() {
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
            ShoppingListServerObject.DoneLogin()
            self.stop()
        })
        )
    }
    
    /// handel login & register change
    @objc func handleLoginRegisterChange() {
        let title = loginRegisterSegmentedControl.titleForSegment(at: loginRegisterSegmentedControl.selectedSegmentIndex)
        loginRegisterButton.setTitle(title, for: .normal)
        
        // change height of inputContainerView
        inputsContainerViewHeightAnchor?.constant = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 100:150
        
        // change height of nameTextField
        nameTextFieldHeightAnchor?.isActive = false
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 0 : 1/3)
        nameTextField.isHidden = loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? true:false
        nameTextFieldHeightAnchor?.isActive = true
        
        emailTextFieldHeightAnchor?.isActive = false
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        
        passwordTextFieldHeightAnchor?.isActive = false
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: loginRegisterSegmentedControl.selectedSegmentIndex == 0 ? 1/2 : 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
    }
    
    /// Called after the controller's view is loaded into memory.
    override func viewDidLoad() {
        super.viewDidLoad()
        setNavigationBar()
        nameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        view.addSubview(inputsContainerView)
        view.addSubview(loginRegisterButton)
        view.addSubview(profileImageView)
        view.addSubview(loginRegisterSegmentedControl)
        
        setupInputsContainerView()
        setupLoginRegisterButton()
        setupProfileImageView()
        setupLoginRegisterSegmentedControl()
    }
    
    /// set navigation controller bar
    @objc func setNavigationBar() {
        let navBar = UINavigationBar(frame: CGRect(x: 0, y: 20, width: self.view.frame.width, height: 60))
        let navItem = UINavigationItem(title: "")
        let doneItem = UIBarButtonItem(barButtonSystemItem: .stop, target: nil, action: #selector(crossStop))
        navItem.rightBarButtonItem = doneItem
        navBar.setItems([navItem], animated: false)
        
        navBar.isTranslucent = false
        navBar.barStyle = .black
        navBar.barTintColor = ReminderStandardViewController.GetCurrentBackGroundThemeColor().MainColor
        self.view.addSubview(navBar)
    }
    
    /// dimiss current view
    @objc func crossStop() {
        self.userVC?.LoginReturned=true
        stop()
    }
    
    /// dimiss current view
    @objc func stop() {
        dismiss(animated: true, completion: nil)
        
//        let storyboard=UIStoryboard(name:"Main",bundle:nil)
//
//        let AccountVC=storyboard.instantiateViewController(withIdentifier: "AccountOverView")
//        self.tabBarController?.setViewControllers([tabBar], animated: <#T##Bool#>)
//        present(AccountVC, animated: true, completion: nil)
        
    }
    
    /// setup login & register segment control
    @objc func setupLoginRegisterSegmentedControl() {
        // need x, y width, height constraints
        loginRegisterSegmentedControl.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterSegmentedControl.bottomAnchor.constraint(equalTo: inputsContainerView.topAnchor, constant: -4).isActive = true
        loginRegisterSegmentedControl.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterSegmentedControl.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    /// setup profile image view
    @objc func setupProfileImageView() {
        // need x, y width, height constraints
        profileImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        profileImageView.bottomAnchor.constraint(equalTo: loginRegisterSegmentedControl.topAnchor, constant: -24).isActive = true
        profileImageView.widthAnchor.constraint(equalToConstant: 150).isActive = true
        profileImageView.heightAnchor.constraint(equalToConstant: 150).isActive = true
    }
    
    /// input container height anchor
    @objc var inputsContainerViewHeightAnchor: NSLayoutConstraint?
    
    /// name text field height anchor
    @objc var nameTextFieldHeightAnchor: NSLayoutConstraint?
    
    /// email text field height anchor
    @objc var emailTextFieldHeightAnchor: NSLayoutConstraint?
    
    /// password text field height anchor
    @objc var passwordTextFieldHeightAnchor: NSLayoutConstraint?
    
    /// setup imputs container view
    @objc func setupInputsContainerView() {
        // need x, y width, height constraints
        inputsContainerView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        inputsContainerView.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 0).isActive = true
        inputsContainerView.widthAnchor.constraint(equalTo: view.widthAnchor, constant: -24).isActive = true
        inputsContainerViewHeightAnchor = inputsContainerView.heightAnchor.constraint(equalToConstant: 150)
        inputsContainerViewHeightAnchor?.isActive = true
        
        inputsContainerView.addSubview(nameTextField)
        inputsContainerView.addSubview(nameSeperatorView)
        inputsContainerView.addSubview(emailTextField)
        inputsContainerView.addSubview(emailSeperatorView)
        inputsContainerView.addSubview(passwordTextField)
        inputsContainerView.addSubview(passwordSeperatorView)
        
        // need x, y , width, height constraints
        nameTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        nameTextField.topAnchor.constraint(equalTo: inputsContainerView.topAnchor).isActive = true
        nameTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameTextFieldHeightAnchor = nameTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1 / 3)
        nameTextFieldHeightAnchor?.isActive = true
        // need x, y , width, height constraints
        nameSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        nameSeperatorView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        nameSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        nameSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // need x, y , width, height constraints
        emailTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        emailTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        emailTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailTextFieldHeightAnchor = emailTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        emailTextFieldHeightAnchor?.isActive = true
        // need x, y , width, height constraints
        emailSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        emailSeperatorView.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        emailSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        emailSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
        
        // need x, y , width, height constraints
        passwordTextField.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor, constant: 12).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: emailTextField.bottomAnchor).isActive = true
        passwordTextField.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordTextFieldHeightAnchor = passwordTextField.heightAnchor.constraint(equalTo: inputsContainerView.heightAnchor, multiplier: 1/3)
        passwordTextFieldHeightAnchor?.isActive = true
        // need x, y , width, height constraints
        passwordSeperatorView.leftAnchor.constraint(equalTo: inputsContainerView.leftAnchor).isActive = true
        passwordSeperatorView.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor).isActive = true
        passwordSeperatorView.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        passwordSeperatorView.heightAnchor.constraint(equalToConstant: 1).isActive = true
    }
    
    /// setup login register button
    @objc func setupLoginRegisterButton() {
        // need x, y , width, height constraints
        loginRegisterButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        loginRegisterButton.topAnchor.constraint(equalTo: inputsContainerView.bottomAnchor, constant: 4).isActive = true
        loginRegisterButton.widthAnchor.constraint(equalTo: inputsContainerView.widthAnchor).isActive = true
        loginRegisterButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
    }
    
    /// name text field
    @objc let nameTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Name"
        tf.translatesAutoresizingMaskIntoConstraints = false
        return tf
    }()
    
    /// name seperator view
    @objc let nameSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// email text field
    @objc let emailTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Email"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.keyboardType=UIKeyboardType.emailAddress
        tf.autocapitalizationType=UITextAutocapitalizationType.none
        return tf
    }()
    
    /// email seperator view
    @objc let emailSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// password text field
    @objc let passwordTextField: UITextField = {
        let tf = UITextField()
        tf.placeholder = "Password"
        tf.translatesAutoresizingMaskIntoConstraints = false
        tf.isSecureTextEntry = true
        return tf
    }()
    
    /// password seperator view
    @objc let passwordSeperatorView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.init(red:0.96, green:0.96, blue:0.96, alpha:1.0)
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    /// hide status bar
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
}

// MARK: - UITextFieldDelegate, UITextViewDelegate
extension LoginViewController : UITextFieldDelegate, UITextViewDelegate {
    // MARK: - UITextFieldDelegate
    /// Asks the delegate if the text field should process the pressing of the return button.
    ///
    /// - Parameter textField: text field
    /// - Returns: true when return pressed
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        // dismiss the keyboard
        textField.resignFirstResponder()
        return true
    }
}
