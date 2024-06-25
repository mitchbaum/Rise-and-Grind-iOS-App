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
    
//    // creates style of header
//    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
//        let categorySCArray = userDefaults.object(forKey: "myKey")
//        let sc = UISegmentedControl(items: categorySCArray as! [String])
//
//        sc.selectedSegmentIndex = activeSegment
//        sc.addTarget(self, action: #selector(segmentedControlValueChanged(_:)), for: .valueChanged)
//        sc.translatesAutoresizingMaskIntoConstraints = true
//        if sc.numberOfSegments == 0 {
//            sc.backgroundColor = .darkGray
//        } else {
//            sc.backgroundColor = .white
//            let activeSegmentTitle = sc.titleForSegment(at: sc.selectedSegmentIndex)
//            UserDefaults.standard.setValue(activeSegmentTitle, forKey: "selectedCategory")
//        }
//        // highlighted filter color
//        sc.selectedSegmentTintColor = UIColor.lightBlue
//        // changes text color to black for selected button text
//        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
//        // changes text color to black for non selected button text
//        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
//        return sc
//    }
//    
//    
//    // creates height of header
//    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
//        return 35
//    }
//    
//    // creates header
//    override func numberOfSections(in tableView: UITableView) -> Int {
//        return 1
//    }
//    
    // when user taps on row bring them into another view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // whenever user taps on a file cell, push over the information to the employee view controller
        print("Selected a cell")
        //let file = self.files[indexPath.row]\
    
        let exercise = self.exercises[indexPath.row]
        
        let workoutController = WorkoutController()
        workoutController.delegate = self

        workoutController.nameTextField.text = exercise.name
        workoutController.categorySelectorTextField.text = exercise.category

        
        print(" workoutController.tableView.numberOfRows(inSection: 0) = \(workoutController.tableView.numberOfRows(inSection: 0))")
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
    
    // create some cells for the rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ExerciseCell.identifier, for: indexPath) as! ExerciseCell
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
            cell.weightRepsView.backgroundColor = .offWhite
            for i in 0...(weightArrayLen - 1) {
                if weightMetric as? Int == 0 {
                    // checks if weight is double or int
                    if weightArray[i].trimmingCharacters(in: .whitespaces).suffix(2) == ".5" {
                        weightRepString += "\((Double(weightArray[i]) ?? 0.0) * 1.0) x \(repsArray[i]) | "
                    } else {
                        weightRepString += "\((Int((Double(weightArray[i]) ?? 0.0) * 1.0))) x \(repsArray[i]) | "
                    }
                } else {
                    weightRepString += "\((Int((Double(weightArray[i]) ?? 0.0) * 0.45))) x \(repsArray[i]) | "

                }
                //weightRepString += "\(weightArray[i]) x \(repsArray[i]) | "
            }
            
        }
        let choppedString = String(weightRepString.dropLast(2))
        cell.weightXreps.text = choppedString
        let timestamp = NSDate().timeIntervalSince1970
        let timeSinceUpdate = Utilities.timestampConversion(timeStamp: exercises[indexPath.row].timeStamp ?? "\(timestamp)").timeAgoDisplay()
        cell.updateLabel.text = Utilities.timestampConversion(timeStamp: exercises[indexPath.row].timeStamp ?? "\(timestamp)").timeAgoDisplay()
        let components = timeSinceUpdate.components(separatedBy: " ")
        if components[2] == "weeks" {
            cell.alertView.backgroundColor = .red
            cell.updateImageView.tintColor = .red
            cell.weightXreps.textColor = .red
        } else {
            cell.alertView.backgroundColor = .lightBlue
            cell.updateImageView.tintColor = .lightBlue
            cell.weightXreps.textColor = .lightBlue
            
        }
        
        if weightMetric as! Int == 0 {
            cell.formatLabel.text = "(LBS x reps)"
        } else {
            cell.formatLabel.text = "(KG x reps)"
        }
        cell.notes.text = note
        cell.selectionStyle = .none

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
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            // get the exercise you are swiping on to get delete action
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let exercise = self.exercises[indexPath.row]
            let category = self.exercises[indexPath.row].category
            let name = self.exercises[indexPath.row].name
            
            let deleteAction = UIAlertAction(title: "Delete Forever", style: .destructive) { (action) in
                // remove the exercise from the tableView
                print("exercise being deleted is: ", exercise)
                self.exercises.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                self.db.collection("Users").document(uid).collection("Category").document(category!).collection("Exercises").document(name!).delete()
                self.tableView.reloadData()
            }
            // alert
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)

            
        }
        // change color of delete button
        deleteAction.backgroundColor = UIColor.red

        
        // this puts the action buttons in the row the user swipes so user can actually see the buttons to delete or edit
        return [deleteAction]
    }

    
    
}
