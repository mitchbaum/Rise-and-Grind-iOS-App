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
    
    let categoryLabel: UILabel = {
        let label = UILabel()
        label.text = "Category"
        label.textColor = .lightBlue
        label.font = UIFont.systemFont(ofSize: 20)
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
    }()
    
    let categoriesContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .red
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
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

    let updateImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "clock-icon"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = UIColor.lightBlue
        // circular picture
        //imageView.layer.cornerRadius = 30 // this value needs to be half the size of the height to make the image circular
        imageView.clipsToBounds = true
//        imageView.layer.borderWidth = 0.8
        return imageView
    }()
    
    
    let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let pillView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.backgroundColor = .lightGray
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
    
//        addSubview(categoriesContainerView)
//        categoriesContainerView.addSubview(pillView)
//        pillView.addSubview(categoryLabel)
//        categoryLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 31).isActive = true
//        categoryLabel.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 10).isActive = true
//        categoryLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -22).isActive = true
//        
//        
//        pillView.topAnchor.constraint(equalTo: categoriesContainerView.topAnchor).isActive = true
//        pillView.leftAnchor.constraint(equalTo: categoriesContainerView.leftAnchor).isActive = true
//        pillView.rightAnchor.constraint(equalTo: categoriesContainerView.rightAnchor).isActive = true
//        
//        categoriesContainerView.topAnchor.constraint(equalTo: dateLabel.bottomAnchor, constant: 5).isActive = true
//        categoriesContainerView.leftAnchor.constraint(equalTo: leftAnchor, constant: 26).isActive = true
//        categoriesContainerView.rightAnchor.constraint(equalTo: rightAnchor, constant: -22).isActive = true
//       
//        categoriesContainerView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true

        
        
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    
    
    
}

