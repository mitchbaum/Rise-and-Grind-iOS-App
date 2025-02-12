//
//  ExerciseCell.swift
//  RiseAndGrind
//
//  Created by Mitch Baumgartner on 10/4/21.
//

import UIKit
extension UICollectionView {
    override open var intrinsicContentSize: CGSize {
        return contentSize
    }
}
class LeftAlignedCollectionViewFlowLayout: UICollectionViewFlowLayout {

    override func layoutAttributesForElements(in rect: CGRect) -> [UICollectionViewLayoutAttributes]? {
        let attributes = super.layoutAttributesForElements(in: rect)

        var leftMargin = sectionInset.left
        var maxY: CGFloat = -1.0
        attributes?.forEach { layoutAttribute in
            if layoutAttribute.frame.origin.y >= maxY {
                leftMargin = sectionInset.left
            }

            layoutAttribute.frame.origin.x = leftMargin

            leftMargin += layoutAttribute.frame.width + minimumInteritemSpacing
            maxY = max(layoutAttribute.frame.maxY , maxY)
        }

        return attributes
    }
}
class ExerciseCell: UITableViewCell,  UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    var setTextColor: UIColor = .black
    
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print("Number of sets items:", sets.count)
        return sets.count
    }

    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        print("Dequeue cell at index:", indexPath.row)
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SetCell.identifier, for: indexPath) as? SetCell else {
            return UICollectionViewCell()
        }
        cell.label.textColor = setTextColor
        cell.populateItemText(with: sets[indexPath.row])
        return cell
    }
    
    
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
    
    let formatLabel: UILabel = {
        let label = UILabel()
        label.text = "(weight x reps)"
        label.font = UIFont.italicSystemFont(ofSize: 12)
        label.textColor = .lightGray
        label.translatesAutoresizingMaskIntoConstraints = false
        //label.backgroundColor = .yellow
        return label
    }()
    
    
    let setsCollectionView: UICollectionView = {
        let layout = LeftAlignedCollectionViewFlowLayout()
        layout.minimumLineSpacing = 5
        layout.minimumInteritemSpacing = 5
        layout.estimatedItemSize = UICollectionViewFlowLayout.automaticSize

        let collectionView = UICollectionView(frame: .zero, collectionViewLayout: layout)
        collectionView.translatesAutoresizingMaskIntoConstraints = false
        collectionView.showsHorizontalScrollIndicator = false
        collectionView.isScrollEnabled = true
        collectionView.backgroundColor = .white
        return collectionView
   }()
    
    let setsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.axis = .horizontal
        stackView.spacing = 5
        stackView.alignment = .leading
        stackView.translatesAutoresizingMaskIntoConstraints = false
        return stackView
    }()
    
    let weightXreps: UILabel = {
        let label = UILabel()
        label.text = "- x -"
        label.textColor = .lightBlue
        label.font = UIFont.systemFont(ofSize: 20)
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
    
    let weightRepsView: UIView = {
        let view = UIView()
        view.backgroundColor = .white
        view.layer.masksToBounds = true
        view.layer.cornerRadius = 5
        view.translatesAutoresizingMaskIntoConstraints = false
        return view
    }()
    
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?){
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        // color of table view cell
        backgroundColor = .darkGray
        

        // Initialize the collection view with the layout
        setsCollectionView.delegate = self
        setsCollectionView.dataSource = self
        setsCollectionView.register(SetCell.self, forCellWithReuseIdentifier: SetCell.identifier)
        
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
        
        addSubview(name)
        name.leftAnchor.constraint(equalTo: leftAnchor, constant: 26).isActive = true
        name.topAnchor.constraint(equalTo: topAnchor, constant: 10).isActive = true
        name.rightAnchor.constraint(equalTo: rightAnchor, constant: -90).isActive = true
    
        
        addSubview(formatLabel)
        //formatLabel.leftAnchor.constraint(equalTo: name.rightAnchor, constant: 8).isActive = true
        formatLabel.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        formatLabel.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
        
        addSubview(eyeImageView)
        eyeImageView.topAnchor.constraint(equalTo: topAnchor, constant: 16).isActive = true
        eyeImageView.rightAnchor.constraint(equalTo: formatLabel.leftAnchor, constant: -8).isActive = true
        eyeImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
        eyeImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true

        
//        addSubview(setsCollectionView)
//           NSLayoutConstraint.activate([
//            setsCollectionView.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10),
//            setsCollectionView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 26),
//            setsCollectionView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -26),
//            //setsCollectionView.heightAnchor.constraint(equalToConstant: 400)
//           ])
//        
        addSubview(setsStackView)
        setsStackView.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10).isActive = true
        setsStackView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 31).isActive = true
        setsStackView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -15).isActive = true
        setsStackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
    
