//
//  ViewController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 10/3/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import SwiftUI
import LBTATools
import JGProgressHUD


class HomeController: UITableViewController, newCategoryControllerDelegate, WorkoutControllerDelegate, NewExerciseControllerDelegate, SettingsControllerDelegate, ReorderControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    let userDefaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    let categories = ["Upper", "Lower", "Abs"]
    var cats = [Cat]()
    var catsNameOnly = [String]()
    var catCollectionReference: CollectionReference!
    var exerciseCollectionRef: CollectionReference!
    
    
    var exercises = [Exercise]()
    var sets = [4]
    
    var activeSegment = 0
    
    var isSignedIn = false
    
    var UIHeight = 0.0
    
    // add loading HUD status for when fetching data from server
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
        
        // Do any additional setup after loading the view.
        
        // creates title of files
        navigationItem.title = "My Workouts"
        
        
        // register fileCell wiht cellId
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(ExerciseCell.self, forCellReuseIdentifier: ExerciseCell.identifier)
        
        tableView.backgroundColor = .darkGray
        tableView.tableFooterView = UIView()
        

        tableView.refreshControl = UIRefreshControl()
        tableView.refreshControl?.addTarget(self, action: #selector(self.refresh(_:)), for: .valueChanged)

        
        catCollectionReference = Firestore.firestore().collection("Category")
        let weightMetric = userDefaults.object(forKey: "weightMetric")
        if weightMetric == nil {
            UserDefaults.standard.setValue(0, forKey: "weightMetric")
        }
        
        let sortMetric = userDefaults.object(forKey: "sortMetric")
        if sortMetric == nil {
            UserDefaults.standard.setValue("Name", forKey: "sortMetric")
        }
        
        let showHidden = userDefaults.object(forKey: "showHidden")
        if showHidden == nil {
            UserDefaults.standard.setValue(true, forKey: "showHidden") // default to showing all exercises
        }
        
        let theme = userDefaults.object(forKey: "theme")
        if theme == nil {
            Utilities.setThemeColor(color: UIColor.lightBlue)
        }
        
        workoutCategorySelectorTextField.inputView = workoutCategoryPicker
        workoutCategoryPicker.delegate = self
        workoutCategoryPicker.dataSource = self
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear data loaded")
        checkIfSignedIn()
        tableView.reloadData()
    }
    
    func checkIfSignedIn() {
        print("checking if user is signed in")
        // user is signed in 
        if Auth.auth().currentUser != nil {
            isSignedIn = true
            let reorder = UIBarButtonItem(barButtonSystemItem: .compose, target: self, action: #selector(handleReorderWorkout))
            let plus = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(handleAddWorkout))
            // add settings icon button
            let settings = UIBarButtonItem(title: NSString(string: "\u{2699}\u{0000FE0E}") as String, style: .plain, target: self, action: #selector(handleSettings))
            let font = UIFont.systemFont(ofSize: 33) // adjust the size as required
            let attributes = [NSAttributedString.Key.font : font]
            settings.setTitleTextAttributes(attributes, for: .normal)
            navigationItem.rightBarButtonItems = [plus, settings, reorder]
            
            self.userDefaults.setValue([], forKey: "myKey")
            fetchCategories()
            UIHeight = 30.0
            setupUI()

        }  else {
            isSignedIn = false
            let signInController = SignInController()
            signInController.modalPresentationStyle = .fullScreen
            present(signInController, animated: true, completion: nil)
            
                
            } 
    }
    
    func sortExercises() {
        print("sorting exercises")
        let sortMetric = self.userDefaults.object(forKey: "sortMetric")
        if sortMetric as! String == "Name" {
            // ascending
            exercises.sort(by: {$0.name ?? "" < $1.name ?? ""})
        } else if sortMetric as! String == "Custom" {
            exercises.sort(by: {$0.location ?? 0 < $1.location ?? 0})

        } else {
            // last modified
            exercises.sort(by: {$0.timeStamp ?? "" > $1.timeStamp ?? ""})
        }
        tableView.reloadData()
    }
    
    
    // fetches the exercises from Firebase database
    @objc func fetchCategories() {
        print("fetching categories in HomeController")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        //cats = []
        if isSignedIn == true {
            catsNameOnly = []
            db.collection("Users").document(uid).collection("Category").getDocuments { snapshot, error in
                if let err = error {
                    debugPrint("error fetching docs: \(err)")
                } else {
                    guard let snap = snapshot else { return }
                    for document in snap.documents {
                        let data = document.data()
                        let name = data["name"] as? String ?? ""

                        self.catsNameOnly.append(name)
                    }
                    self.userDefaults.setValue(self.catsNameOnly, forKey: "myKey")
                    self.fetchExercises()
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                        self.tableView.refreshControl?.endRefreshing()
                        self.sortExercises()
                        self.tableView.reloadData()
                    }

                }
            }
        } else {
            self.tableView.refreshControl?.endRefreshing()
        }
    }

    
    // fetches the exercises from Firebase database
    func fetchExercises() {
        print("fetching exercises")
        exercises = []
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print(catsNameOnly)
        if catsNameOnly.count != 0 {
            workoutCategorySelectorTextField.text = catsNameOnly[activeSegment]
            UserDefaults.standard.setValue(catsNameOnly[activeSegment], forKey: "selectedCategory")
            let showHidden = userDefaults.object(forKey: "showHidden") as? Bool ?? true
            self.exerciseCollectionRef = db.collection("Users").document(uid).collection("Category").document(catsNameOnly[activeSegment]).collection("Exercises")
                if showHidden {
                    self.exerciseCollectionRef.getDocuments { (snapshot, error) in
                        if let err = error {
                            debugPrint("Error fetching exercises: \(err)")
                        } else {
                            guard let snap = snapshot else { return }
                            self.processSnapshot(snapshot: snap, uid: uid, category: self.catsNameOnly[self.activeSegment])
                        }
                    }
                } else {
                    self.exerciseCollectionRef.whereField("hidden", isNotEqualTo: true).getDocuments { (snapshot, error) in
                        if let err = error {
                            debugPrint("Error fetching exercises: \(err)")
                        } else {
                            guard let snap = snapshot else { return }
                            self.processSnapshot(snapshot: snap, uid: uid, category: self.catsNameOnly[self.activeSegment])
                        }
                    }
                }
            }
    }
    
    private func processSnapshot(snapshot: QuerySnapshot, uid: String, category: String) {
        for document in snapshot.documents {
            let data = document.data()
            let name = data["name"] as? String ?? ""
            let category = data["category"] as? String ?? ""
            let timeStamp = data["timestamp"] as? String ?? ""
            let location = data["location"] as? Int ?? 0
            let weight = data["weight"] as? Array ?? []
            let reps = data["reps"] as? Array ?? []
            let note = data["note"] as? String ?? ""
            if (data["hidden"] == nil) {
                print("hidden not found! doc is ", name, " adding the hidden field and setting to false")
                db.collection("Users").document(uid).collection("Category").document(category).collection("Exercises").document(name).updateData(["hidden": false])
            }
            let hidden = data["hidden"] as? Bool ?? false
             
            let newExercise = Exercise(name: name, category: category, timeStamp: timeStamp, location: location, weight: weight, reps: reps, note: note, hidden: hidden)
            self.exercises.append(newExercise)

        }
        self.sortExercises()
    }
    
    @objc func handleSignOut() {
        print("signing out")
        let signOutAction = UIAlertAction(title: "Sign Out", style: .destructive) { (action) in
            self.hud.textLabel.text = "Signing Out"
            self.hud.show(in: self.view, animated: true)
            do {
                try Auth.auth().signOut()
                self.hud.dismiss(animated: true)
                self.dismiss(animated: true, completion: nil)
                self.viewWillAppear(true)
                self.exercises = []
                self.tableView.reloadData()
                self.workoutCategorySelectorTextField.isHidden = true
                self.UIHeight = 0.0
                self.downIcon.tintColor = UIColor.darkGray
                self.setupUI()
                let appDelegate = UIApplication.shared.delegate as! AppDelegate
                Utilities.setThemeColor(color: UIColor.lightBlue)
                appDelegate.updateGlobalNavigationBarAppearance(color: UIColor.lightBlue)
                
            } catch let err {
                self.hud.dismiss(animated: true)
                print("Failed to sign out with error ", err)
                self.showError(title: "Sign Out Error", message: "Please try again.")
            }
        }
        // alert
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        optionMenu.addAction(signOutAction)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    

    @objc func refresh(_ sender: AnyObject) {
        print("refreshing")
        fetchCategories()
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.tableView.refreshControl?.endRefreshing()
            print("reloading data after refresh")
            self.tableView.reloadData()
        }
    }
    
    // function that handles the reorder button in top right
    @objc func handleReorderWorkout() {
        print("reordering exercises..")
        let reorderController = ReorderController()
        let navController = CustomNavigationController(rootViewController: reorderController)
        reorderController.delegate = self
        self.present(navController, animated: true, completion: nil)
    }
    
    // function that handles the plus button in top right corner
    @objc func handleAddWorkout() {
        print("Adding..")
        let color = Utilities.loadTheme()
        let addWorkout = UIAlertAction(title: "New Exercise", style: .default) { action in
            print("new exercise")
            let newExerciseController = NewExerciseController()
            let navController = CustomNavigationController(rootViewController: newExerciseController)
            newExerciseController.delegate = self
            self.present(navController, animated: true, completion: nil)
        }
        let addCategory = UIAlertAction(title: "New Category", style: .default) { action in
            print("new category")
            let newCategoryController = NewCategoryController()
            let navController = CustomNavigationController(rootViewController: newCategoryController)
            newCategoryController.delegate = self
            self.present(navController, animated: true, completion: nil)
        }
        //alert
        // change color of alert text
        addWorkout.setValue(color, forKey: "titleTextColor")
        addCategory.setValue(color, forKey: "titleTextColor")
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        optionMenu.addAction(addWorkout)
        optionMenu.addAction(addCategory)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    // function that handles the settings button in top right corner
    @objc func handleSettings() {
        print("Settings..")
        let settingsController = SettingsController()
        let navController = CustomNavigationController(rootViewController: settingsController)
        settingsController.delegate = self
        self.present(navController, animated: true, completion: nil)
        
    }
    
    @objc private func handleSignIn() {
        print("Sign in")
        let signInController = SignInController()
        // push into new viewcontroller
        navigationController?.pushViewController(signInController, animated: true)
    }
    
    func refreshTheme() {
        let color = Utilities.loadTheme()
        // Customize navigation bar appearance
        let navBarAppearance = UINavigationBarAppearance()
        navBarAppearance.backgroundColor =  color
        navBarAppearance.largeTitleTextAttributes = [.foregroundColor : UIColor.white] //portrait title
        // modifty regular text attributes on view controller as white color. There is a bug where if you scroll down the table view the "files" title at the top turns back to the black default
        navBarAppearance.titleTextAttributes = [.foregroundColor : UIColor.white] //landscape title
        downIcon.tintColor = color
        workoutCategorySelectorTextField.addLine(position: .bottom, color: Utilities.loadTheme(), width: 0.5)
        
        // Apply the customized appearance to the navigation bar
        navigationController?.navigationBar.standardAppearance = navBarAppearance
        navigationController?.navigationBar.scrollEdgeAppearance = navBarAppearance
    }
    
    let workoutCategoryPicker: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    
    var workoutCategorySelectorTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Select workout...",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .white
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        textField.addLine(position: .bottom, color: Utilities.loadTheme(), width: 0.5)
        textField.tintColor = UIColor.clear
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    var downIcon: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "down-arrow-icon"))
        imageView.translatesAutoresizingMaskIntoConstraints = false
        // alters the squashed look to make the image appear normal in the view, fixes aspect ratio
        imageView.contentMode = .scaleAspectFit
        imageView.clipsToBounds = true
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = Utilities.loadTheme()
        return imageView
        
    }()
    
    let containerView : UIView = {
        let view = UIView()
        view.translatesAutoresizingMaskIntoConstraints = false
        view.backgroundColor = .lightGray
        //view.frame.size = contentViewSize
        return view
    }()
    
    
    private func setupUI() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        print("UIHeight: ", UIHeight)
        

        let headerView = UILabel(frame: header.bounds)
        //headerView.backgroundColor = .lightBlue
        header.addSubview(headerView)
        header.addSubview(workoutCategorySelectorTextField)
        workoutCategorySelectorTextField.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        workoutCategorySelectorTextField.topAnchor.constraint(equalTo: headerView.topAnchor, constant: 10).isActive = true
        workoutCategorySelectorTextField.heightAnchor.constraint(equalToConstant: UIHeight).isActive = true
        workoutCategorySelectorTextField.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 16).isActive = true
        
        
        header.addSubview(downIcon)
        downIcon.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        downIcon.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        downIcon.heightAnchor.constraint(equalToConstant: 15).isActive = true
        downIcon.widthAnchor.constraint(equalToConstant: 15).isActive = true
        
        tableView.tableHeaderView = header
    }
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    


}

