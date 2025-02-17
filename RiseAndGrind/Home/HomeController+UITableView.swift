//
//  HomeController+UITableView.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 10/3/21.
//

import UIKit
import Foundation
import CloudKit
import FirebaseAuth

extension HomeController {
    
    // when user taps on row bring them into another view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // whenever user taps on a file cell, push over the information to the employee view controller
    
        let exercise = self.exercises[indexPath.row]
        
        let workoutController = WorkoutController()
        workoutController.delegate = self

        workoutController.nameTextField.text = exercise.name
        workoutController.categorySelectorTextField.text = exercise.category
        workoutController.lastUpdatedTimestamp = exercise.timeStamp ?? ""

        
        let navController = CustomNavigationController(rootViewController: workoutController)
        
        // push into new viewcontroller
        present(navController, animated: true, completion: nil)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // create footer that displays when there are no files in the table
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        if isSignedIn == true {
            if exercises.count == 0 {
                label.text = "\n\n\n\n\n No workouts added. \n\n Tap the + icon to add your first workout!"
                label.textColor = .white
            }
        } else {
            label.text = "Tap the 💪 to sign in!"
            label.textColor = .lightBlue
            label.font = UIFont.boldSystemFont(ofSize: 22)
        }
        label.textAlignment = .center
        label.numberOfLines = 0
        label.contentMode = .scaleToFill
 
        return label
    }
    
    // create footer that is hidden when no rows are present
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return exercises.count == 0 ? 150 : 0
    }
    
    func calculateWeightValue(weight: String) -> String {
        let weightMetric = userDefaults.object(forKey: "weightMetric")
        if weightMetric as? Int == 0 {
            if weight.trimmingCharacters(in: .whitespaces).suffix(2) == ".5" {
                return "\((Double(weight) ?? 0.0) * 1.0)"
            } else {
                return "\((Int((Double(weight) ?? 0.0) * 1.0)))"
            }
        } else {
            return "\((Int((Double(weight) ?? 0.0) * 0.453592)))"

        }
    }
    
    // create some cells for the rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseCell.identifier, for: indexPath) as! ExerciseCell
        let themeColor = Utilities.loadTheme()
        let textColor = Utilities.loadAppearanceTheme(property: "text")
        // this if statement seemed to fix the refresh srash bug. No idea why or how.
        if exercises.count == 0{
            //fetchExercises()
            return cell
        }
        guard let name = exercises[indexPath.row].name else { return cell }
        //let timeStamp = exercises[indexPath.row].timeStamp
        cell.name.text = name
        //"125 x 12  |  130 x 10  |  135 x 8"
        let weight = exercises[indexPath.row].weight
        let reps = exercises[indexPath.row].reps
        let note = exercises[indexPath.row].note
        let weightMetric = userDefaults.object(forKey: "weightMetric")
        var weightArray = [String]()
        var repsArray = [String]()
