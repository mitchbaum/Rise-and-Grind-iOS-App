//
//  SignInController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/7/22.
//

import UIKit
import FirebaseAuth
import JGProgressHUD


class SignInController: UIViewController {
    
    // add loading HUD status for when fetching data from server
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // create title for this view controller
        navigationItem.title = "Sign In"

        view.backgroundColor = UIColor.darkGray
        
        setupUI()
        dismissKeyboardGesture()
    }
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    

    
    @objc func handleSignIn(sender: UIButton) {
        print("User logging in")
        
        // add animation to the button this is taken from the Utilities.swift file in Helpers folder
        Utilities.animateView(sender)

        // validate the textfields
        let error = validatefields()
        if error != nil {

            return showError(title: "Invalid Entry", message: error!)
        }
        // create cleaned versions of textfields
        let email = usernameTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        let password = passwordTextField.text!.trimmingCharacters(in: .whitespacesAndNewlines)
        // signing in the user
        Auth.auth().signIn(withEmail: email, password: password) { (result, error) in
            // style hud
            self.hud.textLabel.text = "Signing In"
            self.hud.show(in: self.view, animated: true)
            if error != nil {
                // dismiss loading hud if there's an error
                self.hud.dismiss(animated: true)
                // couldnt sign in
                self.showError(title: "Unable to sign in", message: error!.localizedDescription)
            } else {
                // dismiss loading hud if there's no error
                self.hud.dismiss(animated: true)
                self.transitionToHome()
            }
        }
        
        
        
    }
    
    @objc private func handleLongPress() {
        // Handle the long press action
        print("Forgot Password button long pressed for 3 seconds")
        // Call your specific function here
        Auth.auth().signIn(withEmail: "apptest@gmail.com", password: "password123") { (result, error) in
            // style hud
            self.hud.textLabel.text = "Test User Signing In"
            self.hud.show(in: self.view, animated: true)
            if error != nil {
                // dismiss loading hud if there's an error
                self.hud.dismiss(animated: true)
                // couldnt sign in
                self.showError(title: "Unable to sign in", message: error!.localizedDescription)
            } else {
                // dismiss loading hud if there's no error
                self.hud.dismiss(animated: true)
                self.transitionToHome()
            }
        }
    }
    
    func transitionToHome() {
        let homeController = HomeController()
        let navigationController = UINavigationController(rootViewController: homeController)
        navigationController.modalPresentationStyle = .fullScreen
        present(navigationController, animated: true, completion: nil)
    }
    
    func validatefields() -> String? {
        // validate the textfields
        if usernameTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" || passwordTextField.text?.trimmingCharacters(in: .whitespacesAndNewlines) == "" {
            return "Please fill in all fields."
        }
        return nil
    }
    
    
    @objc func handleCreateUser(sender: UIButton) {
        print("Creating new user")
        
        // add animation to the button
        Utilities.animateView(sender)
        

        let createUserController = CreateUserController()
        let navController = CustomNavigationController(rootViewController: createUserController)
        // push into new viewcontroller
        present(navController, animated: true, completion: nil)


        
    }
    
    
    @objc func handleForgotPassword(sender: UIButton) {
        print("Forgot password button pressed")
        
        // add animation to the button
        Utilities.animateView(sender)
        
        let forgotPasswordController = ForgotPasswordController()
        let navController = CustomNavigationController(rootViewController: forgotPasswordController)
        // push into new viewcontroller
        present(navController, animated: true, completion: nil)
    }
    
    lazy var logInImageView: UIImageView = {
        //let imageView = UIImageView(image: "🏋".image(fontSize: 100, bgColor: .darkGray, imageSize: CGSize(width: 100, height: 110)))
        let imageView = UIImageView(image: #imageLiteral(resourceName: "stickman-curling"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // alters the squashed look to make the image appear normal in the view, fixes aspect ratio
        imageView.contentMode = .scaleAspectFill
        imageView.backgroundColor = .darkGray
//        imageView.layer.cornerRadius = imageView.frame.width / 3
//        imageView.layer.borderWidth = 1
        let tripleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleLongPress))
        tripleTapRecognizer.numberOfTapsRequired = 3
        imageView.addGestureRecognizer(tripleTapRecognizer)
        imageView.isUserInteractionEnabled = true
        return imageView
        
    }()
    

    // create text field for username
    let usernameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Email",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
//        textField.layer.borderWidth = 2
//        textField.layer.borderColor = UIColor.yellow.cgColor
//        textField.layer.cornerRadius = 10
        textField.addLine(position: .bottom, color: .lightBlue, width: 1)
        //textField.setLeftPaddingPoints(10)
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create text field for password
    let passwordTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Password",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