//        addSubview(weightRepsView)
//        addSubview(weightXreps)
//        weightXreps.leftAnchor.constraint(equalTo: leftAnchor, constant: 31).isActive = true
//        weightXreps.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 10).isActive = true
//        weightXreps.rightAnchor.constraint(equalTo: rightAnchor, constant: -22).isActive = true
//        
//        weightRepsView.topAnchor.constraint(equalTo: name.bottomAnchor, constant: 5).isActive = true
//        weightRepsView.leftAnchor.constraint(equalTo: leftAnchor, constant: 26).isActive = true
//        weightRepsView.rightAnchor.constraint(equalTo: weightXreps.rightAnchor, constant: -22).isActive = true
//        weightRepsView.bottomAnchor.constraint(equalTo: weightXreps.bottomAnchor, constant: 5).isActive = true
        
//        addSubview(notes)
//        notes.leftAnchor.constraint(equalTo: leftAnchor, constant: 26).isActive = true
//        notes.topAnchor.constraint(equalTo: setsStackView.bottomAnchor, constant: 15).isActive = true
//        notes.rightAnchor.constraint(equalTo: rightAnchor, constant: -16).isActive = true
//        
//        addSubview(updateImageView)
//        updateImageView.leftAnchor.constraint(equalTo: leftAnchor, constant: 26).isActive = true
//        updateImageView.topAnchor.constraint(equalTo: notes.bottomAnchor, constant: 10).isActive = true
//        updateImageView.heightAnchor.constraint(equalToConstant: 15).isActive = true
//        updateImageView.widthAnchor.constraint(equalToConstant: 15).isActive = true
//
//        addSubview(updateLabel)
//        updateLabel.leftAnchor.constraint(equalTo: updateImageView.rightAnchor, constant: 5).isActive = true
//        updateLabel.topAnchor.constraint(equalTo: notes.bottomAnchor, constant: 10).isActive = true
//        updateLabel.rightAnchor.constraint(equalTo: rightAnchor).isActive = true
//        updateLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -10).isActive = true
        
        
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    var sets: [Set] = []
    func populateSetsCollectionView(with sets: [Set]) {
        print("POPUALTE SETS!")
        self.sets = sets
        print("reloading collectionView data...")
        setsCollectionView.reloadData()
        var marginBottom: CGFloat = 0.0
//        if (sets.count == 1) {
//            marginBottom = 10
//        } else if
        DispatchQueue.main.async {
                // Ensure the layout is complete
                self.setsCollectionView.layoutIfNeeded()
            let rows = self.numberOfRows(in: self.setsCollectionView)
            print("Number of rows: \(rows)")
                // Get the correct content size
                let contentSize = self.setsCollectionView.collectionViewLayout.collectionViewContentSize
            print("CollectionView content size: \(contentSize.height)")
                
                // Remove existing height constraint if any
                if let existingHeightConstraint = self.setsCollectionView.constraints.first(where: { $0.firstAttribute == .height }) {
                   existingHeightConstraint.isActive = false
               }
            // Invalidate intrinsic content size to let the collection view resize itself
                    self.setsCollectionView.invalidateIntrinsicContentSize()
            
                // Update the height constraint
            self.setsCollectionView.heightAnchor.constraint(equalToConstant: contentSize.height + marginBottom).isActive = true
                
                // Notify the parent view to relayout
                self.setNeedsLayout()
                self.layoutIfNeeded()
            
            if let tableView = self.superview as? UITableView {
                        if let indexPath = tableView.indexPath(for: self) {
                            print("ROW: \(indexPath.row) HEIGHT:", tableView.rectForRow(at: indexPath).height)
                            tableView.beginUpdates()
                            tableView.endUpdates()
                        }
                    }
            }
    }
    
    func numberOfRows(in collectionView: UICollectionView) -> Int {
        guard let flowLayout = collectionView.collectionViewLayout as? UICollectionViewFlowLayout else {
            return 0
        }
        
        // Total number of items
        let totalItems = collectionView.numberOfItems(inSection: 0)
        
        // Calculate the total available width for items
        let contentWidth = collectionView.bounds.width
        print("numberOfRows contentWidth", contentWidth)
        let spacing = flowLayout.minimumInteritemSpacing
        
        // Initialize variables to track the total width of the row and the number of rows
        var currentRowWidth: CGFloat = 0
        var rowCount = 1  // Start with the first row
        
//        // Loop through all items and calculate the row count
//        for index in 0..<totalItems {
//            let indexPath = IndexPath(item: index, section: 0)
//            print("numberOfRows indexPath", indexPath)
//            
//            // Get the item's size directly from the flow layout
//            let itemWidth: CGFloat
//                if let cell = collectionView.cellForItem(at: indexPath) as? YourCustomCell {
//                    // Calculate the width of the item dynamically, for example, based on label/text width:
//                    itemWidth = cell.yourDynamicWidthCalculationMethod()
//                } else {
//                    // Fallback to a default item width if necessary
//                    itemWidth = flowLayout.itemSize.width
//                }
//            print("numberOfRows itemSize", itemSize)
//            
//            // Check if adding the item exceeds the row width
//            if currentRowWidth + itemSize.width + (index > 0 ? spacing : 0) <= contentWidth {
//                // Item fits in the current row
//                currentRowWidth += itemSize.width + (index > 0 ? spacing : 0)
//            } else {
//                // Item doesn't fit, so move it to the next row
//                rowCount += 1
//                currentRowWidth = itemSize.width // Start new row with this item
//            }
//        }
//        
        return rowCount
    }

    
    
    
}
