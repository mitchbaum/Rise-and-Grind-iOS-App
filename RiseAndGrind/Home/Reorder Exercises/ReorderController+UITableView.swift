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
        let cell = tableView.dequeueReusableCell(withIdentifier: ReorderCell.identifier, for: indexPath) as! ReorderCell
        guard let name = exercises[indexPath.row].name else { return cell }
        let themeColor = Utilities.loadTheme()
        let textColor = Utilities.loadAppearanceTheme(property: "text")
        cell.name.text = name
        let note = exercises[indexPath.row].note
    
        let timestamp = NSDate().timeIntervalSince1970
        let timeSinceUpdate = Utilities.timestampConversion(timeStamp: exercises[indexPath.row].timeStamp ?? "\(timestamp)").timeAgoDisplay()
        cell.updateLabel.text = timeSinceUpdate
        let components = timeSinceUpdate.components(separatedBy: " ")
        let needsUpdating = ["weeks", "month", "months", "year", "years"]
        if needsUpdating.contains(components[2]) {
            cell.alertView.backgroundColor = .red
            cell.updateImageView.tintColor = .red
        } else {
            cell.alertView.backgroundColor = themeColor
            cell.updateImageView.tintColor = themeColor
        }
        
        if exercises[indexPath.row].hidden ?? false {
            cell.eyeImageView.isHidden = false
            cell.name.leftAnchor.constraint(equalTo: cell.eyeImageView.rightAnchor, constant: 8).isActive = true
        } else {
            cell.eyeImageView.isHidden = true
            cell.name.leftAnchor.constraint(equalTo: cell.leftAnchor, constant: 26).isActive = true
        }
        cell.notes.text = note
        
        // appearance light/dark mode
        cell.name.textColor = textColor
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
        return exercises.count
    }
    
    override func tableView(_ tableView: UITableView, canMoveRowAt indexPath: IndexPath) -> Bool {
        return true
    }
    
    override func tableView(_ tableView: UITableView, moveRowAt sourceIndexPath: IndexPath, to destinationIndexPath: IndexPath) {
        tableView.beginUpdates()
        let movedObject = exercises[sourceIndexPath.row]
        exercises.remove(at: sourceIndexPath.row)
        exercises.insert(movedObject, at: destinationIndexPath.row)
        tableView.endUpdates()
        tableView.reloadData()

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
