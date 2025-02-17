//
//  ArchiveController+UITableView.swift
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

extension ArchiveController {
    
    // when user taps on row bring them into another view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // whenever user taps on a file cell, push over the information to the employee view controller
        print("Selected a cell")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // create footer that displays when there are no files in the table
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        if contents.count == 0 {
            label.text = "Archive empty."
        }
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.contentMode = .scaleToFill
 
        return label
    }
    
    // create footer that is hidden when no rows are present
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return contents.count == 0 ? 150 : 0
    }
    
    // create some cells for the rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: ArchiveCell.identifier, for: indexPath) as! ArchiveCell
        let textColor = Utilities.loadAppearanceTheme(property: "text")
//        let weight = sets[indexPath.row]
//        cell.weightLabel.text = weight
        let weight = contents[indexPath.row].weight
        let reps = contents[indexPath.row].reps
        let note = contents[indexPath.row].note
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
                    weightRepString += "\((Int((Double(weightArray[i]) ?? 0.0) * 0.453592))) x \(repsArray[i]) | "
                }
            }

            
        }
        let choppedString = String(weightRepString.dropLast(2))
        cell.weightXreps.text = choppedString
        cell.updateLabel.text = "Archived on: \(contents[indexPath.row].timeStamp ?? "N/A")"
        
        if weightMetric as! Int == 0 {
            cell.formatLabel.text = "(LBS x reps)"
        } else {
            cell.formatLabel.text = "(KG x reps)"
        }
        cell.notes.text = note
        
        // appearance light/dark mode
        cell.weightXreps.textColor = textColor
        cell.notes.textColor = textColor
        cell.cardView.backgroundColor = Utilities.loadAppearanceTheme(property: "primaryCell")
        cell.backgroundColor = Utilities.loadAppearanceTheme(property: "secondary")

        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // add some rows to the tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return contents.count
    }
    
    // delete exercise archive
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            let set = self.contents[indexPath.row]
            let name = self.nameTextField.text
            let category = self.categoryTextField.text
            let id = set.id
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let deleteAction = UIAlertAction(title: "Delete Forever", style: .destructive) { action in
                self.contents.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                print("sets after delete = ", self.contents)
                self.db.collection("Users").document(uid).collection("Category").document(category!).collection("Exercises").document(name!).collection("Archive").document(id!).delete()
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

