//
//  TableView.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/2/26.
//
import UIKit
import FirebaseAuth
extension LinkedExercisesController {
    // when user taps on row bring them into another view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // create some cells for the rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "LinkedExerciseCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].category
        cell.selectionStyle = .none
        cell.backgroundColor = Utilities.loadAppearanceTheme(property: "primaryCell")
        cell.textLabel?.textColor = Utilities.loadAppearanceTheme(property: "text")
        
        return cell
    }
    
    // height of each cell
    override func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return 55
    }
    
    // add some rows to the tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return items.count
    }
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()

        if items.count == 0 {
            label.text = "\n\n\n\n\n No categories linked."
            label.textColor = .white
        }

        label.textAlignment = .center
        label.numberOfLines = 0
        label.contentMode = .scaleToFill
 
        return label
    }
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let uid = (Auth.auth().currentUser?.uid)!

        let deleteAction = UIContextualAction(style: .destructive, title: "Unlink") { (_, _, completionHandler) in
            
            Task {
                self.items.remove(at: indexPath.row)
                // Remove the set from the data source and update the database
                do {
                    try await self.db.collection("Users")
                        .document(uid)
                        .collection("LinkedExercises")
                        .document(self.exerciseLinkDetails?.id ?? "")
                        .updateData(["categories" : self.items])
                    
                    await MainActor.run {
                        tableView.deleteRows(at: [indexPath], with: .automatic)
                    }
                    
                    try await self.delegate?.fetchLinkedCategories()
                    try await self.fetchAvailableCategoriesToLink()
                } catch {
                    print("Error unlinking exercise: \(error)")
                }
            }
        }
        deleteAction.backgroundColor = .red

        // Return the configuration
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
}
