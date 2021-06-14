//
//  IngredientTableViewCell.swift
//  Nonas Box
//
//  Created by Jason Ruan on 2/21/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import UIKit

class IngredientTableViewCell: UITableViewCell {
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        selectionStyle = .none
        backgroundColor = .clear
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lazy Variables
    private lazy var checklistButton: UIButton = {
        let button = UIButton(type: .contactAdd)
        button.addTarget(self, action: #selector(checklistButtonPressed), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        return UILabel(font: UIFont.makeFont(.tamil, 16),
                       alignment: .left)
    }()
    
    private lazy var measurementLabel: UILabel = {
        return UILabel(font: UIFont.makeFont(.tamil, 16, .bold),
                       alignment: .right)
    }()
    
    // MARK: - Properties
    var measurementSystem: MeasurementSystem?
    var ingredient: Ingredient? {
        didSet {
            guard let ingredient = ingredient else { return }
            configureViews(forIngredient: ingredient)
        }
    }
    
    weak var delegate: AlertMessengerDelegate?
    
    static var reuseIdentifier: String {
        return String(describing: self)
    }
    
    // MARK: - Private Functions
    private func setUpViews() {
        contentView.addSubview(checklistButton)
        checklistButton.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            checklistButton.leadingAnchor.constraint(equalTo: contentView.leadingAnchor, constant: 10),
            checklistButton.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            checklistButton.widthAnchor.constraint(equalToConstant: 25),
            checklistButton.heightAnchor.constraint(equalTo: checklistButton.widthAnchor)
        ])
        
        contentView.addSubview(measurementLabel)
        measurementLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            measurementLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
            measurementLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
            measurementLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor, constant: -15),
            measurementLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.23)
        ])
        
        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: checklistButton.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: measurementLabel.leadingAnchor)
        ])
    }
    
    private func configureViews(forIngredient ingredient: Ingredient) {
        nameLabel.text = ingredient.name?.capitalized
        measurementLabel.text = measurementSystem == .usa ? ingredient.measures.us.shortHandMeasurement : ingredient.measures.metric.shortHandMeasurement
    }
    
    @objc func checklistButtonPressed() {
        guard let ingredientName = ingredient?.name?.capitalized, let delegate = delegate else { return }
        if let shoppingItem = ShoppingItem(itemName: ingredientName,
                                           itemQuantity: ingredient?.measures.us.amount,
                                           itemUnit: ingredient?.measures.us.fullMeasurement,
                                           imageURL: ingredient?.imageURL) {
            
            guard !ShoppingItemPersistenceHelper.manager.contains(item: shoppingItem) else {
                do {
                    try ShoppingItemPersistenceHelper.manager.delete(key: ingredientName)
                    delegate.showAutoDismissingAlert(title: nil, message: "'\(ingredientName)' was removed from your shopping list.")
                    checklistButton.setImage(UIImage(systemName: .plusCircle), for: .normal)
                    checklistButton.tintColor = .systemBlue
                } catch {
                    delegate.showAutoDismissingAlert(title: "Oops!", message: "Looks like there was a problem trying to edit \(ingredientName) your shopping list.")
                    print(error)
                }
                return
            }
            
            do {
                try ShoppingItemPersistenceHelper.manager.save(key: ingredientName, item: shoppingItem)
                delegate.showAutoDismissingAlert(title: nil, message: "'\(ingredientName)' was added to your shopping list.")
                checklistButton.setImage(UIImage(systemName: .minusCircle), for: .normal)
                checklistButton.tintColor = .lightGray
            } catch {
                delegate.showAutoDismissingAlert(title: "Oops!", message: "Looks like there was a problem trying to edit \(ingredientName) your shopping list.")
                print(error)
            }
        }
    }
    
}
