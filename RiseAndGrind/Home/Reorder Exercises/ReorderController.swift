//
//  ReorderController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/24/22.
//

import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import JGProgressHUD
import FirebaseStorage

//custom delegation
protocol ReorderControllerDelegate {
    var exercises: [Exercise] { get set }
    func fetchExercises()
}


class ReorderController: UITableViewController {
    var delegate: ReorderControllerDelegate?
    let userDefaults = UserDefaults.standard
    var exerciseCollectionRef: CollectionReference!
    
    let db = Firestore.firestore()
    
    var exercises = [Exercise]()
    
    let category = UserDefaults.standard.object(forKey: "selectedCategory")
    
    // add loading HUD status for when fetching data from server
    let hud: JGProgressHUD = {
        let hud = JGProgressHUD(style: .light)
        hud.interactionType = .blockAllTouches
        return hud
    }()

    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        exercises = delegate?.exercises ?? []
        
        // creates title of files
        navigationItem.title = "Custom Workout Order"
        navigationItem.largeTitleDisplayMode = .never
        
        // register fileCell wiht cellId
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(ReorderCell.self, forCellReuseIdentifier: ReorderCell.identifier)
        
        tableView.backgroundColor = Utilities.loadAppearanceTheme(property: "secondary")
        tableView.separatorColor =  Utilities.loadAppearanceTheme(property: "secondary")
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        reorder()
    }
    
    
    
    @objc private func handleSave() {
        for (i, exercise) in exercises.enumerated() {
            print(i, exercise.name ?? "")
        }
        guard let uid = Auth.auth().currentUser?.uid else { return }
        // dispatch tracks the completion of asynchronous tasks. Needed to prevent dismissal of viewcontroller while reordering is in progress
        let dispatchGroup = DispatchGroup()
        for (i, exercise) in exercises.enumerated() {
            // Enter the dispatch group
            dispatchGroup.enter()
            print("name = \(String(describing: exercise.name)) | location =  \(String(describing: exercise.location))")
            db.collection("Users").document(uid).collection("Category").document(category as! String).collection("Exercises").document(exercise.name ?? "").updateData(["location" : i]) { error in
                if let error = error {
                    print("Error updating document's order: \(error)")
                } else {
                    // Delete the row from the table view
                    print("done reordering exercise.")
                    print("index =", i)
                }
                dispatchGroup.leave()
            }
            
        }

        dispatchGroup.notify(queue: .main) {
            print("dismissing")
            self.dismiss(animated: true, completion: {self.delegate?.fetchExercises() })
        }
    }
    
    func reorder() {
        if tableView.isEditing {
            tableView.isEditing = false
        } else {
            tableView.isEditing = true
        }
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    

    
    
}

