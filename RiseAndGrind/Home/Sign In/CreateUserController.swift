//
//  CreateUserController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/7/22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import JGProgressHUD


class CreateUserController: UIViewController {
    override func viewDidLoad() {
        super.viewDidLoad()
        // create title for this view controller
        navigationItem.title = "Create Account"
        view.backgroundColor = .darkGray
        navigationItem.largeTitleDisplayMode = .never
        
        setupUI()
    }
    
    func buildUser() {
        // create cleaned versions of the data
        let email = emailTextField.text!
        let password = passwordTextField.text!
        let db = Firestore.firestore()
        
        // create the user
        Auth.auth().createUser(withEmail: email, password: password) { (result, err) in
            // check for errors
            if err != nil {
                //  there was an error
                self.hud.dismiss(animated: true)
                self.showError(title: "Unable to create user", message: "Please try again.")
            } else {
                // org was authenticated successfully, now store the organization name
                db.collection("Users").document(result!.user.uid).setData(
                    ["uid" : result!.user.uid,
                     "password" : password,
                     "email" : email,
                     "sort" : "Name",
                    ])
                { (error) in
                    if error != nil {
                        // show error message
                        self.hud.dismiss(animated: true)
                        self.showError(title: "Error saving user data", message: "User email wasn't saved.")
                    }
                }

                
                
            }

            self.hud.dismiss(animated: true)
            // transition to home screen
            self.transitionToHome()
            
        }
    }
    
    @objc func handleCreateUser(sender: UIButton) {
        print("creating new user")
        Utilities.animateView(sender)
        // validate the fields
        let error = validateFields()
        if error != nil {
            // there is something wrong with the fields, show error message
            return showError(title: "Unable to create user", message: error!)
        } else {
            buildUser()
        }
    }

    
    // check the fields and validate that the data is correct. If everything is correct, this method returns nil, otherwise it returns an error message as a string
    func validateFields() -> String? {
        
        // check if the password is secure
        let cleanedPassword = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isPasswordValid(cleanedPassword) == false {
            // password isnt secure enough
            return "Please make sure your password contains at least 6 characters."
        }
        if passwordTextField.text != reenterPasswordTextField.text {
            return "Passwords do not match."
        }
        
        // check if email is correct format
        let cleanedEmail = emailTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        if Utilities.isValidEmail(cleanedEmail) == false {
            return "Invalid email."
        }
        
        return nil
    }
    
    // create email label
    let emailLabel: UILabel = {
        let label = UILabel()
        label.text = "Email"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightBlue
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // create text field for email entry
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter email",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .lightBlue, width: 1)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    
    // create password label
    let passwordLabel: UILabel = {
        let label = UILabel()
        label.text = "Password"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightBlue
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        
        return label
    }()
    
    // create text field for password
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter password",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .lightBlue, width: 1)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry.toggle()
        return textField
    }()
    // create reenterpassword label
    let reenterPasswordLabel: UILabel = {
        let label = UILabel()
        label.text = "Re-enter Password"
        label.font = UIFont.systemFont(ofSize: 12)
        label.textColor = .lightBlue
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // create text field for reentered password
    let reenterPasswordTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Enter password",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.addLine(position: .bottom, color: .lightBlue, width: 1)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isSecureTextEntry.toggle()
        return textField
    }()
    
    
    
    // create button for create account
    let createButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightBlue
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleCreateUser(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    

    
    // all code to add any layout UI elements
    private func setupUI() {
        
        // add and position deductible label
        view.addSubview(emailLabel)
        emailLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 10).isActive = true
        emailLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        emailLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        emailLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(emailTextField)
        emailTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        emailTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        emailTextField.topAnchor.constraint(equalTo: emailLabel.bottomAnchor).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        // add and position established label
        
        view.addSubview(passwordLabel)
        passwordLabel.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 10).isActive = true
        passwordLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        passwordLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        passwordLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // add and position coc textfield element to the right of the nameLabel
        view.addSubview(passwordTextField)
        passwordTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: passwordLabel.bottomAnchor).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true


        // add and position invoice label
        view.addSubview(reenterPasswordLabel)
        reenterPasswordLabel.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 10).isActive = true
        reenterPasswordLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        reenterPasswordLabel.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        reenterPasswordLabel.heightAnchor.constraint(equalToConstant: 20).isActive = true

        // add and position invoice textfield element to the right of the nameLabel
        view.addSubview(reenterPasswordTextField)
        reenterPasswordTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        reenterPasswordTextField.rightAnchor.constraint(equalTo: view.rightAnchor, constant: -16).isActive = true
        reenterPasswordTextField.topAnchor.constraint(equalTo: reenterPasswordLabel.bottomAnchor).isActive = true
        reenterPasswordTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        // to fill entire view
        //nameLabel.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true


        

        // add and position deductible textfield element to the right of the nameLabel
        view.addSubview(createButton)
        createButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        createButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 80).isActive = true
        createButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -80).isActive = true
        createButton.topAnchor.constraint(equalTo: reenterPasswordTextField.bottomAnchor, constant: 40).isActive = true
        //createButton.bottomAnchor.constraint(equalTo: containerView.bottomAnchor, constant: -20.0).isActive = true
    
    }
    
    
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    func transitionToHome() {
        let homeController = HomeController()
        navigationController?.pushViewController(homeController, animated: true)
    }
    
}
