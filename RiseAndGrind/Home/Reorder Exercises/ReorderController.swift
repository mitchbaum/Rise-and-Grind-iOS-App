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
    func fetchCategories()
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
        fetchExercises()
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
        dismiss(animated: true, completion: {self.delegate?.fetchCategories() })
    }
    
    func reorder() {
        if tableView.isEditing {
            tableView.isEditing = false
        } else {
            tableView.isEditing = true
        }
    }
    
    // fetches the exercises from Firebase database
    func fetchExercises() {
        if category == nil {
            return
        }
        print("fetching exercises")
        exercises = []
//        print(activeSegment)
//        print(catsNameOnly[activeSegment])
        guard let uid = Auth.auth().currentUser?.uid else { return }
        self.exerciseCollectionRef = db.collection("Users").document(uid).collection("Category").document(category as! String).collection("Exercises")
            self.exerciseCollectionRef.getDocuments { (snapshot, error) in
                if let err = error {
                    debugPrint("Error fetching exercises: \(err)")
                } else {
                    guard let snap = snapshot else { return }
                    for document in snap.documents {
                        let data = document.data()
                        let name = data["name"] as? String ?? ""
                        let category = data["category"] as? String ?? ""
                        let timeStamp = data["timestamp"] as? String ?? ""
                        let location = data["location"] as? Int ?? 0
                        let weight = data["weight"] as? Array ?? []
                        let reps = data["reps"] as? Array ?? []
                        let note = data["note"] as? String ?? ""

                        let newExercise = Exercise(name: name, category: category, timeStamp: timeStamp, location: location, weight: weight, reps: reps, note: note)
                        self.exercises.append(newExercise)


                    }
                    self.sortExercises()
                }
            }
        

    }
    
    func sortExercises() {
        let sortMetric = self.userDefaults.object(forKey: "sortMetric")
        if sortMetric as! String == "Name" {
            // ascending
            exercises.sort(by: {$0.name ?? "" < $1.name ?? ""})
        } else if sortMetric as! String == "Custom" {
            exercises.sort(by: {$0.location ?? 0 < $1.location ?? 0})
        } else {
            // last modified
            exercises.sort(by: {$0.timeStamp ?? "" > $1.timeStamp ?? ""})
        }
        tableView.reloadData()
    }
    
    @objc func handleCancel() {
        dismiss(animated: true, completion: nil)
    }
    

    
    
}

