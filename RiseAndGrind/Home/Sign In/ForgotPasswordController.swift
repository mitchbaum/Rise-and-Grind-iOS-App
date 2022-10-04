//
//  ForgotPasswordController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/7/22.
//
import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import JGProgressHUD


class ForgotPasswordController: UIViewController {
    
    //create variable to reference the firebase data so we can read, wirte and update it
    let db = Firestore.firestore()

    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        navigationItem.title = "Reset Password"
        
        view.backgroundColor = UIColor.darkGray
        navigationItem.largeTitleDisplayMode = .never
        
        // add cancel button to dismiss view
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Back", style: .plain, target: self, action: #selector(handleCancel))
        
        setupUI()
    }

    
    @objc func handleSendResetPassword(sender: UIButton) {
        // add animation to the button
        Utilities.animateView(sender)
        print("sending password reset email...")
    
        
        if emailTextField.text != "" {
            // style hud
            hud.textLabel.text = "Sending..."
            hud.show(in: view, animated: true)
            Auth.auth().sendPasswordReset(withEmail: emailTextField.text!) { (error) in
                if let error = error {
                    // dismiss loading hud if there's an error
                    self.hud.dismiss(animated: true)
                    return self.showError(title: "Unable to Send Password Reset Email", message: "\(error.localizedDescription) Please double check your email address.")
                } else {
                    self.hud.dismiss(animated: true)
                    print("done")
                    let alert = UIAlertController(title: "Sent", message: "A password reset email has been sent to \(self.emailTextField.text!).", preferredStyle: UIAlertController.Style.alert)
                    alert.addAction(UIAlertAction(title: "Ok", style: UIAlertAction.Style.default, handler: { (UIAlertAction) in
                        self.dismiss(animated: true, completion: nil)
                    }))
                    self.present(alert, animated: true, completion: nil)
                }
            }
        } else {
            return self.showError(title: "No Email Address Entered", message: "Please enter a valid email address to proceed.")
        }
    }
    
    
    // create text field for email entry
    let emailTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Email",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.autocapitalizationType = .none
        textField.autocorrectionType = .no
        textField.addLine(position: .bottom, color: .lightBlue, width: 1)
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    

    // send button for email rest
    let sendButton: UIButton = {
        let button = UIButton()
        button.backgroundColor = UIColor.lightBlue
        button.setTitle("Send Password Reset", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.addTarget(self, action: #selector(handleSendResetPassword(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // all code to add any layout UI elements
    private func setupUI() {
        
        // add and position name textfield element to the right of the nameLabel
        view.addSubview(emailTextField)
        emailTextField.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 40).isActive = true
        // move label to the right a bit
        emailTextField.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 32).isActive = true
        emailTextField.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -32).isActive = true
        emailTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        
        view.addSubview(sendButton)
        sendButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        sendButton.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 80).isActive = true
        sendButton.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -80).isActive = true
        sendButton.topAnchor.constraint(equalTo: emailTextField.bottomAnchor, constant: 40).isActive = true
        
    }
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // add loading HUD status for when fetching data from server
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
        

}


