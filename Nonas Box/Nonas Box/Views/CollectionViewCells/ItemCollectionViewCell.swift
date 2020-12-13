//
//  ItemCollectionViewCell.swift
//  Nonas Box
//
//  Created by Jason Ruan on 9/30/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class ItemCollectionViewCell: UICollectionViewCell {
    
    //MARK: - UI Objects
    private lazy var itemImageView: UIImageView = { return UIImageView() }()
    private lazy var itemNameLabel: UILabel = { return UILabel(alignment: .center) }()
    
    
    //MARK: - Properties
    public var item: UPC_Item! {
        didSet {
            configureCell(forItem: item)
        }
    }
    
    public static var identifier: String {
        return String(describing: self)
    }
    
    //MARK: - Initializerss
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.cornerRadius = 15
        layer.borderWidth = 1
        layer.borderColor = UIColor.lightGray.cgColor
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        itemImageView.image = nil
        super.prepareForReuse()
    }
    
    
    //MARK: - Functions
    private func configureCell(forItem item: UPC_Item) {
        itemNameLabel.text = item.title?.capitalized
        
        guard let barcode = item.barcode, let imageURLs = item.images else { return }
        ImageHelper.shared.getImage(cacheKey: barcode, urls: imageURLs) { [weak self] (result) in
            switch result {
                case .failure(let error):
                    print(error)
                case .success(let image):
                    self?.itemImageView.image = image
            }
        }
    }
    
    
    //MARK: - Constraints
    private func setUpViews() {
        addSubview(itemImageView)
        itemImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            itemImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            itemImageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            itemImageView.heightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.75)
        ])
    
        addSubview(itemNameLabel)
        itemNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemNameLabel.topAnchor.constraint(equalTo: itemImageView.bottomAnchor, constant: 5),
            itemNameLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 5),
            itemNameLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -5),
            itemNameLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -5),
        ])
    }
    
}
