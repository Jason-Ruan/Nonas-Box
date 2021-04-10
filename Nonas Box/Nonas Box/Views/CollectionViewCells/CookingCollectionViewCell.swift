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
    private lazy var recipeImageView: UIImageView = {
        let iv = UIImageView()
        iv.contentMode = .scaleAspectFill
        iv.kf.indicatorType = .activity
        (iv.kf.indicator?.view as? UIActivityIndicatorView)?.color = #colorLiteral(red: 0.8859762549, green: 0.6057382822, blue: 0.4648851752, alpha: 1)
        return iv
    }()
    
    private lazy var recipeNameLabel:  UILabel = {
        return UILabel(numLines: 1,
                       fontName: .handwriting,
                       fontSize: 20,
                       alignment: .center)
    }()
    
    private lazy var underHalfHourLabel: UILabel = {
        let label = UILabel()
        label.layer.cornerRadius = 10
        label.backgroundColor = #colorLiteral(red: 0.4078232283, green: 0.4078232283, blue: 0.4078232283, alpha: 0.7519250987)
        let image = UIImage(systemName: .clockFill)!
        let imageTextAttachment = NSTextAttachment(image: image)
        let text = NSMutableAttributedString(attachment: imageTextAttachment)
        text.append(NSAttributedString(string: "Under 30 min. ", attributes: [.font : UIFont.boldSystemFont(ofSize: 14)]))
        label.attributedText = text
        label.isHidden = true
        label.clipsToBounds = true
        return label
    }()
    
    
    // MARK: - Properties
    var recipe: RecipeDetails! {
        didSet {
            configureCell(forRecipe: recipe)
        }
    }
    
    private let padding: CGFloat = 5
    
    static var identifier: String {
        return String(describing: self)
    }
    
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        clipsToBounds = true
        backgroundColor = .white
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
            recipeImageView.trailingAnchor.constraint(equalTo: trailingAnchor),
            recipeImageView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        contentView.addSubview(recipeNameLabel)
        recipeNameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            recipeNameLabel.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.3),
            recipeNameLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            recipeNameLabel.trailingAnchor.constraint(equalTo: trailingAnchor),
            recipeNameLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        contentView.addSubview(underHalfHourLabel)
        underHalfHourLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            underHalfHourLabel.topAnchor.constraint(equalTo: topAnchor, constant: padding),
            underHalfHourLabel.leadingAnchor.constraint(equalTo: leadingAnchor, constant: padding)
        ])
        
        layoutIfNeeded()
        
        recipeImageView.addGradientLayer(colors: [.clear, .clear, #colorLiteral(red: 0.00280471798, green: 0.2107150853, blue: 0.412620753, alpha: 0.5)])
    }
    
    private func configureCell(forRecipe recipe: RecipeDetails) {
        recipeNameLabel.text = recipe.title
        underHalfHourLabel.isHidden = (recipe.readyInMinutes ?? 10) > 30 ? true : false
        recipeImageView.kf.setImage(with: recipe.imageURL,
                                    options: [.onFailureImage(UIImage(systemName: .photoFill)),
                                              .transition(.fade(0.2))])
        { [weak self] (result) in
            switch result {
            case .failure:
                self?.recipeImageView.contentMode = .scaleAspectFit
            case .success:
                self?.recipeImageView.contentMode = .scaleAspectFill
            }
        }
    }
    
}

