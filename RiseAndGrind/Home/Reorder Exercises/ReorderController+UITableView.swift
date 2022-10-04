//
//  ReorderController+UITableView.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/26/22.
//

import UIKit
import Foundation
import FirebaseAuth

extension ReorderController {
    
    
    // when user taps on row bring them into another view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // whenever user taps on a file cell, push over the information to the employee view controller
        print("Selected a cell")
        //let file = self.files[indexPath.row]\
    
        let exercise = self.exercises[indexPath.row]
        
        let workoutController = WorkoutController()

        workoutController.nameTextField.text = exercise.name
        workoutController.categorySelectorTextField.text = exercise.category

        let navController = CustomNavigationController(rootViewController: workoutController)
        
        // push into new viewcontroller
        present(navController, animated: true, completion: nil)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // create footer that displays when there are no files in the table
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        if exercises.count == 0 {
            label.text = "\n\n\n\n\n No workouts found."
            label.textColor = .white
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
            for i in 0...(weightArrayLen - 1) {
                if weightMetric as? Int == 0 {
                    weightRepString += "\((Int((Double(weightArray[i]) ?? 0.0) * 1.0))) x \(repsArray[i]) | "
                } else {
                    weightRepString += "\((Int((Double(weightArray[i]) ?? 0.0) * 0.45))) x \(repsArray[i]) | "
                }
                //weightRepString += "\(weightArray[i]) x \(repsArray[i]) | "
            }

            
        }
        let choppedString = String(weightRepString.dropLast(2))
        cell.weightXreps.text = choppedString
        let timestamp = NSDate().timeIntervalSince1970
        cell.updateLabel.text = Utilities.timestampConversion(timeStamp: exercises[indexPath.row].timeStamp ?? "\(timestamp)").timeAgoDisplay()
        
        if weightMetric as! Int == 0 {
            cell.formatLabel.text = "(LBS x reps)"
        } else {
            cell.formatLabel.text = "(KG x reps)"
        }
        cell.notes.text = note

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
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        exercises.swapAt(sourceIndexPath.row, destinationIndexPath.row)
    }
    
    // removes editing icon to left of cell when reordering
    override func tableView(_ tableView: UITableView, editingStyleForRowAt indexPath: IndexPath) -> UITableViewCell.EditingStyle {
        return .none
    }
    
    // removes indent to left of cell when reordering
    override func tableView(_ tableView: UITableView, shouldIndentWhileEditingRowAt indexPath: IndexPath) -> Bool {
        return false
    }
    
}
