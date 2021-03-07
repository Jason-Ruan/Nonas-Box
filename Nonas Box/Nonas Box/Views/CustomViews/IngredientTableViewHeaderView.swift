//
//  IngredientTableViewHeaderView.swift
//  Nonas Box
//
//  Created by Jason Ruan on 3/5/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import UIKit

class IngredientTableViewHeaderView: UITableViewHeaderFooterView {
    // MARK: - UI Objects
    private lazy var stackView: UIStackView = {
        let stackView = UIStackView(arrangedSubviews: [worldButton, usaButton])
        stackView.axis = .horizontal
        stackView.distribution = .fillEqually
        return stackView
    }()
    
    private lazy var usaButton: UIButton = {
        let usaButton = UIButton()
        usaButton.setTitle("🇺🇸", for: .normal)
        usaButton.showsTouchWhenHighlighted = true
        usaButton.layer.borderWidth = 1.5
        usaButton.layer.borderColor = UIColor.clear.cgColor
        usaButton.addTarget(self, action: #selector(changeSelectedButton(button:)), for: .touchUpInside)
        return usaButton
    }()
    
    private lazy var worldButton: UIButton = {
        let worldButton = UIButton()
        worldButton.setTitle("\u{1F310}", for: .normal)
        worldButton.showsTouchWhenHighlighted = true
        worldButton.layer.borderWidth = 1.5
        worldButton.layer.borderColor = UIColor.clear.cgColor
        worldButton.addTarget(self, action: #selector(changeSelectedButton(button:)), for: .touchUpInside)
        return worldButton
    }()
    
    // MARK: - Public Properties
    weak var delegate: TogglableMeasurementSystem?
    
    
    // MARK: - Private Properties
    private let highlightedBorderColor = UIColor.systemBlue.cgColor
    private var selectedButton: UIButton? {
        willSet {
            selectedButton?.layer.borderColor = UIColor.clear.cgColor
        }
        
        didSet {
            selectedButton?.layer.borderColor = highlightedBorderColor
        }
    }
    
    
    // MARK: - Initializers
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
   
    override func layoutSubviews() {
        super.layoutSubviews()
        selectedButton = usaButton
    }
    
    // MARK: - Private Functions
    private func configureSubviews() {
        addSubview(stackView)
        stackView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            stackView.trailingAnchor.constraint(equalTo: trailingAnchor),
            stackView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -5),
            stackView.topAnchor.constraint(equalTo: topAnchor),
            stackView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.2)
        ])
    }
    
    private func toggleMeasurementSystem() {
        if selectedButton == usaButton {
            delegate?.useAmericanMeasurementSystem()
        } else {
            delegate?.useMetricSystem()
        }
    }
    
    
    // MARK: - Private Objc Functions
    @objc private func changeSelectedButton(button: UIButton) {
        selectedButton = button == usaButton ? usaButton : worldButton
        toggleMeasurementSystem()
    }
    
    
    // MARK: - ReuseIdentifier
    static var reuseIdentifier: String {
        return String(describing: self)
    }
}
