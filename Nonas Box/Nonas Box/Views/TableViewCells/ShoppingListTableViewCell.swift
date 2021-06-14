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
        iv.contentMode = .scaleAspectFit
        iv.clipsToBounds = true
        return iv
    }()
    
    private lazy var nameLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: Fonts.circular.fontName, size: 16)
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    private lazy var quantityLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.boldSystemFont(ofSize: 12.5)
        label.textColor = subtitleTextColor
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 2
        label.textAlignment = .left
        return label
    }()
    
    private lazy var crossedOutLineView: UIView = {
        let v = UIView()
        v.backgroundColor = .systemIndigo
        v.isHidden = true
        return v
    }()
    
    // MARK: - Properties
    var shoppingItem: ShoppingItem! {
        didSet {
            configureViews()
        }
    }
    
    private let padding: CGFloat = 15
    private let subtitleTextColor: UIColor = .lightGray
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        backgroundColor = .clear
        selectionStyle = .none
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Functions
    private func setUpViews() {
        contentView.addSubview(shoppingItemImageView)
        contentView.addSubview(nameLabel)
        contentView.addSubview(quantityLabel)
        contentView.addSubview(crossedOutLineView)
        
        shoppingItemImageView.translatesAutoresizingMaskIntoConstraints = false
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        quantityLabel.translatesAutoresizingMaskIntoConstraints = false
        crossedOutLineView.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            shoppingItemImageView.topAnchor.constraint(equalTo: topAnchor, constant: padding / 2),
            shoppingItemImageView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -padding / 2),
            shoppingItemImageView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding * 2),
            shoppingItemImageView.widthAnchor.constraint(equalTo: shoppingItemImageView.heightAnchor)
        ])
        
        NSLayoutConstraint.activate([
            nameLabel.leadingAnchor.constraint(equalTo: shoppingItemImageView.trailingAnchor, constant: padding),
            nameLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            nameLabel.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -padding)
        ])
        
        NSLayoutConstraint.activate([
            quantityLabel.topAnchor.constraint(equalTo: nameLabel.bottomAnchor),
            quantityLabel.leadingAnchor.constraint(equalTo: nameLabel.leadingAnchor),
            quantityLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            crossedOutLineView.centerYAnchor.constraint(equalTo: centerYAnchor),
            crossedOutLineView.centerXAnchor.constraint(equalTo: centerXAnchor),
            crossedOutLineView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.95),
            crossedOutLineView.heightAnchor.constraint(equalToConstant: 1)
        ])
    }
    
    func configureViews() {
        layoutIfNeeded()
        shoppingItemImageView.kf.indicatorType = .activity
        shoppingItemImageView.kf.setImage(with: shoppingItem.imageURL,
                                          options: [.onFailureImage(UIImage(systemName: .photoFill)),
                                                    .cacheOriginalImage])
        nameLabel.text = shoppingItem.itemName.capitalized
        quantityLabel.text = "\(shoppingItem.itemUnit ?? "")"
    }
    
    func toggleCrossedLineStatus(isCrossedOut: Bool) {
        crossedOutLineView.isHidden = !isCrossedOut
        contentView.alpha = isCrossedOut ? 0.33 : 1
    }
    
    // MARK: - ReuseIdentifier
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
