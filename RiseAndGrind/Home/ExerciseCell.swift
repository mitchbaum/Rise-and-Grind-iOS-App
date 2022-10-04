//
//  ExerciseCell.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 10/4/21.
//

import UIKit

class ExerciseCell: UITableViewCell {
    
    static let identifier = "ExerciseCell"
    
    // exercise name
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
    
    let formatLabel: UILabel = {
        let label = UILabel()
        label.text = "(weight x reps)"
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .yellow
        return label
    }()
    
    let weightXreps: UILabel = {
        let label = UILabel()
        label.text = "- x -"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let notes: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    // create custom label for updated label
    let updateLabel: UILabel = {
        let label = UILabel()
        label.text = "Updated 3 min ago"
        //label.font = UIFont.boldSystemFont(ofSize: 10)
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .blue
        return label
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // color of table view cell
        //backgroundColor = UIColor.green
        
        addSubview(name)
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        name.rightAnchor.constraint(equalTo: rightAnchor, constant: -90).isActive = true
        
        addSubview(formatLabel)
        //formatLabel.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 8).isActive = true
        formatLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        formatLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true

       
        
        addSubview(weightXreps)
        weightXreps.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        weightXreps.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10).isActive = true
        weightXreps.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        
        addSubview(notes)
        notes.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        notes.topAnchor.constraint(equalTo: weightXreps.bottomAnchor, constant: 10).isActive = true
        notes.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true

        addSubview(updateLabel)
        updateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        updateLabel.topAnchor.constraint(equalTo: notes.bottomAnchor, constant: 10).isActive = true
        updateLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        updateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
}