//        print("weight:", weight, "reps:", reps)
//        var sets: [Set] = []
//        if weight.count == reps.count {
//            sets = zip(weight, reps).map { Set(weight: $0.0 as? String , reps: $0.1 as? String) }
//            print("combined into sets:", sets)
//        }
        for i in weight {
            weightArray.append(i as! String)
        }
        for i in reps {
            repsArray.append(i as! String)
        }
        
        var weightArrayLen = weightArray.count
        var repsArrayLen = weightArray.count
        var weightRepString = ""
        if weightArrayLen != 0 && repsArrayLen != 0 {
            for i in 0...(weightArrayLen - 1) {
                if weightMetric as? Int == 0 {
                    // checks if weight is double or int
                    if weightArray[i].trimmingCharacters(in: .whitespaces).suffix(2) == ".5" {
                        weightRepString += "\((Double(weightArray[i]) ?? 0.0) * 1.0) x \(repsArray[i]) | "
                    } else {
                        weightRepString += "\((Int((Double(weightArray[i]) ?? 0.0) * 1.0))) x \(repsArray[i]) | "
                    }
                } else {
                    weightRepString += "\((Int((Double(weightArray[i]) ?? 0.0) * 0.453592))) x \(repsArray[i]) | "

                }
            }
            
        }
        let choppedString = String(weightRepString.dropLast(2))
        cell.weightXreps.text = choppedString
        let timestamp = NSDate().timeIntervalSince1970
        let timeSinceUpdate = Utilities.timestampConversion(timeStamp: exercises[indexPath.row].timeStamp ?? "\(timestamp)").timeAgoDisplay()
        cell.updateLabel.text = timeSinceUpdate
        let components = timeSinceUpdate.components(separatedBy: " ")
        let needsUpdating = ["weeks", "month", "months", "year", "years"]
        if needsUpdating.contains(components[2]) {
            cell.alertView.backgroundColor = .red
            cell.updateImageView.tintColor = .red
            cell.weightXreps.textColor = .red
        } else {
            cell.alertView.backgroundColor = themeColor
            cell.updateImageView.tintColor = themeColor
            cell.weightXreps.textColor = themeColor
            
        }
        
        if exercises[indexPath.row].hidden ?? false {
            cell.eyeImageView.isHidden = false
        } else {
            cell.eyeImageView.isHidden = true
        }
        
        if weightMetric as! Int == 0 {
            cell.formatLabel.text = "(LBS x reps)"
        } else {
            cell.formatLabel.text = "(KG x reps)"
        }
        cell.notes.text = note
        cell.selectionStyle = .none
        
        // appearance light/dark mode
        cell.name.textColor = textColor
        cell.notes.textColor = textColor
        cell.cardView.backgroundColor = Utilities.loadAppearanceTheme(property: "primaryCell")
        cell.weightRepsView.backgroundColor = Utilities.loadAppearanceTheme(property: "primaryTopCell")
        cell.backgroundColor = Utilities.loadAppearanceTheme(property: "secondary")
        return cell
    }
        
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // add some rows to the tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        // returns number of rows as number of files
        return exercises.count
    }
    
    // delete exercise from tableView and Cloud databae
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        guard let uid = Auth.auth().currentUser?.uid else { return [] }
        let themeColor = Utilities.loadTheme()
        let exercise = self.exercises[indexPath.row]
        let category = exercise.category
        let name = exercise.name
        let showHidden = userDefaults.object(forKey: "showHidden") as? Bool ?? true

        if exercise.hidden ?? true {
            let action = UITableViewRowAction(style: .normal, title: "Show") { (_, indexPath) in
                let hideAction = UIAlertAction(title: "Show Exercise", style: .default) { (action) in
                    self.exercises[indexPath.row].hidden = false
                    self.db.collection("Users").document(uid).collection("Category").document(category!).collection("Exercises").document(name!).updateData(["hidden" : false])
                    self.tableView.reloadData()
                }
                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                optionMenu.addAction(hideAction)
                optionMenu.addAction(cancelAction)
                self.present(optionMenu, animated: true, completion: nil)

                
            }
            // change color of delete button
            action.backgroundColor = themeColor

            
            // this puts the action buttons in the row the user swipes so user can actually see the buttons to delete or edit
            return [action]
        } else {
            let action = UITableViewRowAction(style: .destructive, title: "Hide") { (_, indexPath) in

                
                let hideAction = UIAlertAction(title: "Hide Exercise", style: .destructive) { (action) in
                    self.exercises[indexPath.row].hidden = true
                    self.db.collection("Users").document(uid).collection("Category").document(category!).collection("Exercises").document(name!).updateData(["hidden" : true])
                    if !showHidden {
                        self.exercises.remove(at: indexPath.row)
                        self.tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                    self.tableView.reloadData()
                }
                let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
                let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
                optionMenu.addAction(hideAction)
                optionMenu.addAction(cancelAction)
                self.present(optionMenu, animated: true, completion: nil)

                
            }
            action.backgroundColor = themeColor
            return [action]
        }
        
    }

    override func tableView(_ tableView: UITableView, leadingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        guard let uid = Auth.auth().currentUser?.uid else { return nil }
        let exercise = self.exercises[indexPath.row]
        let category = exercise.category
        let name = exercise.name

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            // Remove the exercise from the array
            self.exercises.remove(at: indexPath.row)
            let deleteActionAlert = UIAlertAction(title: "Delete Forever", style: .destructive) { (action) in

                self.db.collection("Users").document(uid).collection("Category").document(category!).collection("Exercises").document(name!).delete { error in
                    if let error = error {
                        print("Error removing document: \(error)")
                    } else {
                        // Delete the row from the table view
                        tableView.deleteRows(at: [indexPath], with: .fade)
                        completionHandler(true)
                    }
                }
            }

            // alert
           let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
           let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
           optionMenu.addAction(deleteActionAlert)
           optionMenu.addAction(cancelAction)
           self.present(optionMenu, animated: true, completion: nil)
        }

        deleteAction.backgroundColor = .red // You can customize the color if needed

        return UISwipeActionsConfiguration(actions: [deleteAction])
    }
    
    
}
