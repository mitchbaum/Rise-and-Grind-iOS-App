//
//  WorkoutController+UITableView.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/6/22.
//
import Foundation
import UIKit

extension WorkoutController {

    
    // when user taps on row bring them into another view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // whenever user taps on a file cell, push over the information to the employee view controller
        print("Selected a cell")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // create footer that displays when there are no files in the table
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        if sets.count == 0 {
            label.text = "\n\n\n\n No sets added. \n\n Tap the plus button to add a set!"
        }
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.contentMode = .scaleToFill
 
        return label
    }
    
    // create footer that is hidden when no rows are present
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return sets.count == 0 ? 150 : 0
    }
    
    // create some cells for the rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: WeightRepsCell.identifier, for: indexPath) as! WeightRepsCell
//        let weight = sets[indexPath.row]
//        cell.weightLabel.text = weight
        return cell
    }
    
    // height of each cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    // add some rows to the tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return sets.count
    }
    
    // delete exercise set
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            let set = self.sets[indexPath.row]
            // remove the file from the tableView
            print("set being deleted is: ", set)
            self.sets.remove(at: indexPath.row)
            self.tableView.deleteRows(at: [indexPath], with: .automatic)
            print("sets after delete = ", self.sets)

            }
        // change color of delete button
        deleteAction.backgroundColor = UIColor.red
        
        // this puts the action buttons in the row the user swipes so user can actually see the buttons to delete or edit
        return [deleteAction]
    }
    
}

