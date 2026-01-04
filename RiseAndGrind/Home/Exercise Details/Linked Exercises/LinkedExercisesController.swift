//
//  LinkedCategoriesController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/2/26.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
protocol LinkedExercisesControllerDelegate {
    func fetchLinkedCategories() async throws
}

class LinkedExercisesController: UITableViewController, UIPickerViewDelegate, UIPickerViewDataSource {
    
    var delegate: LinkedExercisesControllerDelegate?
    let db = Firestore.firestore()
    var exerciseLinkDetails: LinkedExercise?
    var availableCategoriesToLink: [String] = []
    var originCategory: String?
    var exerciseName: String?
    
    public var items: [LinkedInfo] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = Utilities.loadAppearanceTheme(property: "secondary")
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "LinkedExerciseCell")
        
        let done = UIBarButtonItem(title: NSString(string: "Done") as String, style: .plain, target: self, action: #selector(handleDone))
        
        navigationItem.rightBarButtonItems = [done]
        
        initialize()

    }
    
    func initialize() {
        Task {
           do {
               setupUI()
               linkCategorySelectorTextField.inputView = linkCategoryPicker
               linkCategoryPicker.delegate = self
               linkCategoryPicker.dataSource = self
               try await fetchAvailableCategoriesToLink()
           } catch {
               print("Failed to initialize linked exercises controller: \(error)")
           }
        }
    }
    
    func fetchAvailableCategoriesToLink() async throws {
        availableCategoriesToLink = []
        var allCategories: [String] = []
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let documentRef = db.collection("Users").document(uid).collection("Category")
        do {
            let snapshot = try await documentRef.getDocuments()
            for document in snapshot.documents {
                let data = document.data()
                let name = data["name"] as? String
              
                allCategories.append(name ?? "")
            }
            for cat in allCategories {
                if let details = exerciseLinkDetails {
                    let alreadyLinked = details.categories.contains(where: { $0.category == cat })
                    if alreadyLinked { continue }
                }
                if originCategory == cat { continue }
                availableCategoriesToLink.append(cat)
            }
            
        } catch {
            debugPrint("Error fetching available categories to link: \(error)")
            throw error
        }
    }
    
    @objc func handleAddToLinkCategories(sender:UIButton) {
        Utilities.animateView(sender)
        if linkCategorySelectorTextField.text == "" { return }
        if self.items.contains(where: {$0.category == linkCategorySelectorTextField.text!})  { return }
        self.items.append(LinkedInfo(category: linkCategorySelectorTextField.text!, location: 0, hidden: false))
        let categoriesForFirestore = self.items.map { info in
            [
                "category": info.category,
                "location": info.location,
                "hidden": info.hidden
            ]
        }
        Task {
            do {
                guard let uid = Auth.auth().currentUser?.uid else { return }
                let linkedExerciseRef = db.collection("Users").document(uid).collection("LinkedExercises").document()
                let newId = linkedExerciseRef.documentID
                try await self.db.collection("Users")
                    .document(uid)
                    .collection("LinkedExercises")
                    .document(self.exerciseLinkDetails?.id ?? newId)
                    .setData(["categories" : categoriesForFirestore,
                              "id": self.exerciseLinkDetails?.id ?? newId,
                              "originCategory": originCategory ?? "",
                              "exerciseName": exerciseName ?? ""])
                
                try await self.delegate?.fetchLinkedCategories()
                try await self.fetchAvailableCategoriesToLink()
                linkCategorySelectorTextField.text = ""
                tableView.reloadData()

            } catch {
                print("Error linking exercise to category: \(error)")
            }
        }
        
    }
    
    let linkCategoryPicker: UIPickerView = {
        let pickerView = UIPickerView()
        return pickerView
    }()
    
    var linkCategorySelectorTextField: UITextField = {
        let textField = UITextField()
        textField.attributedPlaceholder = NSAttributedString(string: "Select workout to link...",
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
    
    let linkButton: UIButton = {
        let button = UIButton()
        let appearanceTheme = UserDefaults.standard.object(forKey: "appearanceTheme") as? String
        let color = Utilities.loadTheme()
        button.backgroundColor = color
        button.setTitle("Link", for: .normal)
        button.setTitleColor(appearanceTheme == "Light" ? .white : Utilities.loadAppearanceTheme(property: "primary"), for: .normal)
        button.layer.cornerRadius = 10
        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 16.0)
        button.addTarget(self, action: #selector(handleAddToLinkCategories(sender:)), for: .touchUpInside)
        button.translatesAutoresizingMaskIntoConstraints = false
        return button
    }()

    private func setupUI() {
        let header = UIView(frame: CGRect(x: 0, y: 0, width: view.frame.size.width, height: 50))
        let headerView = UILabel(frame: header.bounds)
        //headerView.backgroundColor = .lightBlue
        header.addSubview(headerView)
        header.addSubview(linkCategorySelectorTextField)
        linkCategorySelectorTextField.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -82).isActive = true
        linkCategorySelectorTextField.topAnchor.constraint(equalTo: headerView.topAnchor).isActive = true
        linkCategorySelectorTextField.heightAnchor.constraint(equalToConstant: 50).isActive = true
        linkCategorySelectorTextField.leftAnchor.constraint(equalTo: headerView.leftAnchor, constant: 12).isActive = true
        
        
        header.addSubview(downIcon)
        downIcon.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -82).isActive = true
        downIcon.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        downIcon.heightAnchor.constraint(equalToConstant: 15).isActive = true
        downIcon.widthAnchor.constraint(equalToConstant: 15).isActive = true
        
        header.addSubview(linkButton)
        linkButton.centerYAnchor.constraint(equalTo: header.centerYAnchor).isActive = true
        linkButton.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -12).isActive = true
        linkButton.heightAnchor.constraint(equalToConstant: 30).isActive = true
        linkButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        
        tableView.tableHeaderView = header
    }
    
    @objc func handleDone() {
        dismiss(animated: true, completion: nil)
    }

}
