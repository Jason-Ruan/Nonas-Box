//
//  CookingCollectionViewCell.swift
//  Nonas Box
//
//  Created by Jason Ruan on 10/9/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class CookingCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Objects
    lazy var recipeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.clipsToBounds = true
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy var recipeNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // MARK: - Properties
    var recipe: RecipeDetails! {
        didSet {
            configureCell(forRecipe: recipe)
        }
    }
    
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        layer.cornerRadius = 5
        layer.borderWidth = 2
        layer.borderColor = UIColor.lightGray.cgColor
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 5, height: 5)
        addSubviews()
        constrainSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private Methods
    private func addSubviews() {
        contentView.addSubview(recipeImageView)
        contentView.addSubview(recipeNameLabel)
    }
    
    private func constrainSubviews() {
        NSLayoutConstraint.activate([
            recipeImageView.topAnchor.constraint(equalTo: topAnchor),
            recipeImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            recipeImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            recipeImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        NSLayoutConstraint.activate([
            recipeNameLabel.topAnchor.constraint(equalTo: topAnchor),
            recipeNameLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor),
            recipeNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            instructionTableView.topAnchor.constraint(equalTo: recipeNameLabel.bottomAnchor),
            instructionTableView.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor),
            instructionTableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            instructionTableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
    private func configureCell(forRecipe recipe: RecipeDetails) {
        if let imageURL = recipe.image {
            ImageHelper.shared.getImage(url: imageURL) { (result) in
                switch result {
                    case .success(let image):
                        self.recipeImageView.image = image
                    case .failure(let error):
                        print("Could not find image for \(recipe.title ?? "this recipe"), error: \(error)")
                }
            }
        }
    }
    
}

