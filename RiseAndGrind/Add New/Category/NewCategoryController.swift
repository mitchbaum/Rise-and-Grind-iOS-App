//
//  NewCategoryController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 10/4/21.
//

import UIKit
import Firebase
import FirebaseStorage
import FirebaseDatabase
import FirebaseAuth


protocol newCategoryControllerDelegate {
    func fetchCategories()
}

class NewCategoryController: UITableViewController {
    
    var delegate: newCategoryControllerDelegate?
    
    //create variable to reference the firebase data so we can read, wirte and update it
    let db = Firestore.firestore()
    
    var categories = [Category]()

    var categoryCollectionReference: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    
        navigationItem.title = "New Category"
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = .darkGray
        tableView.separatorColor = .darkGray
        tableView.tableFooterView = UIView()
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        
        // add cancel button to dismiss view
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleAdd))
        
        categoryCollectionReference = Firestore.firestore().collection("Category")
        
        fetchCategories()
        setupUI()

    }
    
    @objc private func handleAdd() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        if nameTextField.text != "" {
            print("adding new category")
            let name = nameTextField.text!
            if name.contains("/") {
                return showError(title: "Unable to Save", message: "/ is a reserved character. Try using \\ instead.")
            }
            let catUid = db.collection("Category").document().documentID


            db.collection("Users").document(uid).collection("Category").document(name).setData(["name" : name,
                                                          "id" : catUid])
            { (error) in
                if error != nil {
                    print(error ?? "")
                    return
                }
            }
        }
        
        dismiss(animated: true) {
                        self.delegate?.fetchCategories()
                    }
    }
    
    func fetchCategories() {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).collection("Category").getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching categories: \(err)")
            } else {
                guard let snap = snapshot else { return }
                for document in snap.documents {
                    let data = document.data()
                    
                    let name = data["name"] as? String ?? "No category found"
                    let id = data["id"] as? String ?? "No id found"
                    
                    let newCategory = Category(name: name, id: id)
                    self.categories.append(newCategory)
                    
                }
                self.tableView.reloadData()
            }
            
        }
    }
    
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = .black
        // enable autolayout
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Tap to edit",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        textField.backgroundColor = UIColor.white
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        textField.addLine(position: .bottom, color: UIColor.lightBlue, width: 0.5)
        return textField
    }()
    
    
    private func setupUI() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 82))
        header.backgroundColor = .white
        let headerLabel = UILabel(frame: header.bounds)
        header.addSubview(headerLabel)
        
        // add and position name label
        header.addSubview(nameLabel)
        nameLabel.topAnchor.constraint(equalTo: headerLabel.topAnchor, constant: 16).isActive = true
        nameLabel.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 16).isActive = true
        nameLabel.widthAnchor.constraint(equalToConstant: 120).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 50).isActive = true
        
        header.addSubview(nameTextField)
        nameTextField.topAnchor.constraint(equalTo: header.topAnchor, constant: 16).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: nameLabel.rightAnchor).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    
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
