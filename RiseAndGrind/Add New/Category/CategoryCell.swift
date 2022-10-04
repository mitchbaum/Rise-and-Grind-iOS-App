//
//  CategoryCell.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 11/22/21.
//

import Foundation
import UIKit

class CategoryCell: UITableViewCell {
    
    static let identifier = "CategoryCell"
    
    
    let nameLabel: UILabel = {
        let label = UILabel()
        label.text = "Name"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()

    
    
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // color of table view cell
        backgroundColor = UIColor.white
        
        addSubview(nameLabel)
        nameLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        nameLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true

        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
