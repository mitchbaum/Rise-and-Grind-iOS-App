//
//  NewCategoryController+UITableView.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 11/22/21.
//

import Foundation
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase

extension NewCategoryController {

    
    // when user taps on row bring them into another view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // whenever user taps on a file cell, push over the information to the employee view controller
        print("Selected a cell")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // create footer that displays when there are no files in the table
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        if categories.count == 0 {
            label.text = "No Categories added."
        }
        label.textColor = .white
        label.textAlignment = .center
        label.numberOfLines = 0
        label.contentMode = .scaleToFill
 
        return label
    }
    
    // create footer that is hidden when no rows are present
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return categories.count == 0 ? 150 : 0
    }
    
    // create some cells for the rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: CategoryCell.identifier, for: indexPath) as! CategoryCell
//        let weight = sets[indexPath.row]
//        cell.weightLabel.text = weight
        let category = categories[indexPath.row]
        cell.nameLabel.text = category.name
        cell.selectionStyle = .none
        return cell
    }
    
    // height of each cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    // add some rows to the tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return categories.count
    }
    
    // delete exercise set
    override func tableView(_ tableView: UITableView, editActionsForRowAt indexPath: IndexPath) -> [UITableViewRowAction]? {
        let deleteAction = UITableViewRowAction(style: .destructive, title: "Delete") { (_, indexPath) in
            let category = self.categories[indexPath.row]
            guard let uid = Auth.auth().currentUser?.uid else { return }
            // remove the file from the tableView
            print("category being deleted is: ", category.name!)
            let deleteAction = UIAlertAction(title: "Delete Category Forever", style: .destructive) { action in
                self.categories.remove(at: indexPath.row)
                self.tableView.deleteRows(at: [indexPath], with: .automatic)
                print("categories after delete = ", self.categories)
                self.db.collection("Users").document(uid).collection("Category").document(category.name!).delete()
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
    
    // creates height of header
    override func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 36
    }

    
    // creates style of header
    override func tableView(_ tableView: UITableView, viewForHeaderInSection section: Int) -> UIView? {
        let label = IndentedLabel()
        // make headers refelct what goes information goes into the sections

        if section == 0 {
            label.text = "Current Categories:"
        }
        

        label.backgroundColor = Utilities.loadTheme()
        label.textColor = .white
        label.font =  UIFont.systemFont(ofSize: 18)



        return label
    }
    
}