//        textField.layer.borderWidth = 2
//        textField.layer.borderColor = UIColor.yellow.cgColor
//        textField.layer.cornerRadius = 10
        textField.addLine(position: .bottom, color: .lightBlue, width: 1)
        textField.isSecureTextEntry.toggle()
        //textField.setLeftPaddingPoints(10)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create button for forgot password
    let forgotPasswordButton: UIButton = {
        let button = UIButton()
        

        //button.backgroundColor = UIColor.green
        button.setTitle("Forgot Password", for: .normal)
        button.setTitleColor(.lightBlue, for: .normal)
        //button.layer.cornerRadius = 15
        button.addTarget(self, action: #selector(handleForgotPassword(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 14.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    
    
    

    
    // create button for log in
    let signinButton: UIButton = {
        let button = UIButton()
        

        button.backgroundColor = UIColor.lightBlue
//        button.layer.borderColor = UIColor.beerOrange.cgColor
//        button.layer.borderWidth = 2
        button.setTitle("Log In", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSignIn(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // create button for creating a new user
    let createUserButton: UIButton = {
        let button = UIButton()
        

        //button.backgroundColor = UIColor.logoRed
        button.layer.borderColor = UIColor.lightBlue.cgColor
        button.layer.borderWidth = 2
        button.setTitle("Create Account", for: .normal)
        button.setTitleColor(.lightBlue, for: .normal)
        button.addTarget(self, action: #selector(handleCreateUser(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()




    
    private func setupUI() {
        
        view.addSubview(logInImageView)
        // gives padding of image from top
        logInImageView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 60).isActive = true
        logInImageView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        logInImageView.heightAnchor.constraint(equalToConstant: 125).isActive = true
        logInImageView.widthAnchor.constraint(equalToConstant: 125).isActive = true

        //add username textfield
        view.addSubview(usernameTextField)
        //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
        usernameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //usernameTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //usernameTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 30).isActive = true
        usernameTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        usernameTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        usernameTextField.topAnchor.constraint(equalTo: logInImageView.bottomAnchor, constant: 10).isActive = true
        
        //add password textfield
        view.addSubview(passwordTextField)
        //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
        passwordTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //passwordTextField.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        //passwordTextField.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 95).isActive = true
        passwordTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        passwordTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        passwordTextField.topAnchor.constraint(equalTo: usernameTextField.bottomAnchor, constant: 10).isActive = true
        
        
        //add log in button
        view.addSubview(signinButton)
        //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
        signinButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
//        signinButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
//        signinButton.centerYAnchor.constraint(equalTo: view.centerYAnchor, constant: 185).isActive = true
//        signinButton.widthAnchor.constraint(equalToConstant: 200).isActive = true
        
        signinButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 80).isActive = true
        signinButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -80).isActive = true
        signinButton.topAnchor.constraint(equalTo: passwordTextField.bottomAnchor, constant: 40).isActive = true
        
        //add ceate org button
        view.addSubview(createUserButton)
        //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
        createUserButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        createUserButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 80).isActive = true
        createUserButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -80).isActive = true
        createUserButton.topAnchor.constraint(equalTo: signinButton.bottomAnchor, constant: 15).isActive = true
        
        //add log in button
        view.addSubview(forgotPasswordButton)
        //crewButton.topAnchor.constraint(equalTo: roleLabel.bottomAnchor, constant: 10).isActive = true
//        forgotPasswordButton.heightAnchor.constraint(equalToConstant: 10).isActive = true
//        forgotPasswordButton.widthAnchor.constraint(equalToConstant: 150).isActive = true
        
        //forgotPasswordButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        //forgotPasswordButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        forgotPasswordButton.topAnchor.constraint(equalTo: createUserButton.bottomAnchor, constant: 15).isActive = true
        forgotPasswordButton.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        

    }
    
    
    private func dismissKeyboardGesture() {
        // dismiss keyboard when user taps outside of keyboard
        let tap = UITapGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        let swipeDown = UIPanGestureRecognizer(target: self, action: #selector(UIInputViewController.dismissKeyboard))
        view.addGestureRecognizer(tap)
        view.addGestureRecognizer(swipeDown)
    }
    
    //Calls this function when the tap is recognized.
    @objc func dismissKeyboard() {
        //Causes the view (or one of its embedded text fields) to resign the first responder status.
        view.endEditing(true)
    }
    
    
}
