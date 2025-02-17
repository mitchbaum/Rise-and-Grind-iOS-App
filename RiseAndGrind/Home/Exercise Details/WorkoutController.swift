//
//  WorkoutController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 11/1/21.
//


import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import JGProgressHUD
import FirebaseStorage

protocol WorkoutControllerDelegate {
    func fetchExercises()
}

class WorkoutController: UITableViewController {
    var delegate: WorkoutControllerDelegate?
    var sets = [Set]()
    
    
    var weight = [String]()
    var reps = [String]()
    
    var categoryCollectionReference: CollectionReference!
    
    var SCIndex = 0
    
    let db = Firestore.firestore()

    let weightMetric = UserDefaults.standard.object(forKey: "weightMetric")
    
    var lastUpdatedTimestamp = ""
    
    // add loading HUD status for when fetching data from server
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // creates title of files
        navigationItem.title = "Editing Workout"
        navigationItem.largeTitleDisplayMode = .never
        
        // register fileCell wiht cellId
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(WeightRepsCell.self, forCellReuseIdentifier: WeightRepsCell.identifier)
        
        tableView.backgroundColor = Utilities.loadAppearanceTheme(property: "secondary")
        tableView.separatorColor =  Utilities.loadAppearanceTheme(property: "secondary")
        tableView.tableFooterView = UIView()
//        tableView.setEditing(true, animated: true)
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        categoryCollectionReference = Firestore.firestore().collection("Category")

        
        fetchSets()
        setupUI()
       // reorder()
    }
    
    override func setEditing(_ editing: Bool, animated: Bool) {
        super.setEditing(editing, animated: animated)
        tableView.setEditing(editing, animated: animated)
    }
    
    @objc func toggleEditing(sender:UISegmentedControl) {
        let isReordering = sender.selectedSegmentIndex == 1
        setEditing(isReordering, animated: true)
    }
    
    
    @objc private func handleSave() {
        print("saving exercise")
        let name = nameTextField.text!
        let category = categorySelectorTextField.text!
        let note = notesTextField.text!
        weight = []
        reps = []
        let timestamp = NSDate().timeIntervalSince1970
        let setCell: [WeightRepsCell] = self.tableView.visibleCells as? [WeightRepsCell] ?? []
        
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let analyticsRef = db.collection("Users").document(uid).collection("Category").document(category).collection("Exercises").document(name).collection("Analytics").document()
        let id = analyticsRef.documentID
        for cell in setCell {
            if cell.weightTextField.text == "" {
                weight.append("0")
            } else {
                if self.weightMetric as? Int == 1 {
                    weight.append("\((Int((Double(cell.weightTextField.text ?? "") ?? 0.0).rounded() * 2.204623)))") // if KG, always convert to LBS
                } else {
                    weight.append(cell.weightTextField.text ?? "")
                }
                
            }
            reps.append(cell.repsTextField.text ?? "-")
        }
        db.collection("Users").document(uid).collection("Category").document(category).collection("Exercises").document(name).updateData(["name" : name,
                                                                                                     "category" : category,
                                                                                                     "timestamp" : "\(timestamp)",
                                                                                                     "weight" : weight,
                                                                                                     "reps" : reps,
                                                                                                     "note" : note])
        db.collection("Users").document(uid).collection("Category").document(category).collection("Exercises").document(name).collection("Analytics").document(id).setData([
                                                                                                     "timestamp" : "\(timestamp)",
                                                                                                     "weight" : weight,
                                                                                                     "reps" : reps,
                                                                                                     "id": id
                                                                                                     ])
        

        dismiss(animated: true, completion: {
            self.delegate?.fetchExercises()
            
        })
    }
    
    

    
    func fetchSets() {
        let category = categorySelectorTextField.text
        let name = nameTextField.text
        var setCount = 0
        var repsList = [String]()
        var weightList = [String]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).collection("Category").document(category!).collection("Exercises").document(name!).getDocument { snapshot, error in
            if let err = error {
                debugPrint("Error fetching workout: \(err)")
            } else {
                if let data = snapshot?.data() {
                    let reps = data["reps"] as? Array<String>
                    let weight = data["weight"] as? Array<String>
                    let note = data["note"] as? String

                    setCount = reps?.count ?? 0
                    repsList = reps!
                    weightList = weight!
                    self.notesTextField.text = note

                }
            }
            if setCount > 0 {
                for i in 0...(setCount - 1) {
                    print(i)
                    self.sets.append(Set(weight: weightList[i], reps: repsList[i]))
                }
                self.tableView.reloadData()
            }
            let setCell: [WeightRepsCell] = self.tableView.visibleCells as? [WeightRepsCell] ?? []
            var i = 0
            for cell in setCell {
                if self.weightMetric as? Int == 0 {
                    if weightList[i].trimmingCharacters(in: .whitespaces).suffix(2) == ".5" {
                        weightList[i] = "\((Double(weightList[i]) ?? 0.0) * 1.0)"
                    } else {
                        weightList[i] = "\((Int((Double(weightList[i]) ?? 0.0) * 1.0)))"
                    }
                } else {
                    weightList[i] = "\((Int((Double(weightList[i]) ?? 0.0) * 0.453592)))"

                }
                cell.weightTextField.text = weightList[i]
                cell.repsTextField.text = repsList[i]
                i += 1
            }
        }
    }
    

    
    @objc private func handleButtonPressed(sender:UIButton) {
        // add animation to the button
        Utilities.animateView(sender)
        let set = Set(weight: "0", reps: "0")
        
        sets.append(set)
        let indexPath = IndexPath(row: sets.count - 1, section: 0)
        tableView.beginUpdates()
        tableView.insertRows(at: [indexPath], with: .automatic)
        tableView.endUpdates()
        
        // Optionally scroll to the bottom to show the new item
        tableView.scrollToRow(at: indexPath, at: .bottom, animated: true)
    }
    
    @objc func handleArchiveThisButton(sender:UIButton) {
        print("archiving workout")
        Utilities.animateView(sender)
        hud.textLabel.text = "Archiving Workout"
        hud.show(in: view, animated: true)
        
        let name = nameTextField.text!
        let category = categorySelectorTextField.text!
        let note = notesTextField.text!
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("Users").document(uid).collection("Category").document(category).collection("Exercises").document(name).collection("Archive").document()
        let id = ref.documentID
        weight = []
        reps = []
        let lastUpdated = Date(timeIntervalSince1970: Double(lastUpdatedTimestamp) ?? 0.0)
        let formatter = DateFormatter()
        
        formatter.timeStyle = .none
        formatter.dateStyle = .long
        let setCell: [WeightRepsCell] = self.tableView.visibleCells as? [WeightRepsCell] ?? []
        
        for cell in setCell {
            if cell.weightTextField.text == "" {
                weight.append("0")
            } else {
                weight.append(cell.weightTextField.text ?? "")
            }
            //weight.append(cell.weightTextField.text ?? "0")
            reps.append(cell.repsTextField.text ?? "-")
        }
    
        db.collection("Users").document(uid).collection("Category").document(category).collection("Exercises").document(name).collection("Archive").document(id).setData(["name" : name,
                                                                                                                                        "id" : id,
                                                                                                     "category" : category,
                                                                                                     "timestamp" :  formatter.string(from: lastUpdated),
                                                                                                     "weight" : weight,
                                                                                                     "reps" : reps,
                                                                                                     "note" : note])
        self.hud.dismiss(animated: true)
    }
    
    @objc func handleOpenArchiveButton(sender:UIButton) {
        Utilities.animateView(sender)
        
        let archiveController = ArchiveController()
        let navController = CustomNavigationController(rootViewController: archiveController)
        
        archiveController.navigationItem.title = "\(nameTextField.text ?? "") Archive"
        archiveController.nameTextField.text = nameTextField.text
        archiveController.categoryTextField.text = categorySelectorTextField.text
        
        // push into new viewcontroller
        navigationController?.pushViewController(archiveController, animated: true)
    }
    
    @objc func handleOpenAnalyticsButton(sender:UIButton) {
        Utilities.animateView(sender)
        
        let analyticsController = AnalyticsController()
        let navController = CustomNavigationController(rootViewController: analyticsController)
        
        analyticsController.navigationItem.title = "Analytics"
        analyticsController.exerciseName = nameTextField.text ?? ""
        analyticsController.exerciseCategory = categorySelectorTextField.text ?? ""
        analyticsController.name.text = nameTextField.text
        analyticsController.category.text = categorySelectorTextField.text
        
        // push into new viewcontroller
        navigationController?.pushViewController(analyticsController, animated: true)
    }
    


    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Title",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = Utilities.loadAppearanceTheme(property: "text")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        textField.addLine(position: .bottom, color: Utilities.loadTheme(), width: 0.5)
        textField.isUserInteractionEnabled = false
        return textField
    }()

    
    // create text field for category entry
    let categorySelectorTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Select category",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = Utilities.loadAppearanceTheme(property: "text")
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        textField.addLine(position: .bottom, color: Utilities.loadTheme(), width: 0.5)
        textField.tintColor = UIColor.clear
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = false
        return textField
    }()

    // create text field for notes entry
    let notesTextField: UITextField = {
        let textField = UITextField()
        let color = Utilities.loadTheme()
        textField.attributedPlaceholder = NSAttributedString(string: "Note",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = Utilities.loadAppearanceTheme(property: "text")
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        textField.addLine(position: .bottom, color: color, width: 0.5)
        textField.tintColor = color
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        let color = Utilities.loadTheme()
        let appearanceTheme = UserDefaults.standard.object(forKey: "appearanceTheme")
        button.setImage(UIImage(systemName: "plus.app.fill"), for: .normal)
        button.tintColor = color
        button.addTarget(nil, action: #selector(handleButtonPressed(sender:)), for: .touchUpInside)
        button.imageView?.contentMode = .scaleAspectFit
        button.contentVerticalAlignment = .fill
        button.contentHorizontalAlignment = .fill
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // create button to archive
    let archiveThisButton: UIButton = {
        let button = UIButton()
        let color = Utilities.loadTheme()
        button.backgroundColor = color
        button.setTitle("Archive Workout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(nil, action: #selector(handleArchiveThisButton(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        // add animation to the button
        
        return button
    }()
    
    // create button to view archive
    let openArchiveButton: UIButton = {
        let button = UIButton()
        let color = Utilities.loadTheme()
        let appearanceTheme = UserDefaults.standard.object(forKey: "appearanceTheme") as? String
        button.backgroundColor = appearanceTheme == "Light" ? UIColor.white : nil
        //button.tintColor = .lightBlue
        
        button.setTitle("Open Archive", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleOpenArchiveButton(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        button.setTitleColor(color, for: .normal)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        // add animation to the button
        
        return button
    }()
    
    let openAnalyticsButton: UIButton = {
        let button = UIButton()
        let color = Utilities.loadTheme()
        let appearanceTheme = UserDefaults.standard.object(forKey: "appearanceTheme") as? String
        button.backgroundColor = appearanceTheme == "Light" ? UIColor.white : nil
        //button.tintColor = .lightBlue
        
        button.setTitle("Open Analytics", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleOpenAnalyticsButton(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        button.setTitleColor(color, for: .normal)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        // add animation to the button
        
        return button
    }()
    
    let reorderSetsControl: UISegmentedControl = {
        let types = ["Swipe to Delete", "Reorder Sets"]
        let sc = UISegmentedControl(items: types)
        let color = Utilities.loadTheme()
        sc.selectedSegmentIndex = 0
        sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentTintColor = color
        // changes text color to black for selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        // changes text color to black for non selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Utilities.loadAppearanceTheme(property: "text")], for: .normal)
        
        sc.addTarget(self, action: #selector(toggleEditing(sender:)), for: .valueChanged)

        return sc
    }()

    
    
    func setupUI() {
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 350))
        header.backgroundColor = Utilities.loadAppearanceTheme(property: "primary")

        let headerTextField = UITextField(frame: header.bounds)
        //let workoutSC = UISegmentedControl(frame: header.bounds)
        let workoutTF = UITextField(frame: header.bounds)
        let button = UIButton(frame: header.bounds)
        let archiveThisBtn = UIButton(frame: header.bounds)
        let openArchiveBtn = UIButton(frame: header.bounds)
        let reorderSetsBtn = UIButton(frame: header.bounds)
        let openAnalyticsBtn = UIButton(frame: header.bounds)
        //headerView.backgroundColor = .lightBlue
        header.addSubview(headerTextField)
        //header.addSubview(workoutSC)
        header.addSubview(workoutTF)
        header.addSubview(button)
        header.addSubview(archiveThisBtn)
        header.addSubview(openArchiveBtn)
        header.addSubview(reorderSetsBtn)
        header.addSubview(openAnalyticsBtn)
        
        
        
        
        header.addSubview(nameTextField)
        nameTextField.topAnchor.constraint(equalTo: headerTextField.topAnchor, constant: 16).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 16).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //nameTextField.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        // add and position deductible textfield element to the right of the nameLabel
        header.addSubview(categorySelectorTextField)
        categorySelectorTextField.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 16).isActive = true
        categorySelectorTextField.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        categorySelectorTextField.topAnchor.constraint(equalTo: nameTextField.bottomAnchor).isActive = true
        categorySelectorTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        // add and position deductible textfield element to the right of the nameLabel
        header.addSubview(notesTextField)
        notesTextField.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 16).isActive = true
        notesTextField.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        notesTextField.topAnchor.constraint(equalTo: categorySelectorTextField.bottomAnchor).isActive = true
        notesTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        header.addSubview(addButton)
        addButton.topAnchor.constraint(equalTo: notesTextField.bottomAnchor, constant: 16).isActive = true
        addButton.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -12).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 45).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 45).isActive = true
        
        header.addSubview(archiveThisButton)
        archiveThisButton.topAnchor.constraint(equalTo: notesTextField.bottomAnchor, constant: 16).isActive = true
        archiveThisButton.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 8).isActive = true
        archiveThisButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        archiveThisButton.widthAnchor.constraint(equalToConstant: 155).isActive = true
        
        header.addSubview(openArchiveButton)
        openArchiveButton.topAnchor.constraint(equalTo: archiveThisButton.bottomAnchor, constant: 8).isActive = true
        openArchiveButton.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 8).isActive = true
        openArchiveButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        openArchiveButton.widthAnchor.constraint(equalToConstant: 155).isActive = true
        
        header.addSubview(openAnalyticsButton)
        openAnalyticsButton.topAnchor.constraint(equalTo: openArchiveButton.bottomAnchor, constant: 8).isActive = true
        openAnalyticsButton.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 8).isActive = true
        openAnalyticsButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        openAnalyticsButton.widthAnchor.constraint(equalToConstant: 155).isActive = true
        
        header.addSubview(reorderSetsControl)
        reorderSetsControl.topAnchor.constraint(equalTo: openAnalyticsButton.bottomAnchor, constant: 16).isActive = true
        reorderSetsControl.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 8).isActive = true
        reorderSetsControl.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -8).isActive = true
        
        
        
        tableView.tableHeaderView = header
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    
    func reorder() {
        if tableView.isEditing {
            tableView.isEditing = false
        } else {
            tableView.isEditing = true
        }
    }
    

    
    
}
