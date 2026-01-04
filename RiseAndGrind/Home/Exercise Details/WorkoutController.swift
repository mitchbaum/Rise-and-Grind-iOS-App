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
class WorkoutController: UITableViewController, LinkedExercisesControllerDelegate {
    var delegate: WorkoutControllerDelegate?
    var sets = [Set]()
    
    
    var weight = [String]()
    var reps = [String]()
    
    var categoryCollectionReference: CollectionReference!
    let linkedExercisesController = LinkedExercisesController()
    var SCIndex = 0
    
    let db = Firestore.firestore()
    
    let weightMetric = UserDefaults.standard.object(forKey: "weightMetric")
    
    var lastUpdatedTimestamp = ""
    var originCategory = ""
    var linkedCategories: [LinkedInfo] = []
    var linkedCategoriesChanged = false

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
        navigationItem.title = "Editing Exercise"
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
        
//        categorySelectorTextField.text = originCategory
        categoryCollectionReference = Firestore.firestore().collection("Category")
        
        initialize()
    }
    
    func initialize() {
        Task {
           do {
               setupUI()
               try await fetchLinkedCategories()
               try await fetchSets()
           } catch {
               print("Failed to initialize workout controller: \(error)")
           }
        }
    }
    
    func fetchLinkedCategories() async throws {
        linkedCategories = []
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let documentRef = db.collection("Users").document(uid).collection("LinkedExercises").whereField("originCategory", isEqualTo: originCategory)
        do {
            let snapshot = try await documentRef.getDocuments()
            for document in snapshot.documents {
                let data = document.data()
                let id = data["id"] as? String
                let exerciseName = data["exerciseName"] as? String
                let originCategory = data["originCategory"] as? String
                let categoriesDicts = data["categories"] as? [[String: Any]] ?? []
                // Map dictionaries to LinkedInfo structs
                let categories: [LinkedInfo] = categoriesDicts.compactMap { dict in
                    guard let category = dict["category"] as? String,
                          let location = dict["location"] as? Int,
                          let hidden = dict["hidden"] as? Bool else { return nil }
                    return LinkedInfo(category: category, location: location, hidden: hidden)
                }
                let exercise = LinkedExercise(id: id, exerciseName: exerciseName, originCategory: originCategory, categories: categories)
                linkedExercisesController.exerciseLinkDetails = exercise
                linkedCategories = categories
                print("linkedCategories", linkedCategories)
            }
            // add category name to start of linkedCategories array
            linkedCategories.insert(LinkedInfo(category: originCategory, location: 0, hidden: false), at: 0)
            loadLinkedStackView()
        } catch {
            debugPrint("Error fetching linked categories: \(error)")
            throw error
        }
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
        let note = notesTextField.text!
        weight = []
        reps = []
        let timestamp = NSDate().timeIntervalSince1970
        let setCell: [WeightRepsCell] = self.tableView.visibleCells as? [WeightRepsCell] ?? []
        
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let analyticsRef = db.collection("Users").document(uid).collection("Category").document(originCategory).collection("Exercises").document(name).collection("Analytics").document()
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
        db.collection("Users").document(uid).collection("Category").document(originCategory).collection("Exercises").document(name).updateData(["name" : name,
                                                                                                                                          "category" : originCategory,
                                                                                                                                          "timestamp" : "\(timestamp)",
                                                                                                                                          "weight" : weight,
                                                                                                                                          "reps" : reps,
                                                                                                                                          "note" : note])
        db.collection("Users").document(uid).collection("Category").document(originCategory).collection("Exercises").document(name).collection("Analytics").document(id).setData([
            "timestamp" : "\(timestamp)",
            "weight" : weight,
            "reps" : reps,
            "id": id
        ])
        
        
        dismiss(animated: true, completion: {
            self.delegate?.fetchExercises()
            
        })
    }
    
    
    
    
    func fetchSets() async throws {
        let name = nameTextField.text
        var setCount = 0
        var repsList = [String]()
        var weightList = [String]()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        do {
            let snapshot = try await db.collection("Users").document(uid).collection("Category").document(originCategory).collection("Exercises").document(name!).getDocument()
            if let data = snapshot.data() {
                let reps = data["reps"] as? Array<String>
                let weight = data["weight"] as? Array<String>
                let note = data["note"] as? String
                
                setCount = reps?.count ?? 0
                repsList = reps!
                weightList = weight!
                self.notesTextField.text = note
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
            
        } catch {
            debugPrint("Error fetching sets: \(error)")
            throw error
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
        let note = notesTextField.text!
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let ref = db.collection("Users").document(uid).collection("Category").document(originCategory).collection("Exercises").document(name).collection("Archive").document()
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
        
        db.collection("Users").document(uid).collection("Category").document(originCategory).collection("Exercises").document(name).collection("Archive").document(id).setData(["name" : name,
                                                                                                                                                                          "id" : id,
                                                                                                                                                                          "category" : originCategory,
                                                                                                                                                                          "timestamp" :  formatter.string(from: lastUpdated),
                                                                                                                                                                          "weight" : weight,
                                                                                                                                                                          "reps" : reps,
                                                                                                                                                                          "note" : note])
        self.hud.dismiss(animated: true)
    }
    
    @objc func handleOpenArchiveButton(sender:UIButton) {
        Utilities.animateView(sender)
        let archiveController = ArchiveController()
        archiveController.navigationItem.title = "\(nameTextField.text ?? "") Archive"
        archiveController.nameTextField.text = nameTextField.text
        archiveController.categoryTextField.text = originCategory
        
        // push into new viewcontroller
        navigationController?.pushViewController(archiveController, animated: true)
    }
    
    @objc func handleOpenAnalyticsButton(sender:UIButton) {
        Utilities.animateView(sender)
        
        let analyticsController = AnalyticsController()
        analyticsController.navigationItem.title = "Analytics"
        analyticsController.exerciseName = nameTextField.text ?? ""
        analyticsController.exerciseCategory = originCategory
        analyticsController.name.text = nameTextField.text
        analyticsController.category.text = originCategory
        
        // push into new viewcontroller
        navigationController?.pushViewController(analyticsController, animated: true)
    }
    
    @objc func handlOpenLinkedCategoriesButton(sender:UIButton) {
        let navController = CustomNavigationController(rootViewController: linkedExercisesController)
        linkedExercisesController.items = Array(linkedCategories.dropFirst())
        linkedExercisesController.originCategory = originCategory
        linkedExercisesController.exerciseName = nameTextField.text ?? ""
        linkedExercisesController.navigationItem.title = "Linked Categories"
        linkedExercisesController.delegate = self
        linkedCategoriesChanged = true
        // Configure sheet presentation
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()] // Set to medium (half height) and large (full screen)
            sheet.prefersGrabberVisible = true   // Show grabber at the top of the modal
            sheet.preferredCornerRadius = 16     // Optional: add corner radius
        }
        
        self.present(navController, animated: true, completion: nil)
    }
    
    
    
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Title",
                                                             attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = Utilities.loadAppearanceTheme(property: "text")
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        textField.font = UIFont.boldSystemFont(ofSize: 18.0)
        textField.addLine(position: .bottom, color: Utilities.loadTheme(), width: 0.5)
        textField.isUserInteractionEnabled = false
        return textField
    }()

    let linkedCategoriesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .center
        stackView.distribution = .equalSpacing
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()

    
    let linkButton: UIButton = {
        let button = UIButton()
        let color = Utilities.loadTheme()
        let appearanceTheme = UserDefaults.standard.object(forKey: "appearanceTheme") as? String
        button.backgroundColor = color
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 14, weight: .medium)
        let image = UIImage(systemName: "link", withConfiguration: symbolConfig)
        button.setImage(image, for: .normal)
        button.tintColor = appearanceTheme == "Light" ? .white : Utilities.loadAppearanceTheme(property: "primary")
        button.layer.cornerRadius = 8
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handlOpenLinkedCategoriesButton(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    // create text field for notes entry
    let notesTextField: UITextField = {
        let textField = UITextField()
        let color = Utilities.loadTheme()
        textField.attributedPlaceholder = NSAttributedString(string: "Add a note...",
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
        let appearanceTheme = UserDefaults.standard.object(forKey: "appearanceTheme") as? String
        button.backgroundColor = color
        let symbolConfig = UIImage.SymbolConfiguration(pointSize: 20, weight: .bold)
        let image = UIImage(systemName: "plus", withConfiguration: symbolConfig)
        button.setImage(image, for: .normal)
        button.tintColor = appearanceTheme == "Light" ? .white : Utilities.loadAppearanceTheme(property: "primary")
        button.layer.cornerRadius = 8
        button.layer.borderColor = color.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleButtonPressed(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // create button to archive
    let archiveThisButton: UIButton = {
        let button = UIButton()
        let appearanceTheme = UserDefaults.standard.object(forKey: "appearanceTheme") as? String
        let color = Utilities.loadTheme()
        button.backgroundColor = color
        button.setTitle("Archive Exercise", for: .normal)
        button.setTitleColor(appearanceTheme == "Light" ? .white : Utilities.loadAppearanceTheme(property: "primary"), for: .normal)
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
        let appearanceTheme = UserDefaults.standard.object(forKey: "appearanceTheme") as? String
        sc.selectedSegmentIndex = 0
        sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentTintColor = color
        // changes text color to black for selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: appearanceTheme == "Light" ? UIColor.white : Utilities.loadAppearanceTheme(property: "primary")], for: .selected)
        // changes text color to black for non selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: Utilities.loadAppearanceTheme(property: "text")], for: .normal)
        
        sc.addTarget(self, action: #selector(toggleEditing(sender:)), for: .valueChanged)

        return sc
    }()

    
    
    func setupUI() {
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 290))
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
        nameTextField.topAnchor.constraint(equalTo: headerTextField.topAnchor, constant: 8).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 12).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -12).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        //nameTextField.widthAnchor.constraint(equalToConstant: 120).isActive = true
        
        header.addSubview(linkedCategoriesStackView)
        linkedCategoriesStackView.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 12).isActive = true
        linkedCategoriesStackView.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8).isActive = true
        linkedCategoriesStackView.heightAnchor.constraint(equalToConstant: 30).isActive = true
        
        header.addSubview(linkButton)
        linkButton.topAnchor.constraint(equalTo: nameTextField.bottomAnchor, constant: 8).isActive = true
        linkButton.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -12).isActive = true
        linkButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        linkButton.widthAnchor.constraint(equalToConstant: 30).isActive = true

    
        
        // add and position deductible textfield element to the right of the nameLabel
        header.addSubview(notesTextField)
        notesTextField.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 12).isActive = true
        notesTextField.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -12).isActive = true
        notesTextField.topAnchor.constraint(equalTo: linkedCategoriesStackView.bottomAnchor).isActive = true
        notesTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        header.addSubview(archiveThisButton)
        archiveThisButton.topAnchor.constraint(equalTo: notesTextField.bottomAnchor, constant: 16).isActive = true
        archiveThisButton.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -12).isActive = true
        archiveThisButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        archiveThisButton.widthAnchor.constraint(equalToConstant: 155).isActive = true
        
        header.addSubview(addButton)
        addButton.topAnchor.constraint(equalTo: archiveThisButton.bottomAnchor, constant: 8).isActive = true
        addButton.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -12).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 30).isActive = true
        
        header.addSubview(openArchiveButton)
        openArchiveButton.topAnchor.constraint(equalTo: notesTextField.bottomAnchor, constant: 16).isActive = true
        openArchiveButton.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 12).isActive = true
        openArchiveButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        openArchiveButton.widthAnchor.constraint(equalToConstant: 155).isActive = true
        
        header.addSubview(openAnalyticsButton)
        openAnalyticsButton.topAnchor.constraint(equalTo: openArchiveButton.bottomAnchor, constant: 8).isActive = true
        openAnalyticsButton.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 12).isActive = true
        openAnalyticsButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        openAnalyticsButton.widthAnchor.constraint(equalToConstant: 155).isActive = true
        
        header.addSubview(reorderSetsControl)
        reorderSetsControl.topAnchor.constraint(equalTo: openAnalyticsButton.bottomAnchor, constant: 16).isActive = true
        reorderSetsControl.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 12).isActive = true
        reorderSetsControl.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -12).isActive = true
        
        
        tableView.tableHeaderView = header
    }
    
    func loadLinkedStackView() {
        linkedCategoriesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        linkedCategories.forEach { linked in
            let label = UILabel()
            let view = UIView()
            // Configure the container view
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 5
            view.backgroundColor = Utilities.loadAppearanceTheme(property: "primaryTopCell")
            view.translatesAutoresizingMaskIntoConstraints = false

            // Configure the label
            label.text = linked.category
            label.numberOfLines = 1
            label.lineBreakMode = .byTruncatingTail
            if linked.category == originCategory {
                label.font =  UIFont.boldSystemFont(ofSize: 16.0)
            } else {
                label.font = UIFont.systemFont(ofSize: 16)
            }
            
            label.textColor = Utilities.loadTheme()
            label.translatesAutoresizingMaskIntoConstraints = false

            // Add the label to the container view
            view.addSubview(label)

            // Add constraints to center the label inside the container view
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
            ])

            // Add the container view to the stack view
            linkedCategoriesStackView.addArrangedSubview(view)
        }
    }
    
    @objc func handleCancel() {
        if linkedCategoriesChanged {
            self.delegate?.fetchExercises()
        }
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
