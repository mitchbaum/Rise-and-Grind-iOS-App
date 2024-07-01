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
    
    var sortValue = "Name"
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.title = "Settings"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = UIColor.darkGray
        UINavigationBarAppearance().backgroundColor = .red
        
        let themeColor = Utilities.loadTheme()
        previewTheme(color: themeColor)
        themeControl.addTarget(self, action: #selector(themeControlValueChanged(_:)), for: .valueChanged)
        
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
            Utilities.setThemeColor(color: UIColor.sageGreen)
            appDelegate.updateGlobalNavigationBarAppearance(color: UIColor.sageGreen)
        } else if themeControl.selectedSegmentIndex == 2 {
            Utilities.setThemeColor(color: UIColor.lilac)
            appDelegate.updateGlobalNavigationBarAppearance(color: UIColor.lilac)
        } else if themeControl.selectedSegmentIndex == 3 {
            Utilities.setThemeColor(color: UIColor.mattePink)
            appDelegate.updateGlobalNavigationBarAppearance(color: UIColor.mattePink)
        } else {
            Utilities.setThemeColor(color: UIColor.maroon)
            appDelegate.updateGlobalNavigationBarAppearance(color: UIColor.maroon)
        }
        
        db.collection("Users").document(uid).updateData(["sort" : sort])
        navigationItem.title = "erere"
        dismiss(animated: true, completion: {self.delegate?.fetchExercises(); self.delegate?.refreshTheme()})
    }
    
    func previewTheme(color: UIColor) {
        // Customize navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor =  color
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor : UIColor.white] //portrait title
        // modifty regular text attributes on view controller as white color. There is a bug where if you scroll down the table view the "files" title at the top turns back to the black default
        navBarAppearance.titleTextAttributes = [.foregroundColor : UIColor.white] //landscape title
        themeControl.selectedSegmentTintColor = color
        showHiddenControl.selectedSegmentTintColor = color
        metricSegmentedControl.selectedSegmentTintColor = color
        sortSegmentedControl.selectedSegmentTintColor = color
        // Apply the customized appearance to the navigation bar
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    

    let messageLabel: UILabel = {
        let label = UILabel()
        label.text = "Display Weight As:"
        label.textColor = .black
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
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)

        return sc
    }()
    
    
    let sortMessageLabel: UILabel = {
        let label = UILabel()
        label.text = "Sort Exercises By:"
        label.textColor = .black
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
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)

        return sc
    }()
    
    let showHiddenLabel: UILabel = {
        let label = UILabel()
        label.text = "Hidden Exercises Visibility:"
        label.textColor = .black
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
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)

        return sc
    }()
    
    let themeLabel: UILabel = {
        let label = UILabel()
        label.text = "Theme:"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let themeControl: UISegmentedControl = {
        let activeSegment = Utilities.loadTheme()
        let types = ["💎","🌲","🍆", "🫦", "👞"]
        let sc = UISegmentedControl(items: types)
        // default as first item
        if activeSegment as UIColor == UIColor.lightBlue {
            sc.selectedSegmentIndex = 0
        } else if activeSegment as UIColor == UIColor.sageGreen {
            sc.selectedSegmentIndex = 1
        } else if activeSegment as UIColor == UIColor.lilac {
            sc.selectedSegmentIndex = 2
        } else if activeSegment as UIColor == UIColor.mattePink {
            sc.selectedSegmentIndex = 3
        } else {
            sc.selectedSegmentIndex = 4
        }
        sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        // changes text color to black for selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        // changes text color to black for non selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)

        return sc
    }()
    
    @objc func themeControlValueChanged(_ sender: UISegmentedControl) {
            switch sender.selectedSegmentIndex {
            case 0:
                previewTheme(color: UIColor.lightBlue)
            case 1:
                previewTheme(color: UIColor.sageGreen)
            case 2:
                previewTheme(color: UIColor.lilac)
            case 3:
                previewTheme(color: UIColor.mattePink)
            case 4:
                previewTheme(color: UIColor.maroon)
            default:
                break
            }
        }
        
    
    
    
    
    
    private func setupUI() {
        let silverBackgroundView = UIView()
        silverBackgroundView.backgroundColor = UIColor.white
        silverBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(silverBackgroundView)
        silverBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        silverBackgroundView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        silverBackgroundView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
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
        
        silverBackgroundView.bottomAnchor.constraint(equalTo: themeControl.bottomAnchor, constant: 16).isActive = true
        
        
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }

}
