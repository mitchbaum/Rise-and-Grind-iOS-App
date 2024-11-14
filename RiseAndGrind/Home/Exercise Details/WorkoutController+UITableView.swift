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
        let set = sets[indexPath.row]
        cell.weightTextField.text = nil
        cell.repsTextField.text = nil
        cell.selectionStyle = .none
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
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        // Delete action
        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            let set = self.sets[indexPath.row]
            
            // Remove the set from the data source
            self.sets.remove(at: indexPath.row)
            tableView.deleteRows(at: [indexPath], with: .automatic)
            
            // Call completion handler to indicate action was performed
            completionHandler(true)
        }
        deleteAction.backgroundColor = .red

        // Return the configuration
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        sets.swapAt(sourceIndexPath.row, destinationIndexPath.row)
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

