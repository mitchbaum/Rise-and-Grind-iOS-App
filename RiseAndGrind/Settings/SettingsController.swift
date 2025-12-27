//
//  SettingsController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 10/4/21.
//


import UIKit
import FirebaseAuth
import Firebase
import FirebaseStorage
import JGProgressHUD

//custom delegation
@objc protocol SettingsControllerDelegate {
    func fetchExercises()
    func refreshTheme()
    @objc func handleSignOut()
}


class SettingsController: UIViewController {
    var delegate: SettingsControllerDelegate?
    
    let db = Firestore.firestore()
    
    var currThemeColor: UIColor?
    var currAppearanceMode: String = "Light"
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.title = "Settings"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Utilities.loadAppearanceTheme(property: "secondary")
        
        let themeColor = Utilities.loadTheme()
        currThemeColor = themeColor
        previewTheme(color: themeColor)
        themeControl.addTarget(self, action: #selector(themeControlValueChanged(_:)), for: .valueChanged)
        
        let appearanceTheme = UserDefaults.standard.object(forKey: "appearanceTheme") as? String ?? "Light"
        currAppearanceMode = appearanceTheme
        previewAppearanceTheme(mode: appearanceTheme)
        appearanceThemeControl.addTarget(self, action: #selector(appearanceThemeControlValueChanged(_:)), for: .valueChanged)
        
        let tripleTapRecognizer = UITapGestureRecognizer(target: self, action: #selector(handleMultiTap))
        tripleTapRecognizer.numberOfTapsRequired = 3
        messageLabel.isUserInteractionEnabled = true
        messageLabel.addGestureRecognizer(tripleTapRecognizer)
        
        // add cancel button to dismiss view
        let cancel = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        let save = UIBarButtonItem(title: NSString(string: "Save") as String, style: .plain, target: self, action: #selector(handleSave))
        let signOut = UIBarButtonItem(title: NSString(string: "👋") as String, style: .plain, target: self, action: #selector(handleSignOut))
        navigationItem.leftBarButtonItems = [signOut, cancel]
        
        navigationItem.rightBarButtonItems = [save]
        fetchSortValue()
        setupUI()

    }
    
    @objc private func handleSignOut() {
        dismiss(animated: true, completion: nil)
            // Ensure delegate is set and call the delegate method
            delegate?.handleSignOut()
        }
    
    // add loading HUD status for when fetching data from server
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()
    
    func fetchSortValue() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).getDocument(completion: { snapshot, error in
            if let err = error {
                debugPrint("Error fetching workout: \(err)")
            } else {
                if let data = snapshot?.data() {
                    let sort = data["sort"] as? String
                    UserDefaults.standard.setValue(sort, forKey: "sortMetric")

                }
            }
        })
    }
    
    @objc private func handleSave() {
        print("saving settings")
        var sort = ""
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if metricSegmentedControl.selectedSegmentIndex == 0 {
            UserDefaults.standard.setValue(0, forKey: "weightMetric")
        } else {
            UserDefaults.standard.setValue(1, forKey: "weightMetric")
        }
        if sortSegmentedControl.selectedSegmentIndex == 0 {
            UserDefaults.standard.setValue("Name", forKey: "sortMetric")
            sort = "Name"
        } else if sortSegmentedControl.selectedSegmentIndex == 1 {
            UserDefaults.standard.setValue("Custom", forKey: "sortMetric")
            sort = "Custom"
        } else {
            UserDefaults.standard.setValue("Last Modified", forKey: "sortMetric")
            sort = "Last Modified"
        }
        if showHiddenControl.selectedSegmentIndex == 0 {
            UserDefaults.standard.setValue(false, forKey: "showHidden")
        } else {
            UserDefaults.standard.setValue(true, forKey: "showHidden")
        }
        let appDelegate = UIApplication.shared.delegate as! AppDelegate
        if themeControl.selectedSegmentIndex == 0 {
            Utilities.setThemeColor(color: UIColor.lightBlue)
            appDelegate.updateGlobalNavigationBarAppearance(color: UIColor.lightBlue)
        } else if themeControl.selectedSegmentIndex == 1 {
            Utilities.setThemeColor(color: UIColor.green)
            appDelegate.updateGlobalNavigationBarAppearance(color: UIColor.green)
        } else if themeControl.selectedSegmentIndex == 2 {
            Utilities.setThemeColor(color: UIColor.purple)
            appDelegate.updateGlobalNavigationBarAppearance(color: UIColor.purple)
        } else if themeControl.selectedSegmentIndex == 3 {
            Utilities.setThemeColor(color: UIColor.pink)
            appDelegate.updateGlobalNavigationBarAppearance(color: UIColor.pink)
        } else {
            Utilities.setThemeColor(color: UIColor.orange)
            appDelegate.updateGlobalNavigationBarAppearance(color: UIColor.orange)
        }
        if let scene = UIApplication.shared.connectedScenes.first as? UIWindowScene,
           let sceneDelegate = scene.delegate as? SceneDelegate {
            let appearanceTheme = appearanceThemeControl.selectedSegmentIndex == 0 ? "Light" : "Dark"
            let colorTheme = Utilities.loadTheme()
            UserDefaults.standard.setValue(appearanceTheme, forKey: "appearanceTheme")
            sceneDelegate.updateWindowAppearance()
            appDelegate.updateGlobalNavigationBarAppearance(color: appearanceTheme == "Dark" ? UIColor.black : colorTheme)
            
        }
        db.collection("Users").document(uid).updateData(["sort" : sort])
        dismiss(animated: true, completion: {self.delegate?.fetchExercises(); self.delegate?.refreshTheme()})
    }
    
    func previewTheme(color: UIColor) {
        currThemeColor = color
        if currAppearanceMode != "Dark" {
            previewNavBarappearance(color: color)
        }
        themeControl.selectedSegmentTintColor = color
        showHiddenControl.selectedSegmentTintColor = color
        metricSegmentedControl.selectedSegmentTintColor = color
        sortSegmentedControl.selectedSegmentTintColor = color
        appearanceThemeControl.selectedSegmentTintColor = color
    }
    
    func previewAppearanceTheme(mode: String) {
        currAppearanceMode = mode
        let normalTextAttributes: [NSAttributedString.Key: Any] = [
            .foregroundColor: Utilities.loadAppearanceTheme(property: "text", optionalMode: mode)
        ]
        let textColor = Utilities.loadAppearanceTheme(property: "text", optionalMode: mode)
        previewNavBarappearance(color: mode == "Dark" ? Utilities.loadAppearanceTheme(property: "secondary", optionalMode: mode) : currThemeColor ?? UIColor.gray)
        backgroundView.backgroundColor = Utilities.loadAppearanceTheme(property: "primary", optionalMode: mode)
        view.backgroundColor = Utilities.loadAppearanceTheme(property: "secondary", optionalMode: mode)
        messageLabel.textColor = textColor
        metricSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        sortMessageLabel.textColor = textColor
        sortSegmentedControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        showHiddenLabel.textColor = textColor
        showHiddenControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        themeLabel.textColor = textColor
        themeControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        appearanceThemeLabel.textColor = textColor
        appearanceThemeControl.setTitleTextAttributes(normalTextAttributes, for: .normal)
        
    }
    
    func previewNavBarappearance(color: UIColor) {
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor =  color
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor : UIColor.white] //portrait title
        // modifty regular text attributes on view controller as white color. There is a bug where if you scroll down the table view the "files" title at the top turns back to the black default
        navBarAppearance.titleTextAttributes = [.foregroundColor : UIColor.white] //landscape title
        // Apply the customized appearance to the navigation bar
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    @objc private func handleMultiTap() {

        print("Multi tap!")
        let deleteAccountAction = UIAlertAction(title: "Delete Account", style: .destructive) { (action) in
            self.hud.textLabel.text = "Deleting Account..."
            self.hud.show(in: self.view, animated: true)
            let user = Auth.auth().currentUser
            user?.delete { error in
              if let error = error {
                  self.hud.dismiss(animated: true)
                  // couldnt sign in
                  self.showError(title: "Unable to delete account", message: error.localizedDescription)
              } else {
                  self.hud.dismiss(animated: true)
                  let signInController = SignInController()
                  signInController.modalPresentationStyle = .fullScreen
                  self.present(signInController, animated: true, completion: nil)
              }
            }
        }
        // alert
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(deleteAccountAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
       
    }
    
    let backgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.white
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
        
    }()

    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Display Weight As:"
        label.textColor = Utilities.loadAppearanceTheme(property: "text")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let metricSegmentedControl: UISegmentedControl = {
        let activeSegment = UserDefaults.standard.object(forKey: "weightMetric")
        let types = ["LBS","KG"]
        let sc = UISegmentedControl(items: types)
        // default as first item
        sc.selectedSegmentIndex = activeSegment as? Int ?? 0
        sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        // changes text color to black for selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        // changes text color to black for non selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Utilities.loadAppearanceTheme(property: "text")], for: .normal)

        return sc
    }()
    
    
    let sortMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Order Exercises By:"
        label.textColor = Utilities.loadAppearanceTheme(property: "text")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let sortSegmentedControl: UISegmentedControl = {
        let activeSegment = UserDefaults.standard.object(forKey: "sortMetric")
        let types = ["Name","Custom","Last Modified"]
        let sc = UISegmentedControl(items: types)
        // default as first item
        if activeSegment as! String == "Name" {
            sc.selectedSegmentIndex = 0
        } else if activeSegment as! String == "Custom" {
            sc.selectedSegmentIndex = 1
        } else {
            sc.selectedSegmentIndex = 2
        }
        sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        // changes text color to black for selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        // changes text color to black for non selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Utilities.loadAppearanceTheme(property: "text")], for: .normal)

        return sc
    }()
    
    let showHiddenLabel: UILabel = {
        let label = UILabel()
        label.text = "Hidden Exercises Visibility:"
        label.textColor = Utilities.loadAppearanceTheme(property: "text")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let showHiddenControl: UISegmentedControl = {
        let activeSegment = UserDefaults.standard.object(forKey: "showHidden")
        let types = ["Hide","Show"]
        let sc = UISegmentedControl(items: types)
        // default as first item
        if activeSegment as! Bool == false {
            sc.selectedSegmentIndex = 0
        } else {
            sc.selectedSegmentIndex = 1
        }
        sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        // changes text color to black for selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        // changes text color to black for non selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Utilities.loadAppearanceTheme(property: "text")], for: .normal)

        return sc
    }()
    
    let themeLabel: UILabel = {
        let label = UILabel()
        label.text = "Theme:"
        label.textColor = Utilities.loadAppearanceTheme(property: "text")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let themeControl: UISegmentedControl = {
        let activeSegment = Utilities.loadTheme()
        let types = ["💎","🌲","😈", "💄", "🍊"]
        let sc = UISegmentedControl(items: types)
        // default as first item
        if activeSegment as UIColor == UIColor.lightBlue {
            sc.selectedSegmentIndex = 0
        } else if activeSegment as UIColor == UIColor.green {
            sc.selectedSegmentIndex = 1
        } else if activeSegment as UIColor == UIColor.purple {
            sc.selectedSegmentIndex = 2
        } else if activeSegment as UIColor == UIColor.pink {
            sc.selectedSegmentIndex = 3
        } else {
            sc.selectedSegmentIndex = 4
        }
        sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        // changes text color to black for selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        // changes text color to black for non selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Utilities.loadAppearanceTheme(property: "text")], for: .normal)

        return sc
    }()
    
    @objc func themeControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            previewTheme(color: UIColor.lightBlue)
        case 1:
            previewTheme(color: UIColor.green)
        case 2:
            previewTheme(color: UIColor.purple)
        case 3:
            previewTheme(color: UIColor.pink)
        case 4:
            previewTheme(color: UIColor.orange)
        default:
            break
        }
    }
    
    let appearanceThemeLabel: UILabel = {
        let label = UILabel()
        label.text = "Appearance:"
        label.textColor = Utilities.loadAppearanceTheme(property: "text")
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let appearanceThemeControl: UISegmentedControl = {
        let activeSegment = UserDefaults.standard.object(forKey: "appearanceTheme")
        let types = ["Light", "Dark"]
        let sc = UISegmentedControl(items: types)
        // default as first item
        if activeSegment as? String == "Light" {
            sc.selectedSegmentIndex = 0
        } else if activeSegment as? String == "Dark" {
            sc.selectedSegmentIndex = 1
        } else {
            sc.selectedSegmentIndex = 0
        }
        sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        // changes text color to black for selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        // changes text color to black for non selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Utilities.loadAppearanceTheme(property: "text")], for: .normal)

        return sc
    }()
    @objc func appearanceThemeControlValueChanged(_ sender: UISegmentedControl) {
        switch sender.selectedSegmentIndex {
        case 0:
            previewAppearanceTheme(mode: "Light")
        case 1:
            previewAppearanceTheme(mode: "Dark")
        default:
            break
        }
    }
        
    
    
    
    
    
    private func setupUI() {

        view.addSubview(backgroundView)
        backgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        backgroundView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        backgroundView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        view.addSubview(messageLabel)
        messageLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 16).isActive = true
        messageLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        view.addSubview(metricSegmentedControl)
        metricSegmentedControl.topAnchor.constraint(equalTo: messageLabel.bottomAnchor, constant: 16).isActive = true
        metricSegmentedControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        metricSegmentedControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        
        view.addSubview(sortMessageLabel)
        sortMessageLabel.topAnchor.constraint(equalTo:  metricSegmentedControl.bottomAnchor, constant: 16).isActive = true
        sortMessageLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        view.addSubview(sortSegmentedControl)
        sortSegmentedControl.topAnchor.constraint(equalTo: sortMessageLabel.bottomAnchor, constant: 16).isActive = true
        sortSegmentedControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        sortSegmentedControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        
        view.addSubview(showHiddenLabel)
        showHiddenLabel.topAnchor.constraint(equalTo:  sortSegmentedControl.bottomAnchor, constant: 16).isActive = true
        showHiddenLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        view.addSubview(showHiddenControl)
        showHiddenControl.topAnchor.constraint(equalTo: showHiddenLabel.bottomAnchor, constant: 16).isActive = true
        showHiddenControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        showHiddenControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        
        view.addSubview(themeLabel)
        themeLabel.topAnchor.constraint(equalTo:  showHiddenControl.bottomAnchor, constant: 16).isActive = true
        themeLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        view.addSubview(themeControl)
        themeControl.topAnchor.constraint(equalTo: themeLabel.bottomAnchor, constant: 16).isActive = true
        themeControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        themeControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        
        view.addSubview(appearanceThemeLabel)
        appearanceThemeLabel.topAnchor.constraint(equalTo:  themeControl.bottomAnchor, constant: 16).isActive = true
        appearanceThemeLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        view.addSubview(appearanceThemeControl)
        appearanceThemeControl.topAnchor.constraint(equalTo: appearanceThemeLabel.bottomAnchor, constant: 16).isActive = true
        appearanceThemeControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        appearanceThemeControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        
        backgroundView.bottomAnchor.constraint(equalTo: appearanceThemeControl.bottomAnchor, constant: 16).isActive = true
        
        
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    

}
