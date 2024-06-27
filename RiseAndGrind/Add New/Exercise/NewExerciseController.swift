//
//  NewExerciseController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 10/6/21.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import JGProgressHUD
import FirebaseStorage

//custom delegation
protocol NewExerciseControllerDelegate {
    func fetchCategories()
}


class NewExerciseController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    var delegate: NewExerciseControllerDelegate?
    var sets = [String]()
    let userDefaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    var weight = [String]()
    var reps = [String]()
    
    var categories = [" "]
    var categoryStrings = [String]()
    
    var categoryCollectionReference: CollectionReference!
    
    var SCIndex = 0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // creates title of files
        navigationItem.title = "New Exercise"
        
        // register fileCell wiht cellId
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(WeightRepsCell.self, forCellReuseIdentifier: WeightRepsCell.identifier)
        
        tableView.backgroundColor = .darkGray
        tableView.separatorColor = .darkGray
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Add", style: .plain, target: self, action: #selector(handleAdd))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        
        categoryCollectionReference = Firestore.firestore().collection("Category")
        print(categories)
        fetchCategories()
        print(categories)
        
        categorySelectorTextField.inputView = categoryPicker
        categoryPicker.delegate = self
        categoryPicker.dataSource = self
        
        setupUI()
    }
    
    
    
    @objc private func handleAdd() {
        print("adding new exercise")
        let name = nameTextField.text!
        let category = categorySelectorTextField.text!
        let locationCounter = userDefaults.object(forKey: "locationCounter") ?? 0
        let note = notesTextField.text!
        if name.contains("/") {
            return showError(title: "Unable to Save", message: "/ is a reserved character. Try using \\ instead.")
        } else if name == "" {
            return showError(title: "Unable to add exercise", message: "Please fill in the name field.")
        } else if category == "" {
            return showError(title: "Unable to add exercise", message: "Please fill in the category field.")
        } else {
            weight = []
            reps = []
            let timestamp = NSDate().timeIntervalSince1970
            let setCell: [WeightRepsCell] = self.tableView.visibleCells as? [WeightRepsCell] ?? []
            
            let db = Firestore.firestore()
            for cell in setCell {
                if cell.weightTextField.text == "" {
                    weight.append("0")
                } else {
                    weight.append(cell.weightTextField.text ?? "")
                }
                //weight.append(cell.weightTextField.text ?? "0")
                reps.append(cell.repsTextField.text ?? "-")
            }
            guard let uid = Auth.auth().currentUser?.uid else { return }
            db.collection("Users").document(uid).collection("Category").document(category).collection("Exercises").document(name).setData(["name" : name,
                                                                                                         "category" : category,
                                                                                                         "location" : locationCounter as! Int + 1,
                                                                                                         "timestamp" : "\(timestamp)",
                                                                                                         "weight" : weight,
                                                                                                         "reps" : reps,
                                                                                                         "note" : note,
                                                                                                         "hidden": false])
        }
        dismiss(animated: true, completion: {self.delegate?.fetchCategories() })
    }
    
    @objc private func handleButtonPressed(sender:UIButton) {
        print("Plus button pressed")
        // add animation to the button
        Utilities.animateView(sender)
        sets.append("Set added")
        
        tableView.reloadData()
        let weightMetric = userDefaults.object(forKey: "weightMetric") 
        let setCell: [WeightRepsCell] = self.tableView.visibleCells as? [WeightRepsCell] ?? []
        for cell in setCell {
            if weightMetric as! Int == 0 {
                cell.weightTextField.attributedPlaceholder = NSAttributedString(string: "LBS",
                                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            } else {
                cell.weightTextField.attributedPlaceholder = NSAttributedString(string: "KG",
                                                                                attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
            }
            
        }
        
    }
    
    
    
    func fetchCategories() {
        print("fetchCategories() NewExerciseController")
        categoryStrings = []
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).collection("Category").getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching categories: \(err)")
            } else {
                guard let snap = snapshot else { return }
                for document in snap.documents {
                    let data = document.data()
                    
                    let name = data["name"] as? String ?? "No category found"

                    self.categories.append(name)
                    self.categoryStrings.append(name)
                }
            }
            
        }
    }

    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Title",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        textField.backgroundColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        textField.addLine(position: .bottom, color: UIColor.lightBlue, width: 0.5)
        return textField
    }()

    
    // create text field for category entry
    let categorySelectorTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Select category",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        textField.addLine(position: .bottom, color: UIColor.lightBlue, width: 0.5)
        textField.tintColor = UIColor.clear
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    // create category picker view
    let categoryPicker: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
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
        textField.tintColor = UIColor.clear
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

    
    
    func setupUI() {
        
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 242))
        header.backgroundColor = .white

        let headerTextField = UITextField(frame: header.bounds)
        let workoutSC = UISegmentedControl(frame: header.bounds)
        let workoutTF = UITextField(frame: header.bounds)
        let button = UIButton(frame: header.bounds)
        //headerView.backgroundColor = .lightBlue
        header.addSubview(headerTextField)
        header.addSubview(workoutSC)
        header.addSubview(workoutTF)
        header.addSubview(button)
        
        
        
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
        
        
        tableView.tableHeaderView = header
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

