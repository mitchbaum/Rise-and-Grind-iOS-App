//
//  OptionsController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 12/16/24.
//

import Foundation
import UIKit
import Firebase
import FirebaseAuth
protocol RecentSelectedControllerDelegate {
     func fetchRecents() async throws
}

class RecentSelectedController: UITableViewController {
    var delegate: RecentSelectedControllerDelegate?
    let db = Firestore.firestore()
    
    public var items: [RecentCategory] = []
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = UIColor.darkGray
        
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "RecentSelectedCell")
        
        let done = UIBarButtonItem(title: NSString(string: "Done") as String, style: .plain, target: self, action: #selector(handleDone))
        
        navigationItem.rightBarButtonItems = [done]

    }
    
    
    // when user taps on row bring them into another view
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // whenever user taps on a file cell, push over the information to the employee view controller
        print("Selected a cell")
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    // create some cells for the rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "RecentSelectedCell", for: indexPath)
        cell.textLabel?.text = items[indexPath.row].category
        cell.selectionStyle = .none
        cell.backgroundColor = .white
        cell.textLabel?.textColor = .black
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
    
    override func tableView(_ tableView: UITableView, trailingSwipeActionsConfigurationForRowAt indexPath: IndexPath) -> UISwipeActionsConfiguration? {
        let uid = (Auth.auth().currentUser?.uid)!

        let deleteAction = UIContextualAction(style: .destructive, title: "Delete") { (_, _, completionHandler) in
            
            Task {
                // Remove the set from the data source and update the database
                do {
                    try await self.db.collection("Users")
                        .document(uid)
                        .collection("History")
                        .document(self.items[indexPath.row].id!)
                        .delete()
                    
                    // Update the local data source
                    self.items.remove(at: indexPath.row)
                    tableView.deleteRows(at: [indexPath], with: .automatic)
                    
                    // Call the delegate's fetchRecents method
                    try await self.delegate?.fetchRecents()
                } catch {
                    print("Error deleting item: \(error)")
                }
            }
        }
        deleteAction.backgroundColor = .red

        // Return the configuration
        let configuration = UISwipeActionsConfiguration(actions: [deleteAction])
        return configuration
    }
    
    

    @objc func handleDone() {
        
        dismiss(animated: true, completion: nil)
    }
    

    
    


}
