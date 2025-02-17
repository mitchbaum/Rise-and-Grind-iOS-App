//
//  RecentsController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/1/25.
//



import UIKit
import FirebaseAuth
import Firebase

protocol RecentsControllerDelegate {
     func populateLeftBarButtonItem()
}

class RecentsController: UITableViewController, RecentSelectedControllerDelegate {
    var delegate: RecentsControllerDelegate?
    let db = Firestore.firestore()
    
    var recents = [Recent]()
    
    public var category: String = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.title = "Recent Workouts"
        navigationItem.largeTitleDisplayMode = .never
        
        let done = UIBarButtonItem(title: "Done", style: .plain, target: self, action: #selector(handleDone))
        navigationItem.rightBarButtonItems = [done]
        
        tableView.register(RecentCell.self, forCellReuseIdentifier: RecentCell.identifier)
        tableView.backgroundColor = Utilities.loadAppearanceTheme(property: "secondary")
        tableView.separatorColor =  Utilities.loadAppearanceTheme(property: "secondary")

        Task {
           do {
               try await fetchRecents()
           } catch {
               print("Failed to fetch recents: \(error)")
           }
        }
    }
    
    func fetchRecents() async throws {
        recents = []
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let documentRef = db.collection("Users").document(uid).collection("History")
        do {
            let snapshot = try await documentRef.getDocuments()
            var groupedByDate: [String: [RecentCategory]] = [:]
            for document in snapshot.documents {
                let data = document.data()
                
                let id = data["id"] as? String
                let categoryName = data["category"] as? String
                let timestamp = data["timestamp"] as? String
                let date = data["date"] as? String ?? "Unknown Date"
                
                let category = RecentCategory(id: id, category: categoryName, timestamp: timestamp, date: date)
                groupedByDate[date, default: []].append(category)
            }
            recents = groupedByDate.map { date, categories in
                let sortedCategories = categories.sorted { $0.timestamp ?? "" < $1.timestamp ?? ""  }
                return Recent(date: date, categories: sortedCategories)
            }
            
            recents.sort { Utilities.convertDateToTimestamp(dateString: $0.date!) ?? "" > Utilities.convertDateToTimestamp(dateString: $1.date!) ?? ""}
            tableView.reloadData()
        } catch {
            debugPrint("Error fetching recent exercise: \(error)")
            throw error
        }
    }
    
    
    @objc func handleDone() {
        dismiss(animated: true, completion: {self.delegate?.populateLeftBarButtonItem() })
    }
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
    

}

