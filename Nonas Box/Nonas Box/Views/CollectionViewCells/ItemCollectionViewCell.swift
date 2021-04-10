//
//  ItemCollectionViewCell.swift
//  Nonas Box
//
//  Created by Jason Ruan on 9/30/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit
import Kingfisher

class ItemCollectionViewCell: UICollectionViewCell {
    
    //MARK: - UI Objects
    private lazy var itemImageView: UIImageView = {
        let iv = UIImageView()
        iv.kf.indicatorType = .activity
        iv.backgroundColor = .white
        iv.contentMode = .scaleAspectFit
        return iv
    }()
    
    public lazy var itemNameLabel: UILabel = {
        let label = UILabel()
        label.adjustsFontSizeToFitWidth = true
        label.font = UIFont.boldSystemFont(ofSize: 25)
        label.backgroundColor = . systemBlue
        return label
    }()
    private lazy var dateAddedLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textColor = .systemGray2
        label.backgroundColor = .systemYellow
        return label
    }()
    
    
    //MARK: - Properties
    public var item: UPC_Item! {
        didSet {
            configureCell(forItem: item)
        }
    }
    
    public static var identifier: String {
        return String(describing: self)
    }
    
    private let padding: CGFloat = 5
    
    //MARK: - Initializerss
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 15
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        clipsToBounds = true
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Functions
    private func configureCell(forItem item: UPC_Item) {
        itemNameLabel.text = "\(item.title?.capitalized ?? "Item_name")"
        itemImageView.image = UIImage(systemName: .photoFill)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMM d, yyyy"
        dateAddedLabel.text =  "Added on: \(dateFormatter.string(from: item.dateAdded ?? Date()))"
        
        guard let imageURLs = item.images, !imageURLs.isEmpty else {
            return
        }
        
        for url in imageURLs {
            guard itemImageView.image == UIImage(systemName: .photoFill) else { return }
            itemImageView.kf.setImage(with: url,
                                      options: [.onFailureImage(UIImage(systemName: .photoFill)),
                                                .cacheOriginalImage])
        }
    }
    
    
    //MARK: - Constraints
    private func setUpViews() {
        addSubview(itemImageView)
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemImageView.topAnchor.constraint(equalTo: topAnchor),
            itemImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            itemImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33),
            itemImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addSubview(itemNameLabel)
        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemNameLabel.topAnchor.constraint(equalTo: topAnchor),
            itemNameLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor),
            itemNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            itemNameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.65)
        ])
        
        addSubview(dateAddedLabel)
        dateAddedLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            dateAddedLabel.topAnchor.constraint(equalTo: itemNameLabel.bottomAnchor),
            dateAddedLabel.leadingAnchor.constraint(equalTo: itemImageView.trailingAnchor),
            dateAddedLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            dateAddedLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
}
