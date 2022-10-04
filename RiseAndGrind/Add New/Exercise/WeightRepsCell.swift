//
//  WeightRepsCell.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 10/6/21.
//
import UIKit
import FirebaseAuth
import Firebase
import FirebaseDatabase
import JGProgressHUD
import FirebaseStorage

class WeightRepsCell: UITableViewCell {
    
    class TextField: UITextField {
            override func textRect(forBounds bounds: CGRect) -> CGRect {
                return bounds.insetBy(dx: 48, dy: 0)
            }
            
            override func editingRect(forBounds bounds: CGRect) -> CGRect {
                return bounds.insetBy(dx: 48, dy: 0)
            }
            
//            override var intrinsicContentSize: CGSize {
//                return .init(width: 50, height: 44)
//            }

        }
    
    static let identifier = "WeightRepsCell"
    
    
    let weightLabel: UILabel = {
        let label = UILabel()
        label.text = "Weight"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let weightTextField: UITextField = {
        let textField = UITextField()
        
        
        textField.attributedPlaceholder = NSAttributedString(string: "LBS",
                                     attributes: [NSAttributedString.Key.foregroundColor: UIColor.lightGray])
        textField.textColor = .black
        //textField.layer.borderWidth = 1
        //textField.layer.cornerRadius = 5
        textField.addLine(position: .bottom, color: .lightBlue, width: 1)
        textField.setLeftPaddingPoints(4)
        textField.backgroundColor = UIColor.white
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        textField.keyboardType = UIKeyboardType.decimalPad
        return textField
    }()
    
    let xLabel: UILabel = {
        let label = UILabel()
        label.text = "x"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let repsLabel: UILabel = {
        let label = UILabel()
        label.text = "Reps"
        label.textColor = .black
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    let repsTextField: UITextField = {
        let textField = UITextField()
        textField.keyboardType = UIKeyboardType.decimalPad
        textField.textColor = .black
        textField.addLine(position: .bottom, color: .lightBlue, width: 1)
        textField.setLeftPaddingPoints(4)
        textField.backgroundColor = UIColor.white
        // enable autolayout, without this constraints wont load properly
        textField.translatesAutoresizingMaskIntoConstraints = false
        return textField
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // color of table view cell
        //backgroundColor = UIColor.lightBlue
        
        addSubview(weightLabel)
        weightLabel.leftAnchor.constraint(equalTo: leftAnchor, constant: 16).isActive = true
        weightLabel.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        //weightLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        weightLabel.widthAnchor.constraint(equalToConstant: 60).isActive = true
        weightLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true

        
        contentView.addSubview(weightTextField)
        //weightTextField.frame = bounds
        weightTextField.leftAnchor.constraint(equalTo: weightLabel.rightAnchor, constant: 8).isActive = true
        weightTextField.topAnchor.constraint(equalTo: weightLabel.topAnchor).isActive = true
        weightTextField.widthAnchor.constraint(equalToConstant: 100).isActive = true
        weightTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        addSubview(xLabel)
        xLabel.leftAnchor.constraint(equalTo: weightTextField.rightAnchor, constant: 8).isActive = true
        xLabel.topAnchor.constraint(equalTo:  weightLabel.topAnchor).isActive = true
        xLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        addSubview(repsLabel)
        repsLabel.leftAnchor.constraint(equalTo: xLabel.rightAnchor, constant: 8).isActive = true
        repsLabel.topAnchor.constraint(equalTo: weightLabel.topAnchor).isActive = true
        //weightLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
        repsLabel.widthAnchor.constraint(equalToConstant: 45).isActive = true
        repsLabel.heightAnchor.constraint(equalToConstant: 35).isActive = true
        
        contentView.addSubview(repsTextField)
        repsTextField.leftAnchor.constraint(equalTo: repsLabel.rightAnchor, constant: 8).isActive = true
        repsTextField.topAnchor.constraint(equalTo: weightLabel.topAnchor).isActive = true
        repsTextField.widthAnchor.constraint(equalToConstant: 40).isActive = true
        repsTextField.heightAnchor.constraint(equalToConstant: 35).isActive = true

        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
