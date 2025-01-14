//
//  RecentCell.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/6/25.
//

import UIKit

class RecentCell: UITableViewCell {
    
    static let identifier = "RecentCell"
    
    let dateLabel: UILabel = {
        let label = UILabel()
        label.text = "Date"
        label.font = UIFont.boldSystemFont(ofSize: 20)
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        //label.backgroundColor = .yellow
        return label
    }()
    
    let categoriesStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .vertical
        stackView.spacing = 5
        stackView.alignment = .leading
        stackView.distribution = .fill
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    
    let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // color of table view cell
        backgroundColor = .darkGray
        
        
        addSubview(cardView)
        cardView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        cardView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        cardView.rightAnchor.constraint(equalTo: rightAnchor, constant: -5).isActive = true
        cardView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        
        
        addSubview(dateLabel)
        dateLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 15).isActive = true
        dateLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        dateLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -90).isActive = true

        
        addSubview(categoriesStackView)
        categoriesStackView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10).isActive = true
        categoriesStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 15).isActive = true
        categoriesStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        categoriesStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
}

