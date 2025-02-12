//
//  ReorderCell.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 1/17/25.
//

import UIKit

class ReorderCell: UITableViewCell {

    static let identifier = "ReorderCell"
    
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
    
    let eyeImageView: UIImageView = {
        let imageView = UIImageView(image: #imageLiteral(resourceName: "eye-off"))
        imageView.contentMode = .scaleAspectFit
        imageView.translatesAutoresizingMaskIntoConstraints = false
        imageView.image = imageView.image?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .lightGray
        // circular picture
        //imageView.layer.cornerRadius = 30 // this value needs to be half the size of the height to make the image circular
        imageView.clipsToBounds = true
//        imageView.layer.borderWidth = 0.8
        return imageView
    }()
    
    let notes: UILabel = {
        let label = UILabel()
        label.text = "Notes"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        label.numberOfLines = 0
        return label
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
    
    let cardView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    let alertView: UIView = {
        let view = UIView()
        view.backgroundColor = .lightBlue
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.layer.maskedCorners = [.layerMinXMaxYCorner, .layerMinXMinYCorner]
        //  [.layerMinXMaxYCorner, .layerMaxXMaxYCorner, .layerMinXMinYCorner, .layerMaxXMinYCorner]  [bottom left, bottom right, top left, top right]
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
        
        addSubview(alertView)
        alertView.topAnchor.constraint(equalTo: topAnchor, constant: 2).isActive = true
        alertView.leftAnchor.constraint(equalTo: leftAnchor, constant: 5).isActive = true
        alertView.widthAnchor.constraint(equalToConstant: 10).isActive = true
        alertView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -2).isActive = true
        
        addSubview(eyeImageView)
        eyeImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 26).isActive = true
        eyeImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        eyeImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        eyeImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
        
        addSubview(name)
        name.leftAnchor.constraint(equalTo: eyeImageView.rightAnchor, constant: 8).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        name.rightAnchor.constraint(equalTo: rightAnchor, constant: -90).isActive = true

        
        addSubview(notes)
        notes.leftAnchor.constraint(equalTo: leftAnchor, constant: 26).isActive = true
        notes.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10).isActive = true
        notes.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        
        addSubview(updateImageView)
        updateImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 26).isActive = true
        updateImageView.topAnchor.constraint(equalTo: notes.bottomAnchor, constant: 10).isActive = true
        updateImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        updateImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true

        addSubview(updateLabel)
        updateLabel.leftAnchor.constraint(equalTo: updateImageView.rightAnchor, constant: 5).isActive = true
        updateLabel.topAnchor.constraint(equalTo: notes.bottomAnchor, constant: 10).isActive = true
        updateLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        updateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
