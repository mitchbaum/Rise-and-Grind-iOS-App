//
//  AnalyticsController.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 11/18/24.
//
import Foundation
import UIKit
import FirebaseAuth
import Firebase
import SwiftUI

class AnalyticsController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    private var lineGraphData = LineGraphData()
    private var lineGraphController: UIHostingController<LineGraph>?
    
    
    let userDefaults = UserDefaults.standard
    let db = Firestore.firestore()
    
    var contents = [Analytics]()
    var graphData: [DataModel] = []
    var categoryCollectionReference: CollectionReference!
    var chartDataTypeOptions: String = "Weight"
    var chartIncludeArchiveOption: Bool = false
    
    public var exerciseName: String = ""
    public var exerciseCategory: String = ""
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        navigationItem.largeTitleDisplayMode = .never

        navigationItem.rightBarButtonItem = UIBarButtonItem(
            image: UIImage(systemName: "slider.horizontal.2.square"),
            style: .plain,
            target: self,
            action: #selector(handleOpenOptions)
        )

        // how the tableView variable gets the data from the contents array. 
        tableView.dataSource = self
        tableView.delegate = self
        
        let weightMetric = userDefaults.object(forKey: "weightMetric")
        
        if weightMetric as! Int == 0 {
            metricLabel.text = "(LBS)"
        } else {
            metricLabel.text = "(KG)"
        }
        

       
        
        categoryCollectionReference = Firestore.firestore().collection("Category")
        Task {
           do {
               try await fetchOptions()
               print(chartDataTypeOptions, chartIncludeArchiveOption)
               fetchAnalytics()
           } catch {
               print("Failed to fetch categories: \(error)")
           }
        }
        setupUI()
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
                self.chartDataTypeOptions = chartDataType ?? "Weight"
                self.chartIncludeArchiveOption = chartIncludeArchive ?? false
            }
        } catch {
            debugPrint("Error fetching exercise: \(error)")
            throw error
        }
    }
    
    public func populateChart() {
        graphData = []
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MM/dd/yyyy" // Adjust based on your timestamp format
        
        for analytics in contents {
            if let timeStampString = analytics.timeStamp,
               let timeStampDouble = Double(timeStampString),
               var weightValue = analytics.weight.last as? String,
               let id = analytics.id {
                
                // Convert the Unix timestamp to a Date
                let date = Date(timeIntervalSince1970: timeStampDouble)
                let weightMetric = userDefaults.object(forKey: "weightMetric")
                // convert weight metric
                if weightMetric as? Int == 0 {
                    if weightValue.trimmingCharacters(in: .whitespaces).suffix(2) == ".5" {
                        weightValue = "\((Double(weightValue) ?? 0.0) * 1.0)"
                    } else {
                        weightValue = "\((Int((Double(weightValue) ?? 0.0) * 1.0)))"
                    }
                } else {
                    weightValue = "\((Int((Double(weightValue) ?? 0.0) * 0.453592)))"
                }
                // Create the DataModel
                let dataModel = DataModel(id: id, weight: Double(weightValue) ?? 0.0, createdAt: date)
                graphData.append(dataModel)
            }
        }
        lineGraphData.list = graphData
    }
    
    
    // fetches the analytics of exercises from Firebase database
    func fetchAnalytics() {
        contents = []
        let name = exerciseName
        let category = exerciseCategory
        let db = Firestore.firestore()
        guard let uid = Auth.auth().currentUser?.uid else { return }
        db.collection("Users").document(uid).collection("Category").document(category).collection("Exercises").document(name).collection("Analytics")
            .getDocuments { (snapshot, error) in
            if let err = error {
                debugPrint("Error fetching analytics: \(err)")
            } else {
                guard let snap = snapshot else { return }
                for document in snap.documents {
                    let data = document.data()
                    let id = data["id"] as? String ?? ""
                    let timeStamp = data["timestamp"] as? String ?? ""
                    let weight = data["weight"] as? Array ?? []
                    let reps = data["reps"] as? Array ?? []
                    
                    let newAnalytic = Analytics(timeStamp: timeStamp, weight: weight, reps: reps, id: id)
                    self.contents.append(newAnalytic)
                }
            }
            self.sortContents()
        }

    }
    
    func sortContents() {
        contents.sort(by: {$0.timeStamp ?? "" > $1.timeStamp ?? ""})
        self.tableView.reloadData()
        populateChart()
    }
    
    @objc func handleOpenOptions() {
        let optionsController = OptionsController()
        let navController = CustomNavigationController(rootViewController: optionsController)
        optionsController.exerciseName = exerciseName
        optionsController.exerciseCategory = exerciseCategory
        self.present(navController, animated: true, completion: nil)
    }
    
    private let headerHeight: CGFloat = 340
    private let header: UIView = {
        let header = UIView()
        header.backgroundColor = .white
        header.translatesAutoresizingMaskIntoConstraints = false
        return header
    }()
    
    let tableView: UITableView = {
        let table = UITableView()
        table.register(AnalyticsCell.self, forCellReuseIdentifier: AnalyticsCell.identifier)
        table.translatesAutoresizingMaskIntoConstraints = false
        table.backgroundColor = .darkGray
        table.separatorColor = .darkGray
        table.translatesAutoresizingMaskIntoConstraints = false
        return table
    }()
    
    let name: UILabel = {
        let label = UILabel()
        label.text = "Exercise Name"
        label.font = UIFont.boldSystemFont(ofSize: 22)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        //label.backgroundColor = .yellow
        return label
    }()
    
    let category: UILabel = {
        let label = UILabel()
        label.text = "Category"
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let metricLabel: UILabel = {
        let label = UILabel()
        label.text = "(weight)"
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .yellow
        return label
    }()
    
    func setupUI() {
        
        view.addSubview(header)
        header.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor).isActive = true
        header.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        header.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        
        
        header.addSubview(name)
        name.topAnchor.constraint(equalTo: header.topAnchor, constant: 16).isActive = true
        name.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 16).isActive = true
        
        header.addSubview(metricLabel)
        metricLabel.topAnchor.constraint(equalTo: header.topAnchor, constant: 16).isActive = true
        metricLabel.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        
        name.rightAnchor.constraint(equalTo: metricLabel.leftAnchor, constant: -16).isActive = true
        
        header.addSubview(category)
        category.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 16).isActive = true
        category.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        category.topAnchor.constraint(equalTo: name.bottomAnchor).isActive = true
        
        
        let lineGraphController = UIHostingController(rootView: LineGraph(data: lineGraphData).environment(\.colorScheme, .light))
        guard let lineGraph = lineGraphController.view else {
            return
        }
        header.addSubview(lineGraph)
        lineGraph.translatesAutoresizingMaskIntoConstraints = false
        lineGraph.topAnchor.constraint(equalTo: category.bottomAnchor, constant: 8).isActive = true
        lineGraph.rightAnchor.constraint(equalTo: header.rightAnchor, constant: -16).isActive = true
        lineGraph.leftAnchor.constraint(equalTo: header.leftAnchor, constant: 16).isActive = true
       
        header.bottomAnchor.constraint(equalTo: lineGraph.bottomAnchor, constant: 16).isActive = true
        
        view.addSubview(tableView)
        tableView.topAnchor.constraint(equalTo: header.bottomAnchor).isActive = true
        tableView.leadingAnchor.constraint(equalTo: view.leadingAnchor).isActive = true
        tableView.trailingAnchor.constraint(equalTo: view.trailingAnchor).isActive = true
        tableView.bottomAnchor.constraint(equalTo: view.bottomAnchor).isActive = true

    }
    
    
    @objc private func handleDone() {
        dismiss(animated: true, completion: nil)
    }
    
    // create alert that will present an error, this can be used anywhere in the code to remove redundant lines of code
    private func showError(title: String, message: String) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .default, handler: nil))
        present(alertController, animated: true, completion: nil)
        return
    }
}

