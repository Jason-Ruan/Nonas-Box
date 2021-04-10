//
//  ShoppingListTableViewCell.swift
//  Nonas Box
//
//  Created by Jason on 3/16/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import UIKit
import Kingfisher

class ShoppingListTableViewCell: UITableViewCell {
    
    // MARK: - UI Objects
    private lazy var shoppingItemImageView: UIImageView = {
        let iv = UIImageView()
        iv.backgroundColor = .white
        iv.layer.cornerRadius = 15
        iv.layer.borderWidth = 0.5
        iv.layer.borderColor = #colorLiteral(red: 0.7819456907, green: 0.7819456907, blue: 0.7819456907, alpha: 0.75).cgColor
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Fonts.handwriting.rawValue, size: 30)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 16)
        label.textColor = subtitleTextColor
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    // MARK: - Properties
    var shoppingItem: ShoppingItem! {
        didSet {
            configureViews()
        }
    }
    
    private let padding: CGFloat = 15
    private let subtitleTextColor = #colorLiteral(red: 0.4384076322, green: 0.466779797, blue: 0.594195651, alpha: 1)
    
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private Functions
    private func setUpViews() {
        addSubview(shoppingItemImageView)
        addSubview(nameLabel)
        addSubview(quantityLabel)
        
        shoppingItemImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shoppingItemImageView.topAnchor.constraint(equalTo: topAnchor, constant: padding / 2),
            shoppingItemImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding / 2),
            shoppingItemImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding),
            shoppingItemImageView.widthAnchor.constraint(equalTo: shoppingItemImageView.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: shoppingItemImageView.trailingAnchor, constant: padding),
            nameLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
//            nameLabel.bottomAnchor.constraint(equalTo: bottomAnchor),
//            nameLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.4)
            
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
        
        NSLayoutConstraint.activate([
//            quantityLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
//            quantityLabel.leadingAnchor.constraint(equalTo: nameLabel.trailingAnchor, constant: padding),
//            quantityLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
            
            quantityLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            quantityLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            quantityLabel.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding)
        ])
    }
    
    func configureViews() {
        layoutIfNeeded()
        shoppingItemImageView.kf.indicatorType = .activity
        shoppingItemImageView.kf.setImage(with: shoppingItem.imageURL,
                                          options: [.onFailureImage(UIImage(systemName: .photoFill)),
                                                    .cacheOriginalImage])
        nameLabel.text = shoppingItem.itemName
        quantityLabel.text = "\(shoppingItem.itemUnit ?? "")"
    }
    
    
    // MARK: - ReuseIdentifier
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
