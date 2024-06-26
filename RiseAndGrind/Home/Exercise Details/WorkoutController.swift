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
    func fetchCategories()
}

class WorkoutController: UITableViewController {
    var delegate: WorkoutControllerDelegate?
    var sets = [String]()
    
    
    var weight = [String]()
    var reps = [String]()
    
    var categoryCollectionReference: CollectionReference!
    
    var SCIndex = 0
    
    let db = Firestore.firestore()
    
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
        
        tableView.backgroundColor = .darkGray
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        categoryCollectionReference = Firestore.firestore().collection("Category")

        
        fetchSets()
        setupUI()
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
        for cell in setCell {
            if cell.weightTextField.text == "" {
                weight.append("0")
            } else {
                weight.append(cell.weightTextField.text ?? "")
            }
            //weight.append(cell.weightTextField.text ?? "0")
            reps.append(cell.repsTextField.text ?? "-")
        }
        db.collection("Users").document(uid).collection("Category").document(category).collection("Exercises").document(name).updateData(["name" : name,
                                                                                                     "category" : category,
                                                                                                     "timestamp" : "\(timestamp)",
                                                                                                     "weight" : weight,
                                                                                                     "reps" : reps,
                                                                                                     "note" : note])

        dismiss(animated: true, completion: {self.delegate?.fetchCategories() })
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
                for _ in 0...(setCount - 1) {
                    self.sets.append("set added")
                }
                self.tableView.reloadData()
            }
            let setCell: [WeightRepsCell] = self.tableView.visibleCells as? [WeightRepsCell] ?? []
            var i = 0
            for cell in setCell {
                print("setCell.count = \(setCell.count)")
                cell.weightTextField.text = weightList[i]
                cell.repsTextField.text = repsList[i]
                i += 1
            }
        }
    }
    

    
    @objc private func handleButtonPressed(sender:UIButton) {
        print("Plus button pressed")
        // add animation to the button
        Utilities.animateView(sender)
        sets.append("Set added")

        
        tableView.reloadData()
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
        let currentDateTime = Date()
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
                                                                                                     "timestamp" :  formatter.string(from: currentDateTime),
                                                                                                     "weight" : weight,
                                                                                                     "reps" : reps,
                                                                                                     "note" : note])
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
            self.hud.textLabel.text = "Success!"
            self.hud.dismiss(afterDelay: 0.75, animated: true)
        }
    }
    
    @objc func handleOpenArchiveButton(sender:UIButton) {
        print("opening archive")
        Utilities.animateView(sender)
        
        let archiveController = ArchiveController()
        let navController = CustomNavigationController(rootViewController: archiveController)
        
        archiveController.navigationItem.title = "\(nameTextField.text ?? "") Archive"
        print("nameTextField = \(nameTextField)")
        archiveController.nameTextField.text = nameTextField.text
        archiveController.categoryTextField.text = categorySelectorTextField.text
        
        // push into new viewcontroller
        present(navController, animated: true, completion: nil)
    }
    


    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Title",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .darkGray
        textField.backgroundColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        textField.addLine(position: .bottom, color: UIColor.lightBlue, width: 0.5)
        textField.isUserInteractionEnabled = false
        return textField
    }()

    
    // create text field for category entry
    let categorySelectorTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Select category",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .darkGray
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        textField.addLine(position: .bottom, color: UIColor.lightBlue, width: 0.5)
        textField.tintColor = UIColor.clear
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.isUserInteractionEnabled = false
        return textField
    }()

    // create text field for notes entry
    let notesTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Note",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        textField.addLine(position: .bottom, color: UIColor.lightBlue, width: 0.5)
        textField.tintColor = UIColor.lightBlue
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    let addButton: UIButton = {
        let button = UIButton()
        //button.backgroundColor = UIColor.red
        button.layer.borderWidth = 2
        button.layer.borderColor = UIColor.lightBlue.cgColor
        button.layer.cornerRadius = 10
        button.setImage(UIImage(named: "add"), for: .normal)
        button.setTitleColor(UIColor.lightBlue, for: .normal)
        button.backgroundColor = .lightBlue
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 32.0)
        button.addTarget(self, action: #selector(handleButtonPressed(sender:)), for: .touchUpInside)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()
    
    // create button to archive
    let archiveThisButton: UIButton = {
        let button = UIButton()

        button.backgroundColor = .lightBlue
        button.setTitle("Archive Workout", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.addTarget(self, action: #selector(handleArchiveThisButton(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        // add animation to the button
        
        return button
    }()
    
    // create button to view archive
    let openArchiveButton: UIButton = {
        let button = UIButton()

        button.backgroundColor = .white
        //button.tintColor = .lightBlue
        
        button.setTitle("Open Archive", for: .normal)
        button.setTitleColor(.white, for: .normal)
        button.layer.cornerRadius = 10
        button.layer.borderColor = UIColor.lightBlue.cgColor
        button.layer.borderWidth = 1
        button.addTarget(self, action: #selector(handleOpenArchiveButton(sender:)), for: .touchUpInside)
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        button.setTitleColor(.lightBlue, for: .normal)
        // enable autolayout
        button.translatesAutoresizingMaskIntoConstraints = false
        // add animation to the button
        
        return button
    }()

    
    
    func setupUI() {
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 266))
        header.backgroundColor = .white

        let headerTextField = UITextField(frame: header.bounds)
        //let workoutSC = UISegmentedControl(frame: header.bounds)
        let workoutTF = UITextField(frame: header.bounds)
        let button = UIButton(frame: header.bounds)
        let archiveThisBtn = UIButton(frame: header.bounds)
        let openArchiveBtn = UIButton(frame: header.bounds)
        //headerView.backgroundColor = .lightBlue
        header.addSubview(headerTextField)
        //header.addSubview(workoutSC)
        header.addSubview(workoutTF)
        header.addSubview(button)
        header.addSubview(archiveThisBtn)
        header.addSubview(openArchiveBtn)
        
        
        
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
        addButton.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -8).isActive = true
        addButton.heightAnchor.constraint(equalToConstant: 40).isActive = true
        addButton.widthAnchor.constraint(equalToConstant: 40).isActive = true
        
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
    

    
    
}
