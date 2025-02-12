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


class HomeController: UITableViewController, newCategoryControllerDelegate, WorkoutControllerDelegate, NewExerciseControllerDelegate, SettingsControllerDelegate, ReorderControllerDelegate, RecentsControllerDelegate, UIPickerViewDelegate, UIPickerViewDataSource {
    
    let userDefaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    var categories = [String]()
    var cats = [Cat]()
    var catCollectionReference: CollectionReference!
    var exerciseCollectionRef: CollectionReference!
    
    var timer: Timer?
    
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
        
        let tapGesture = UITapGestureRecognizer(target: self, action: #selector(handleImageViewTap))
        downIcon.isUserInteractionEnabled = true // Enable user interaction on the UIImageView
        downIcon.addGestureRecognizer(tapGesture)
        
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        print("viewWillAppear data loaded")
        checkIfSignedIn()
        tableView.reloadData()
    }
    
    @objc func handleImageViewTap() {
        // Focus the text field to display the picker view
        workoutCategorySelectorTextField.becomeFirstResponder()
    }
    
    func checkIfSignedIn() {
        print("checking if user is signed in")
        // user is signed in 
        if Auth.auth().currentUser != nil {
            isSignedIn = true
            navigationItem.rightBarButtonItems = populateBarBtnItems(side: "right")
            navigationItem.leftBarButtonItems = populateBarBtnItems(side: "left")
            self.userDefaults.setValue([], forKey: "myKey")
            Task {
               do {
                   try await fetchCategories()
                   restorePrevCategorySelection()
                   fetchExercises()
               } catch {
                   print("Failed to fetch categories: \(error)")
               }
            }
            
            UIHeight = 30.0
            setupUI()

        }  else {
            isSignedIn = false
            let signInController = SignInController()
            signInController.modalPresentationStyle = .fullScreen
            present(signInController, animated: true, completion: nil)
            
                
            } 
    }
    
    func restorePrevCategorySelection() {
        if let prevCat = UserDefaults.standard.string(forKey: "selectedCategory") {
            let row = categories.firstIndex(of: prevCat) ?? 0
            workoutCategoryPicker.selectRow(row, inComponent: 0, animated: false)
            activeSegment = row
            workoutCategorySelectorTextField.text = categories[row]
       }
    }
    
    func populateBarBtnItems(side: String) -> Array<UIBarButtonItem> {
        var barbuttonitems: [UIBarButtonItem] = []
        if (side == "right") {
            let more = UIBarButtonItem(
                image: UIImage(systemName: "square.stack"),
                style: .plain,
                target: self,
                action: #selector(handleOpenOptions)
            )
            barbuttonitems.append(more)
            let sortMetric =  userDefaults.object(forKey: "sortMetric")
            if sortMetric as! String == "Custom" {
                let reorder = UIBarButtonItem(
                    image: UIImage(systemName: "arrow.up.arrow.down.square"),
                    style: .plain,
                    target: self,
                    action: #selector(handleReorderWorkout)
                )
                barbuttonitems.append(reorder)
            }
        } else if (side == "left") {
            Task {
                if let saveHistoryButton = await checkForWorkoutInHistory() {
                    // workout not in history
                    print("in here!", saveHistoryButton)
                    barbuttonitems.append(saveHistoryButton)
                    self.navigationItem.leftBarButtonItems = barbuttonitems
                    startTimer(interval: 5.0 * 60.0) // 5 minutes
                }
            }
        }
        
        return barbuttonitems
    }
    
