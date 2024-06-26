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
    var reorderedExercises = [Exercise]()
    
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
        navigationItem.title = "Reorder Workout"
        navigationItem.largeTitleDisplayMode = .never
        
        // register fileCell wiht cellId
        //tableView.register(UITableViewCell.self, forCellReuseIdentifier: "cellId")
        tableView.register(ExerciseCell.self, forCellReuseIdentifier: ExerciseCell.identifier)
        
        tableView.backgroundColor = .darkGray
        tableView.separatorColor = .darkGray
        tableView.tableFooterView = UIView()
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(title: "Save", style: .plain, target: self, action: #selector(handleSave))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Cancel", style: .plain, target: self, action: #selector(handleCancel))
        reorder()
    }
    
    
    
    @objc private func handleSave() {
        print("saving new ordered workout")
        var locationCounter = 0
        guard let uid = Auth.auth().currentUser?.uid else { return }
        print("handleSave() exercises = ", exercises)
        for exercise in exercises {
            print("name = \(String(describing: exercise.name)) | location =  \(String(describing: exercise.location))")
            db.collection("Users").document(uid).collection("Category").document(category as! String).collection("Exercises").document(exercise.name ?? "").updateData(["location" : locationCounter])
            locationCounter += 1
            
        }
        dismiss(animated: true, completion: {self.delegate?.fetchExercises() })
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

