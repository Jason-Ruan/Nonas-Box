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
    
    //MARK: - UI Objects
    
    private lazy var foodImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 25
        iv.layer.borderWidth = 3
        iv.layer.borderColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        iv.backgroundColor = .clear
        iv.tintColor = #colorLiteral(red: 1, green: 0.687940836, blue: 0.5207877159, alpha: 0.8489672517)
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    private lazy var foodInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.backgroundColor = #colorLiteral(red: 0.2295365632, green: 0.2428716421, blue: 0.2767262459, alpha: 0.5)
        label.layer.cornerRadius = 15
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    private lazy var bookmarkedImageView: UIImageView = {
        let iv = UIImageView(image: UIImage(systemName: "bookmark.fill"))
        iv.isHidden = true
        iv.tintColor = .red
        iv.contentMode = .scaleAspectFill
        iv.translatesAutoresizingMaskIntoConstraints = false
        
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.yellow.cgColor,  UIColor.red.cgColor]
        gradientLayer.frame = iv.bounds
        iv.layer.insertSublayer(gradientLayer, at: 0)
        
        return iv
    }()
    
    
    //MARK: - Properties
    
    public var recipe: Recipe! {
        didSet {
            guard let recipe = self.recipe else { return }
            configureCell(recipe: recipe)
            bookmarkedImageView.isHidden = !checkIfRecipeIsBookmarked(id: recipe.id)
        }
    }
    
    public static var identifier: String {
        return String(describing: self)
    }
    
    
    //MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        layer.borderWidth = 2
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 5, height: 3.0)
        layer.shadowRadius = 3
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 25).cgPath
        adjustBorderColor()
        setUpCell()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    //MARK: - Private Functions
    
    private func setUpCell() {
        contentView.addSubview(foodImage)
        NSLayoutConstraint.activate([
            foodImage.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            foodImage.centerXAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.centerXAnchor),
            foodImage.widthAnchor.constraint(equalToConstant: contentView.bounds.width),
            foodImage.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor)
        ])
        
        contentView.addSubview(foodInfoLabel)
        NSLayoutConstraint.activate([
            foodInfoLabel.heightAnchor.constraint(equalToConstant: contentView.safeAreaLayoutGuide.layoutFrame.height / 3),
            foodInfoLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            foodInfoLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant:  -10),
            foodInfoLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
        
        contentView.addSubview(bookmarkedImageView)
        NSLayoutConstraint.activate([
            bookmarkedImageView.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            bookmarkedImageView.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -(contentView.safeAreaLayoutGuide.layoutFrame.width / 7)),
            bookmarkedImageView.heightAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.heightAnchor, multiplier: 0.15)
        ])
        
    }
    
    private func adjustBorderColor() {
        if self.traitCollection.userInterfaceStyle == .dark {
            layer.borderColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
        } else {
            layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        }
    }
    
    private func configureCell(recipe: Recipe) {
        loadImage(recipe: recipe)
        
        guard let title = recipe.title else { return }
        
        let foodInfoText = NSMutableAttributedString(string: title, attributes: [.font : UIFont.boldSystemFont(ofSize: 15)])
        
        let image1TextAttachment = NSTextAttachment(image: UIImage(systemName: "person.2.fill")!)
        let image2TextAttachment = NSTextAttachment(image: UIImage(systemName: "clock.fill")!)
        let image1TextString = NSAttributedString(attachment: image1TextAttachment)
        let image2TextString = NSAttributedString(attachment: image2TextAttachment)
        
        let prepInfo = NSMutableAttributedString(string: "\n\n")
        
        if let servings = recipe.servings, let prepTime = recipe.readyInMinutes  {
            prepInfo.append(image1TextString)
            prepInfo.append(NSAttributedString(string: servings.description))
            prepInfo.append(NSAttributedString(string: "  |  "))
            prepInfo.append(image2TextString)
            prepInfo.append(NSAttributedString(string: convertMinutesToString(time: prepTime)))
        }
        
        foodInfoText.append(prepInfo)
        foodInfoLabel.attributedText = foodInfoText
    }
    
    private func loadImage(recipe: Recipe) {
        layoutIfNeeded()
        
        guard let imageURL = recipe.imageURL else {
            foodImage.contentMode = .scaleAspectFit
            foodImage.image = UIImage(systemName: .photoFill)
            return
        }
        
        let processor = DownsamplingImageProcessor(size: foodImage.bounds.size) |> RoundCornerImageProcessor(cornerRadius: foodImage.layer.cornerRadius)
        foodImage.kf.indicatorType = .activity
        (foodImage.kf.indicator?.view as? UIActivityIndicatorView)?.color = #colorLiteral(red: 1, green: 0.687940836, blue: 0.5207877159, alpha: 0.8489672517)
        foodImage.kf.setImage(with: imageURL,
                              options: [.processor(processor),
                                        .scaleFactor(UIScreen.main.scale),
                                        .onFailureImage(UIImage(systemName: .photoFill)),
                                        .cacheOriginalImage
                              ]) { [weak self] (result) in
            switch result {
                case .failure:
                    self?.foodImage.contentMode = .center
                case .success:
                    self?.foodImage.contentMode = .scaleAspectFill
            }
        }
    }
    
    private func convertMinutesToString(time: Int) -> String {
        guard time > 60 else { return "\(time.description)m" }
        let hours = time / 60
        let minutes = time % 60
        guard minutes > 0 else { return "\(hours)h" }
        return "\(hours)h \(minutes)m"
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


// MARK: - TraitCollection Methods
extension RecipeCollectionViewCell {
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        switch traitCollection.userInterfaceStyle {
            case .light:
                layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
            case .dark:
                layer.borderColor = #colorLiteral(red: 0.9764705896, green: 0.850980401, blue: 0.5490196347, alpha: 1)
            default:
                layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        }
    }
}
