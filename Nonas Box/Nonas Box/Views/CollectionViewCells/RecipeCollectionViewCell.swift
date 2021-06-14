//
//  RecipeCollectionViewCell.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/10/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit
import Kingfisher

class RecipeCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Objects
    private lazy var foodImage: UIImageView = {
        let imageView = UIImageView()
        imageView.layer.borderWidth = 0.75
        imageView.layer.borderColor = #colorLiteral(red: 1, green: 0.687940836, blue: 0.5207877159, alpha: 0.8489672517).cgColor
        imageView.tintColor = #colorLiteral(red: 1, green: 0.687940836, blue: 0.5207877159, alpha: 0.8489672517)
        imageView.contentMode = .scaleAspectFill
        imageView.layer.cornerRadius = layer.cornerRadius
        imageView.kf.indicatorType = .activity
        (imageView.kf.indicator?.view as? UIActivityIndicatorView)?.color = #colorLiteral(red: 0.8859762549, green: 0.6057382822, blue: 0.4648851752, alpha: 1)
        return imageView
    }()
    
    private lazy var foodInfoLabel: RecipeBlurbLabel = {
        let label = RecipeBlurbLabel()
        label.backgroundColor = #colorLiteral(red: 0.2295365632, green: 0.2428716421, blue: 0.2767262459, alpha: 0.5)
        label.layer.cornerRadius = 15
        label.clipsToBounds = true
        return label
    }()
    
    private lazy var bookmarkedImageView: UIImageView = {
        let imageView = UIImageView(image: UIImage(systemName: "bookmark.fill"))
        imageView.isHidden = true
        imageView.tintColor = .red
        imageView.contentMode = .scaleAspectFill
        imageView.addGradientLayer(colors: [.yellow, .red])
        return imageView
    }()
    
    // MARK: - Properties
    public var recipe: Recipe! {
        didSet {
            guard let recipe = self.recipe else { return }
            configureCell(recipe: recipe)
            bookmarkedImageView.isHidden = !checkIfRecipeIsBookmarked(id: recipe.id)
        }
    }
    
    public var recipeDetails: RecipeDetails! {
        didSet {
            guard let recipeDetails = self.recipeDetails else { return }
            configureCell(recipeDetails: recipeDetails)
        }
    }
    
    public static var identifier: String {
        return String(describing: self)
    }
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .white
        clipsToBounds = true
        layer.cornerRadius = 20
        layer.borderWidth = 0.75
        layer.borderColor = UIColor.systemYellow.cgColor
        setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Functions
    private func setUpCell() {
        contentView.addSubview(foodImage)
        foodImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            foodImage.topAnchor.constraint(equalTo: contentView.topAnchor),
            foodImage.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            foodImage.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            foodImage.bottomAnchor.constraint(equalTo: contentView.bottomAnchor)
        ])
        
        contentView.addSubview(foodInfoLabel)
        foodInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            foodInfoLabel.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.33),
            foodInfoLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            foodInfoLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -10),
            foodInfoLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -10)
        ])
        
        contentView.addSubview(bookmarkedImageView)
        bookmarkedImageView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            bookmarkedImageView.topAnchor.constraint(equalTo: contentView.topAnchor),
            bookmarkedImageView.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -(contentView.frame.width / 7)),
            bookmarkedImageView.heightAnchor.constraint(equalTo: contentView.heightAnchor, multiplier: 0.15)
        ])
        
        layoutIfNeeded()
    }
    
    private func configureCell(recipe: Recipe? = nil, recipeDetails: RecipeDetails? = nil) {
        if let recipe = recipe {
            loadImage(url: recipe.imageURL)
            foodInfoLabel.configureAttributedText(title: "\n\(recipe.title ?? "Le dish")", servings: recipe.servings, readyInMinutes: recipe.readyInMinutes)
        }
        if let recipeDetails = recipeDetails {
            loadImage(url: recipeDetails.imageURL)
            foodInfoLabel.configureAttributedText(title: "\n\(recipeDetails.title ?? "Le dish")", servings: recipeDetails.servings, readyInMinutes: recipeDetails.readyInMinutes)
        }
    }
    
    private func loadImage(url: URL?) {
        let processor = DownsamplingImageProcessor(size: foodImage.bounds.size)
        foodImage.kf.setImage(with: url,
                              options: [.processor(processor),
                                        .scaleFactor(UIScreen.main.scale),
                                        .onFailureImage(UIImage(systemName: .photoFill)),
                                        .transition(.fade(0.3)),
                                        .cacheOriginalImage
                              ])
    }
    
    private func checkIfRecipeIsBookmarked(id: Int) -> Bool {
        do {
            return try Spoonacular_PersistenceHelper.manager.checkIsSaved(forRecipeID: id)
        } catch {
            print(error)
            return false
        }
    }
    
}
