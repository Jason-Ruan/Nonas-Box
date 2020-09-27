//
//  RecipeCollectionViewCell.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/10/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class RecipeCollectionViewCell: UICollectionViewCell {
    
    //MARK: - UI Objects
    
    lazy var foodImage: UIImageView = {
        let iv = UIImageView()
        iv.clipsToBounds = true
        iv.contentMode = .scaleAspectFill
        iv.layer.cornerRadius = 25
        iv.layer.borderWidth = 3
        iv.layer.borderColor = #colorLiteral(red: 0.1411764771, green: 0.3960784376, blue: 0.5647059083, alpha: 1)
        iv.backgroundColor = .clear
        iv.translatesAutoresizingMaskIntoConstraints = false
        return iv
    }()
    
    lazy var foodInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.backgroundColor = #colorLiteral(red: 0.2295365632, green: 0.2428716421, blue: 0.2767262459, alpha: 0.2997913099)
        label.layer.cornerRadius = 25
        label.textColor = #colorLiteral(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //    lazy var favoriteButton: UIButton = {
    //       let button = UIButton()
    //        button.imageView?.contentMode = .scaleAspectFill
    //        button.setBackgroundImage(UIImage(systemName: "heart"), for: .normal)
    //        button.addTarget(self, action: #selector(self.favoriteButtonPressed), for: .touchUpInside)
    //        button.translatesAutoresizingMaskIntoConstraints = false
    //        return button
    //    }()
    
    lazy var spinner: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: UIActivityIndicatorView.Style.medium)
        spinner.translatesAutoresizingMaskIntoConstraints = false
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    //MARK: - Properties
    
    var recipe: Recipe! {
        didSet {
            guard let recipe = self.recipe else { return }
            configureCell(recipe: recipe)
        }
    }
    
    
    //MARK: - Initializers
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        layer.borderWidth = 2
        layer.borderColor = #colorLiteral(red: 0.2392156869, green: 0.6745098233, blue: 0.9686274529, alpha: 1)
        layer.cornerRadius = 25
        layer.shadowColor = UIColor.black.cgColor
        layer.shadowOpacity = 0.2
        layer.shadowOffset = CGSize(width: 5, height: 3.0)
        layer.shadowRadius = 3
        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 25).cgPath
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
        
        //        contentView.addSubview(favoriteButton)
        //        NSLayoutConstraint.activate([
        //            favoriteButton.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 20),
        //            favoriteButton.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor, constant: -20),
        //            favoriteButton.heightAnchor.constraint(equalToConstant: 30),
        //            favoriteButton.widthAnchor.constraint(equalToConstant: 30)
        //        ])
        
        foodImage.addSubview(spinner)
        NSLayoutConstraint.activate([
            spinner.centerXAnchor.constraint(equalTo: foodImage.centerXAnchor),
            spinner.centerYAnchor.constraint(equalTo: foodImage.centerYAnchor)
        ])
        
    }
    
    private func configureCell(recipe: Recipe) {
        foodImage.image = nil
        self.spinner.startAnimating()
        
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
        SpoonacularAPIClient.manager.getImage(recipe: recipe) { (result) in
            switch result {
                case .failure(let error):
                    self.foodImage.image = UIImage(systemName: "xmark.rectangle.fill")!
                    print(error)
                case .success(let image):
                    if recipe.imageURL == self.recipe?.imageURL {
                        self.foodImage.image = image
                    } else {
                        self.loadImage(recipe: self.recipe)
                }
            }
            self.spinner.stopAnimating()
        }
    }
    
    private func convertMinutesToString(time: Int) -> String {
        guard time > 60 else { return "\(time.description) min" }
        let hours = time / 60
        let minutes = time % 60
        guard minutes > 0 else { return "\(hours) \(hours > 1 ? "hrs" : "hr")" }
        return "\(hours) \(hours > 1 ? "hrs" : "hr") \(minutes) min"
    }
    
    //    @objc private func favoriteButtonPressed() {}
    
    
}
