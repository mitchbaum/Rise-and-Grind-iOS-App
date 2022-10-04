//
//  ArchiveController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/7/22.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import JGProgressHUD
import FirebaseStorage

class ArchiveController: UITableViewController {
    let userDefaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    var contents = [Archive]()
    var categoryCollectionReference: CollectionReference!
    
    let nameTextField: UITextField = {
        let textField = UITextField()
        return textField
    }()
    
    
    let categoryTextField: UITextField = {
        let textField = UITextField()
        return textField
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        // creates title of files
        //navigationItem.title = "Archive"
        navigationItem.largeTitleDisplayMode = .never
        
        // register fileCell wiht cellId
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(ArchiveCell.self, forCellReuseIdentifier: ArchiveCell.identifier)
        
        tableView.backgroundColor = .darkGray
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        
        categoryCollectionReference = Firestore.firestore().collection("Category")
        fetchArchive()

    }
    
    // fetches the archive of exercises from Firebase database
    func fetchArchive() {
        contents = []
//        print(activeSegment)
//        print(catsNameOnly[activeSegment])
        let name = nameTextField.text
        let category = categoryTextField.text
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).collection("Category").document(category!).collection("Exercises").document(name!).collection("Archive")
            .getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching archive: \(err)")
            } else {
                guard let snap = snapshot else { return }
                for document in snap.documents {
                    let data = document.data()
                    let id = data["id"] as? String ?? ""
                    let timeStamp = data["timestamp"] as? String ?? ""
                    let weight = data["weight"] as? Array ?? []
                    let reps = data["reps"] as? Array ?? []
                    let note = data["note"] as? String ?? ""
                    
                    let newArchive = Archive(timeStamp: timeStamp, weight: weight, reps: reps, id: id, note: note)
                    self.contents.append(newArchive)
                }
            }
            //print(self.exercises)
            self.tableView.reloadData()
        }

    }
    
    @objc private func handleDone() {
        print("exiting archive")
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

