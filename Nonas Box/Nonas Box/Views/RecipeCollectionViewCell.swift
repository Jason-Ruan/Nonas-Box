//
//  RecipeCollectionViewCell.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/10/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

private enum SpinnerStatus {
    case on
    case off
}

class RecipeCollectionViewCell: UICollectionViewCell {
    
    //MARK: - UI Objects
    
    lazy var foodImage: UIImageView = {
        let iv = UIImageView(frame: CGRect(x: 0, y: 0, width: self.frame.width, height: self.frame.height))
        iv.layer.masksToBounds = true
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 25
        iv.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        iv.layer.borderWidth = 3
        iv.layer.borderColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        return iv
    }()
    
    lazy var foodInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        
        return label
    }()
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        spinner.startAnimating()
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    //MARK: - Properties
    
    var recipe: Recipe? {
        didSet {
            guard let recipe = self.recipe else { return }
            configureCell(recipe: recipe)
        }
    }
    
    
    //MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        layer.cornerRadius = 25
        setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
    }
    
    
    //MARK: - Private Functions
    
    private func setUpCell() {
        
        contentView.addSubview(foodImage)
        foodImage.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            foodImage.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            foodImage.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            foodImage.widthAnchor.constraint(equalToConstant: contentView.frame.width),
            foodImage.heightAnchor.constraint(equalToConstant: contentView.frame.height / 1.5)
        ])
        
        contentView.addSubview(foodInfoLabel)
        foodInfoLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            foodInfoLabel.topAnchor.constraint(equalTo: foodImage.bottomAnchor, constant: 5),
            foodInfoLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 20),
            foodInfoLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
            foodInfoLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
        
    }
    
    func configureCell(recipe: Recipe) {
        guard let title = recipe.title, let servings = recipe.servings, let prepTime = recipe.readyInMinutes else { return }
        
        let foodInfoText = NSMutableAttributedString(string: title, attributes: [.font : UIFont.boldSystemFont(ofSize: 15)])
        let prepInfo = NSAttributedString(string:
            """
            \nServes: \(servings)
            Ready in: \(prepTime) minutes
            """, attributes: [.font : UIFont.monospacedDigitSystemFont(ofSize: 12, weight: .light)])
        
        foodInfoText.append(prepInfo)
        
        foodInfoLabel.attributedText = foodInfoText
        
        foodImage.image = nil
        toggleSpinner(status: .on)
        
        guard let recipeID = recipe.id, let recipeImageURL = URL(string: "https://spoonacular.com/recipeImages/\(recipeID)-636x393") else {
            return
        }
        
        ImageHelper.shared.getImage(url: recipeImageURL) { (result) in
            switch result {
                case .success(let image):
                    DispatchQueue.main.async {
                        self.foodImage.image = image
                }
                case .failure(let error):
                    print(error)
            }
            self.toggleSpinner(status: .off)
        }
        
    }
    
    private func toggleSpinner(status: SpinnerStatus) {
        switch status {
            case .on:
                foodImage.addSubview(spinner)
                NSLayoutConstraint.activate([
                    spinner.centerXAnchor.constraint(equalTo: foodImage.centerXAnchor),
                    spinner.centerYAnchor.constraint(equalTo: foodImage.centerYAnchor)
                ])
            case .off:
                DispatchQueue.main.async {
                    self.spinner.stopAnimating()
                }
                
        }
    }
    
}
