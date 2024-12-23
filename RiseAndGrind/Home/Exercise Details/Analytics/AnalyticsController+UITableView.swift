//
//  AnalyticsController+UITableView.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 11/18/24.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase

extension AnalyticsController {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // create footer that displays when there are no files in the table
    func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        if analyticsContents.count == 0 {
            label.text = "Data points empty."
        }
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.contentMode = .scaleToFill
 
        return label
    }
    
    // create footer that is hidden when no rows are present
    func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return analyticsContents.count == 0 ? 150 : 0
    }
    
    func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // add some rows to the tableView
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return analyticsContents.count
    }
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        
        let label = IndentedLabel()
        label.text = "Data Points"
        label.backgroundColor = Utilities.loadTheme()
        label.textColor = .white
        label.font =  UIFont.systemFont(ofSize: 18)
        
        return label
    }
    
    // create some cells for the rows
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: AnalyticsCell.identifier, for: indexPath) as! AnalyticsCell
        let weight = analyticsContents[indexPath.row].weight
        let reps = analyticsContents[indexPath.row].reps
        let weightMetric = userDefaults.object(forKey: "weightMetric")
        var weightArray = [String]()
        var repsArray = [String]()
        for i in weight {
            weightArray.append(i as! String)
        }
        for i in reps {
            repsArray.append(i as! String)
        }
        
        var weightRepString = ""
        if !weightArray.isEmpty && !repsArray.isEmpty {
            let lastWeight = weightArray[weightArray.count - 1]
            let lastReps = repsArray[repsArray.count - 1]
            if let weightMetricInt = weightMetric as? Int {
                if weightMetricInt == 0 {
                    weightRepString = "\(Int((Double(lastWeight) ?? 0.0) * 1.0)) x \(lastReps) | "
                } else {
                    weightRepString = "\(Int((Double(lastWeight) ?? 0.0) * 0.453592)) x \(lastReps) | "
                }
            }

            
        }
        let choppedString = String(weightRepString.dropLast(2))
        cell.weightXreps.text = choppedString
        
        let formattedTimestamp = Utilities.timestampToFormattedDate(timeStamp: analyticsContents[indexPath.row].timeStamp!, monthAbbrev: "MMMM")
        cell.updateLabel.text = "Logged: \(formattedTimestamp)"

        
        
        if weightMetric as! Int == 0 {
            cell.formatLabel.text = "(LBS x reps)"
        } else {
            cell.formatLabel.text = "(KG x reps)"
        }
        
        cell.archiveLabel.text = analyticsContents[indexPath.row].archive ? "Archive" : ""

        return cell
    }
    
    func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let themeColor = Utilities.loadTheme()
        let isArchive = self.analyticsContents[indexPath.row].archive
        let deleteAction = UIContextualAction(style: isArchive ? .normal : .destructive, title: isArchive ? "Hide" : "Delete") {  (_, _, completionHandler) in
            let set = self.analyticsContents[indexPath.row]
            let name = self.exerciseName
            let category = self.exerciseCategory
            let id = set.id
            guard let uid = Auth.auth().currentUser?.uid else { return }
            let deleteAction = UIAlertAction(title: isArchive ? "Hide From Chart" : "Delete Forever", style: .destructive) { action in
                self.analyticsContents.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                if !isArchive {
                    self.db.collection("Users").document(uid).collection("Category").document(category).collection("Exercises").document(name).collection("Analytics").document(id!).delete()
                }
               
                self.populateChart()
            }
            
            // alert
            let optionMenu = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
            let cancelAction = UIAlertAction(title: "Cancel", style: .cancel)
            optionMenu.addAction(deleteAction)
            optionMenu.addAction(cancelAction)
            self.present(optionMenu, animated: true, completion: nil)
            completionHandler(true)

        }
        // change color of delete button
        deleteAction.backgroundColor = isArchive ? themeColor : UIColor.red
        
        // this puts the action buttons in the row the user swipes so user can actually see the buttons to delete or edit
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
}