    func sortExercises() {
        print("sorting exercises")
        let sortMetric =  userDefaults.object(forKey: "sortMetric")
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
    @objc func fetchCategories() async throws {
        print("fetching categories in HomeController")
        guard let uid = Auth.auth().currentUser?.uid else { throw URLError(.userAuthenticationRequired) }
        if isSignedIn == true {
            categories = []
            do {
                let snapshot = try await db.collection("Users")
                  .document(uid)
                  .collection("Category")
                  .getDocuments()
              
                for document in snapshot.documents {
                    let data = document.data()
                    let name = data["name"] as? String ?? ""
                    self.categories.append(name)
                }
            
                userDefaults.setValue(self.categories, forKey: "myKey")
    
              } catch {
                  debugPrint("Error fetching categories: \(error)")
                  throw error
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
        if categories.count != 0 {
            if activeSegment >= 0 && activeSegment >= categories.count {
                activeSegment = 0
            }
            workoutCategorySelectorTextField.text = categories[activeSegment]
            UserDefaults.standard.setValue(categories[activeSegment], forKey: "selectedCategory")
            let showHidden = userDefaults.object(forKey: "showHidden") as? Bool ?? true
            self.exerciseCollectionRef = db.collection("Users").document(uid).collection("Category").document(categories[activeSegment]).collection("Exercises")
                if showHidden {
                    self.exerciseCollectionRef.getDocuments { (snapshot, error) in
                        if let err = error {
                            debugPrint("Error fetching exercises: \(err)")
                        } else {
                            guard let snap = snapshot else { return }
                            self.processSnapshot(snapshot: snap, uid: uid, category: self.categories[self.activeSegment])
                        }
                    }
                } else {
                    self.exerciseCollectionRef.whereField("hidden", isNotEqualTo: true).getDocuments { (snapshot, error) in
                        if let err = error {
                            debugPrint("Error fetching exercises: \(err)")
                        } else {
                            guard let snap = snapshot else { return }
                            self.processSnapshot(snapshot: snap, uid: uid, category: self.categories[self.activeSegment])
                        }
                    }
                }
            }
    }
    
    func findCategoryInHistory() async throws -> Bool {
        print("findCategoryInHistory")
        guard let uid = Auth.auth().currentUser?.uid else { throw URLError(.userAuthenticationRequired) }
        let currentDate = Utilities.timestampToFormattedDate(timeStamp: "\(Date().timeIntervalSince1970)", monthAbbrev: "MMMM")
        do {
            let querySnapshot = try await db.collection("Users")
              .document(uid)
              .collection("History")
              .whereField("date", isEqualTo: currentDate)
              .getDocuments()
          
            for document in querySnapshot.documents {
                let data = document.data()
                let category = data["category"] as? String ?? ""
                
                if category == categories[activeSegment] {
                    return true
                }
            }
            return false

          } catch {
              debugPrint("Error in function findCategoryInHistory: \(error)")
              throw error
          }
    }
    
    private func processSnapshot(snapshot: QuerySnapshot, uid: String, category: String) {
        print("processing snapshot")
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
                db.collection("Users").document(uid).collection("Category").document(category).collection("Exercises").document(name).updateData(["hidden": false])
            }
            let hidden = data["hidden"] as? Bool ?? false
             
            let newExercise = Exercise(name: name, category: category, timeStamp: timeStamp, location: location, weight: weight, reps: reps, note: note, hidden: hidden)
            self.exercises.append(newExercise)

        }
        self.sortExercises()
    }
    
    @MainActor
    private func checkForWorkoutInHistory() async -> UIBarButtonItem? {
        let saveHistory = UIBarButtonItem(
            image: UIImage(named: "square.and.arrow.down.badge.clock"),
            style: .plain,
            target: self,
            action: #selector(handleAddToHistory)
        )
        var categoryFound: Bool = false
        do {
           try await categoryFound = findCategoryInHistory()
           if (!categoryFound) {
               return saveHistory
           }
           return nil
       } catch {
           print("Failed to find category in history: \(error)")
           return nil
       }
    }
    
    func startTimer(interval: TimeInterval) {
        timer?.invalidate()
        timer = Timer.scheduledTimer(timeInterval: interval, target: self, selector: #selector(saveWorkoutReminderAlert), userInfo: nil, repeats: false)
    }
    
    @objc func saveWorkoutReminderAlert() {
        let alert = UIAlertController(title: "You Grinding?", message: "Add this workout to your recents?", preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Skip", style: .cancel, handler: nil ))
        alert.addAction(UIAlertAction(title: "Add", style: .default, handler: { _ in
            self.handleAddToHistory()
        }))
        present(alert, animated: true, completion: nil)
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
        Task {
           do {
               try await fetchCategories()
               fetchExercises()

               DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                   self.tableView.refreshControl?.endRefreshing()
               }
           } catch {
               print("Failed to fetch categories: \(error)")
               self.tableView.refreshControl?.endRefreshing()
           }
        }
        print("down here!")
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
    @objc func handleOpenOptions() {
        let color = Utilities.loadTheme()
        let addWorkout = UIAlertAction(title: "New Exercise", style: .default) { action in
            let newExerciseController = NewExerciseController()
            let navController = CustomNavigationController(rootViewController: newExerciseController)
            newExerciseController.delegate = self
            self.present(navController, animated: true, completion: nil)
        }
        let addCategory = UIAlertAction(title: "New Category", style: .default) { action in
            let newCategoryController = NewCategoryController()
            let navController = CustomNavigationController(rootViewController: newCategoryController)
            newCategoryController.delegate = self
            self.present(navController, animated: true, completion: nil)
        }
        let settings = UIAlertAction(title: "Settings", style: .default) { action in
            let settingsController = SettingsController()
            let navController = CustomNavigationController(rootViewController: settingsController)
            settingsController.delegate = self
            self.present(navController, animated: true, completion: nil)
        }
        let recents = UIAlertAction(title: "Recent Workouts", style: .default) { action in
            let recentsController = RecentsController()
            let navController = CustomNavigationController(rootViewController: recentsController)
            recentsController.delegate = self
            recentsController.category = self.categories[self.activeSegment]
            self.present(navController, animated: true, completion: nil)
        }
        //alert
        // change color of alert text
        addWorkout.setValue(color, forKey: "titleTextColor")
        addCategory.setValue(color, forKey: "titleTextColor")
        settings.setValue(color, forKey: "titleTextColor")
        recents.setValue(color, forKey: "titleTextColor")
        
        let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
        cancelAction.setValue(UIColor.red, forKey: "titleTextColor")
        
        optionMenu.addAction(addWorkout)
        optionMenu.addAction(addCategory)
        optionMenu.addAction(settings)
        optionMenu.addAction(recents)
        optionMenu.addAction(cancelAction)
        self.present(optionMenu, animated: true, completion: nil)
    }
    
    @objc func handleWorkoutHistory() {
        let reorderController = ReorderController()
        let navController = CustomNavigationController(rootViewController: reorderController)
        reorderController.delegate = self
        self.present(navController, animated: true, completion: nil)
    }
    
    @objc func handleAddToHistory() {
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let historyRef = db.collection("Users").document(uid).collection("History").document()
        let id = historyRef.documentID
        db.collection("Users").document(uid).collection("History").document(id).setData([
            "id": id,
            "timestamp": "\(NSDate().timeIntervalSince1970)",
            "date": Utilities.timestampToFormattedDate(timeStamp: "\(Date().timeIntervalSince1970)", monthAbbrev: "MMMM"),
            "category": categories[activeSegment]
        ])
        if var leftBarButtonItems = navigationItem.leftBarButtonItems {
            leftBarButtonItems.removeLast()  // Remove the last item
            navigationItem.leftBarButtonItems = leftBarButtonItems // Update the navigation item's leftBarButtonItems
        }
        timer?.invalidate()
    
    }
    
    @objc private func handleSignIn() {
        print("Sign in")
        let signInController = SignInController()
        // push into new viewcontroller
        navigationController?.pushViewController(signInController, animated: true)
    }
    
    func refreshTheme() {
        navigationItem.rightBarButtonItems = populateBarBtnItems(side: "right") // refresh the right barbuttons
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
    
    // this function is only used in the protocol RecentsControllerDelegate to refresh the save workout into recents on "done" button tap if user deletes a recent workout
    func populateLeftBarButtonItem() {
        navigationItem.leftBarButtonItems = populateBarBtnItems(side: "left")
    }
    


}

