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
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy var recipeNameLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var instructionCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: contentView.frame, collectionViewLayout: layout)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
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
        contentView.layer.cornerRadius = 5
        layer.shadowRadius = 10
        layer.shadowOffset = CGSize(width: 10, height: 10)
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
        contentView.addSubview(instructionCollectionView)
    }
    
    private func constrainSubviews() {
        NSLayoutConstraint.activate([
            recipeImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            recipeImageView.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            recipeImageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor)
        ])
        
        NSLayoutConstraint.activate([
            recipeNameLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            recipeNameLabel.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor),
            recipeNameLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor)
        ])
        
        NSLayoutConstraint.activate([
            recipeImageView.topAnchor.constraint(equalTo: recipeNameLabel.bottomAnchor),
            recipeImageView.leadingAnchor.constraint(equalTo: recipeImageView.trailingAnchor),
            recipeImageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor)
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
        
        self.recipeNameLabel.text = recipe.title
    }
    
}


// MARK: - CollectionView Methods
extension CookingCollectionViewCell: UICollectionViewDataSource , UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return recipe.analyzedInstructions?.count ?? 0
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "instructionCell", for: indexPath) as? InstructionCollectionViewCell else { return UICollectionViewCell() }
        
        return cell
    }
    
    
}
