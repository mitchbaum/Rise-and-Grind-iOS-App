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
        
        navigationItem.largeTitleDisplayMode = .never

        tableView.register(ArchiveCell.self, forCellReuseIdentifier: ArchiveCell.identifier)
        
        tableView.backgroundColor = .darkGray
        tableView.separatorColor = .darkGray
        tableView.tableFooterView = UIView()

        
        categoryCollectionReference = Firestore.firestore().collection("Category")
        fetchArchive()

    }
    
    // fetches the archive of exercises from Firebase database
    func fetchArchive() {
        contents = []
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
            self.sortContents()
        }

    }
    
    func sortContents() {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM d, yyyy"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        contents.sort { (item1, item2) -> Bool in
            guard let dateString1 = item1.timeStamp,
                  let date1 = dateFormatter.date(from: dateString1),
                  let dateString2 = item2.timeStamp,
                  let date2 = dateFormatter.date(from: dateString2) else {
                return false
            }
            return date1 > date2
        }
        self.tableView.reloadData()
    }
    
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
}

