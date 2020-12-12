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
        return iv
    }()
    
    lazy var recipeNameLabel: RecipeBlurbLabel = {
        return RecipeBlurbLabel()
    }()
    
    
    // MARK: - Properties
    var recipe: RecipeDetails! {
        didSet {
            configureCell(forRecipe: recipe)
        }
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .systemBackground
        layer.cornerRadius = 10
        layer.borderWidth = 2
        layer.borderColor = UIColor.lightGray.cgColor
        layer.shadowRadius = 5
        layer.shadowColor = UIColor.darkGray.cgColor
        layer.shadowOpacity = 1
        layer.shadowOffset = CGSize(width: 5, height: 5)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private Methods
    private func setUpViews() {
        contentView.addSubview(recipeImageView)
        recipeImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipeImageView.topAnchor.constraint(equalTo: topAnchor),
            recipeImageView.leadingAnchor.constraint(equalTo: leadingAnchor),
            recipeImageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.5),
            recipeImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        contentView.addSubview(recipeNameLabel)
        recipeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipeNameLabel.topAnchor.constraint(equalTo: topAnchor),
            recipeNameLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor),
            recipeNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            recipeNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
    }
    
    private func configureCell(forRecipe recipe: RecipeDetails) {
        recipeNameLabel.configureAttributedText(title: recipe.title, servings: recipe.servings, readyInMinutes: recipe.readyInMinutes)
        
        if let imageURL = recipe.imageURL {
            ImageHelper.shared.getImage(urls: [imageURL]) { (result) in
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

