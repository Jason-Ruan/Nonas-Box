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
        button.addTarget(self, action: #selector(showMessage), for: .touchUpInside)
        return button
    }()
    
    private lazy var nameLabel: UILabel = {
        return UILabel(fontName: .tamil, fontSize: 16, alignment: .left)
    }()
    
    private lazy var measurementLabel: UILabel = {
        return UILabel(fontName: .tamil, fontSize: 16, fontWeight: .bold, alignment: .right)
    }()
    
    
    // MARK: - Properties
    var measurementSystem: MeasurementSystem?
    var ingredient: Ingredient? {
        didSet {
            guard let ingredient = ingredient else { return }
            configureViews(forIngredient: ingredient)
        }
    }
    
    weak var delegate: UIViewController?
    
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
            measurementLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
            measurementLabel.widthAnchor.constraint(equalTo: contentView.widthAnchor, multiplier: 0.23)
        ])

        contentView.addSubview(nameLabel)
        nameLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
            nameLabel.leadingAnchor.constraint(equalTo: checklistButton.trailingAnchor, constant: 12),
            nameLabel.trailingAnchor.constraint(equalTo: measurementLabel.leadingAnchor)
        ])
        
//            contentView.addSubview(measurementLabel)
//            measurementLabel.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                measurementLabel.topAnchor.constraint(equalTo: contentView.topAnchor, constant: 15),
//                measurementLabel.bottomAnchor.constraint(equalTo: contentView.bottomAnchor, constant: -15),
//                measurementLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor)
//            ])
//
//            contentView.addSubview(nameLabel)
//            nameLabel.translatesAutoresizingMaskIntoConstraints = false
//            NSLayoutConstraint.activate([
//                nameLabel.centerYAnchor.constraint(equalTo: contentView.centerYAnchor),
//                nameLabel.leadingAnchor.constraint(equalTo: checklistButton.trailingAnchor, constant: 20),
//                nameLabel.trailingAnchor.constraint(equalTo: measurementLabel.leadingAnchor)
//            ])
        
    }
    
    private func configureViews(forIngredient ingredient: Ingredient) {
        nameLabel.text = ingredient.name?.capitalized
        measurementLabel.text = measurementSystem == .usa ? ingredient.measures.us.shortHandMeasurement : ingredient.measures.metric.shortHandMeasurement
    }
    
    @objc func showMessage() {
        guard let ingredientName = ingredient?.name?.capitalized, let delegate = delegate else { return }
        delegate.showAlertWithAutoDismiss(title: nil, message: "'\(ingredientName)' was added to your shopping list.")
    }
    
}
