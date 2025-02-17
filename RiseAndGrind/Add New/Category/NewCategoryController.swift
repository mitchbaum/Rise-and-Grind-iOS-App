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
    func fetchCategories() async throws
}

class NewCategoryController: UITableViewController {
    
    var delegate: newCategoryControllerDelegate?
    
    //create variable to reference the firebase data so we can read, wirte and update it
    let db = Firestore.firestore()
    
    var categories = [Cat]()

    var categoryCollectionReference: CollectionReference!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        if #available(iOS 15.0, *) {
            tableView.sectionHeaderTopPadding = 0
        }
    
        navigationItem.title = "New Category"
        navigationItem.largeTitleDisplayMode = .never
        tableView.backgroundColor = Utilities.loadAppearanceTheme(property: "secondary")
        tableView.separatorColor =  Utilities.loadAppearanceTheme(property: "secondary")
        tableView.tableFooterView = UIView()
        tableView.register(CategoryCell.self, forCellReuseIdentifier: CategoryCell.identifier)
        
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
                    Task {
                            do {
                                try await self.delegate?.fetchCategories()
                            } catch {
                                print("Failed to fetch categories: \(error)")
                            }
                        }
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
                    
                    let newCategory = Cat(name: name, id: id)
                    self.categories.append(newCategory)
                    
                }
                self.tableView.reloadData()
            }
            
        }
    }
    
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Title",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = Utilities.loadAppearanceTheme(property: "text")
        textField.tintColor = Utilities.loadTheme()
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.setLeftPaddingPoints(5)
        textField.setRightPaddingPoints(5)
        textField.addLine(position: .bottom, color: Utilities.loadTheme(), width: 0.5)
        return textField
    }()
    
    
    private func setupUI() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 92))
        header.backgroundColor = Utilities.loadAppearanceTheme(property: "primary")
        let headerTextField = UILabel(frame: header.bounds)
        header.addSubview(headerTextField)
        
        
        header.addSubview(nameTextField)
        nameTextField.topAnchor.constraint(equalTo: headerTextField.topAnchor, constant: 16).isActive = true
        nameTextField.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 16).isActive = true
        nameTextField.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        nameTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
    
    
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
