//
//  RecentsController+UITableView.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/6/25.
//

import UIKit
import Foundation
import CloudKit
import FirebaseAuth

extension RecentsController {
    
    override func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        // whenever user taps on a file cell, push over the information to the employee view controller
    
        let recent = self.recents[indexPath.row]
        
        let recentSelectedController = RecentSelectedController()
        let navController = CustomNavigationController(rootViewController: recentSelectedController)
        recentSelectedController.items = recent.categories
        recentSelectedController.navigationItem.title = recent.date
        recentSelectedController.delegate = self
        // Configure sheet presentation
        if let sheet = navController.sheetPresentationController {
            sheet.detents = [.medium(), .large()] // Set to medium (half height) and large (full screen)
            sheet.prefersGrabberVisible = true   // Show grabber at the top of the modal
            sheet.preferredCornerRadius = 16     // Optional: add corner radius
        }
        
        self.present(navController, animated: true, completion: nil)

        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    
    override func tableView(_ tableView: UITableView, viewForFooterInSection section: Int) -> UIView? {
        let label = UILabel()
        if recents.count == 0 {
            label.text = "\n\n\n\n\n No recents added. \n\n Tap 'Done' then tap the icon in the top left."
            label.textColor = .white
        }
        
        label.textAlignment = .center
        label.numberOfLines = 0
        label.contentMode = .scaleToFill
 
        return label
    }
    
    // create footer that is hidden when no rows are present
    override func tableView(_ tableView: UITableView, heightForFooterInSection section: Int) -> CGFloat {
        return recents.count == 0 ? 150 : 0
    }
    
    // create some cells for the rows
    override func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: RecentCell.identifier, for: indexPath) as! RecentCell
        let themeColor = Utilities.loadTheme()
        let textColor = Utilities.loadAppearanceTheme(property: "text")
        let date = recents[indexPath.row].date
        let categories = recents[indexPath.row].categories
        
        // Clear any existing labels from the stack view
        cell.categoriesStackView.arrangedSubviews.forEach { $0.removeFromSuperview() }
        
        // Add a label for each exercise
        categories.forEach { exercise in
            let label = UILabel()
            let view = UIView()
            // Configure the container view
            view.layer.masksToBounds = true
            view.layer.cornerRadius = 5
            view.backgroundColor = Utilities.loadAppearanceTheme(property: "primaryTopCell")
            view.translatesAutoresizingMaskIntoConstraints = false

            // Configure the label
            label.text = exercise.category
            label.font = UIFont.systemFont(ofSize: 16)
            label.textColor = themeColor
            label.translatesAutoresizingMaskIntoConstraints = false

            // Add the label to the container view
            view.addSubview(label)

            // Add constraints to center the label inside the container view
            NSLayoutConstraint.activate([
                label.topAnchor.constraint(equalTo: view.topAnchor, constant: 5),
                label.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -5),
                label.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 10),
                label.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -10)
            ])

            // Add the container view to the stack view
            cell.categoriesStackView.addArrangedSubview(view)
        }
        
        cell.dateLabel.text = date
        cell.selectionStyle = .none
        
        // appearance light/dark mode
        cell.dateLabel.textColor = textColor
        cell.cardView.backgroundColor = Utilities.loadAppearanceTheme(property: "primaryCell")
        cell.backgroundColor = Utilities.loadAppearanceTheme(property: "secondary")

        return cell
    }
    
    override func tableView(_ tableView: UITableView, estimatedHeightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    // add some rows to the tableView
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return recents.count
    }
    
    
}

