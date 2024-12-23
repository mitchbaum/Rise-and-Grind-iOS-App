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
protocol OptionsControllerDelegate {
    func applyOptions()
}

class OptionsController: UIViewController {
    var delegate: OptionsControllerDelegate?
    let db = Firestore.firestore()
    
    public var exerciseName: String = ""
    public var exerciseCategory: String = ""
    public var dataType: String = ""
    public var includeArchive: Bool = false

    override func viewDidLoad() {
        super.viewDidLoad()
    
        navigationItem.title = "Chart Options"
        navigationItem.largeTitleDisplayMode = .never
        view.backgroundColor = UIColor.darkGray
        
        let save = UIBarButtonItem(title: NSString(string: "Done") as String, style: .plain, target: self, action: #selector(handleDone))
        
        navigationItem.rightBarButtonItems = [save]
        Task {
           do {
               try await fetchOptions()
               populateOptionsValue()
               setupUI()
           } catch {
               print("Failed to fetch categories: \(error)")
           }
        }

    }
    
    func fetchOptions() async throws {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let documentRef = db.collection("Users")
               .document(uid)
               .collection("Category")
               .document(exerciseCategory)
               .collection("Exercises")
               .document(exerciseName)
        do {
            let snapshot = try await documentRef.getDocument()
            if let data = snapshot.data() {
                let chartDataType = data["chartDataType"] as? String
                let chartIncludeArchive = data["chartIncludeArchive"] as? Bool
                self.dataType = chartDataType ?? "Weight"
                self.includeArchive = chartIncludeArchive ?? false
            }
        } catch {
            debugPrint("Error fetching exercise: \(error)")
            throw error
        }
    }
    
    func populateOptionsValue() {
        archivedDataSwitch.isOn = includeArchive
        if dataType == "Weight" {
            dataTypeControl.selectedSegmentIndex = 0
        } else {
            dataTypeControl.selectedSegmentIndex = 1
        }
        
    }
    
    @objc func handleDone() {
        
        dismiss(animated: true, completion: nil)
    }
    
    @objc func archivedDataChanged(mySwitch: UISwitch) {
        let value = mySwitch.isOn
        print("switch value changed \(value)")
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).collection("Category").document(exerciseCategory).collection("Exercises").document(exerciseName).updateData(["chartIncludeArchive": value])
        self.delegate?.applyOptions()
    }
    
    @objc func dataTypeChanged(sender:UISegmentedControl) {
        guard let uid = Auth.auth().currentUser?.uid else { return }
        let index = sender.selectedSegmentIndex
        var value: String
        switch index {
            case 0:
                value = "Weight"
            case 1:
                value = "Reps"
            default:
                value = "Weight"
        }
        
        db.collection("Users").document(uid).collection("Category").document(exerciseCategory).collection("Exercises").document(exerciseName).updateData(["chartDataType": value])
        self.delegate?.applyOptions()
        
    }
    
    
    let archivedDataLabel: UILabel = {
       let label = UILabel()
       label.text = "Include Archived Data Points"
       label.textColor = .black
       // enable autolayout
       label.translatesAutoresizingMaskIntoConstraints = false
       
       return label
    }()

    let archivedDataSwitch: UISwitch = {
        let mySwitch = UISwitch()
        mySwitch.onTintColor = Utilities.loadTheme()
        mySwitch.translatesAutoresizingMaskIntoConstraints = false
        mySwitch.addTarget(self, action: #selector(archivedDataChanged(mySwitch:)), for: UIControl.Event.valueChanged)
        return mySwitch
       
    }()
    
    let dataTypeLabel: UILabel = {
        let label = UILabel()
        label.text = "Data Type:"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let dataTypeControl: UISegmentedControl = {
        let color = Utilities.loadTheme()
        let types = ["Weight","Reps"]
        let sc = UISegmentedControl(items: types)
        // default as first item
        sc.selectedSegmentIndex = 0
        sc.overrideUserInterfaceStyle = .light
        sc.translatesAutoresizingMaskIntoConstraints = false
        sc.selectedSegmentTintColor = color
        // changes text color to black for selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.white], for: .selected)
        // changes text color to black for non selected button text
        sc.setTitleTextAttributes([NSAttributedString.Key.foregroundColor: UIColor.black], for: .normal)
        sc.addTarget(self, action: #selector(dataTypeChanged(sender:)), for: .valueChanged)

        return sc
    }()
    
    func setupUI() {
        
        let silverBackgroundView = UIView()
        silverBackgroundView.backgroundColor = UIColor.white
        silverBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(silverBackgroundView)
        silverBackgroundView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        silverBackgroundView.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor).isActive = true
        silverBackgroundView.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor).isActive = true
        
        view.addSubview(archivedDataLabel)
        archivedDataLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20).isActive = true
        archivedDataLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        view.addSubview(archivedDataSwitch)
        archivedDataSwitch.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        archivedDataSwitch.centerYAnchor.constraint(equalTo: archivedDataLabel.centerYAnchor).isActive = true
        
        view.addSubview(dataTypeLabel)
        dataTypeLabel.topAnchor.constraint(equalTo:  archivedDataSwitch.bottomAnchor, constant: 16).isActive = true
        dataTypeLabel.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        
        view.addSubview(dataTypeControl)
        dataTypeControl.topAnchor.constraint(equalTo: dataTypeLabel.bottomAnchor, constant: 16).isActive = true
        dataTypeControl.leftAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leftAnchor, constant: 16).isActive = true
        dataTypeControl.rightAnchor.constraint(equalTo: view.safeAreaLayoutGuide.rightAnchor, constant: -16).isActive = true
        
        silverBackgroundView.bottomAnchor.constraint(equalTo: dataTypeControl.bottomAnchor, constant: 16).isActive = true
        
    }

}
