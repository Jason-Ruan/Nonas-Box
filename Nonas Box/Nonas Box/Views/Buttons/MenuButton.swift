//
//  MenuButton.swift
//  Nonas Box
//
//  Created by Jason Ruan on 11/2/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

enum SymbolUnicodeScalar: String {
    case cardFileBox = "\u{1F5C3}"
    case bentoBox = "\u{1F371}"
    case iceCube = "\u{1F9CA}"
    case fryPan = "\u{1F373}"
    case fire = "\u{1F525}"
    case forkPlateKnife = "\u{1F37D}"
}

class MenuButton: UIButton {
    
    // MARK: - UI Objects
    lazy var unicodeScalarSymbolLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.makeFont(.arial, 80)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var menuTitleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.makeFont(.copperplate, 25)
        label.textAlignment = .center
        label.numberOfLines = 0
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Private Properties
    private let symbol: SymbolUnicodeScalar
    private let title: String
    
    // MARK: - Initializers
    init(symbol: SymbolUnicodeScalar, title: String, color: UIColor ) {
        self.symbol = symbol
        self.title = title
        
        super.init(frame: .zero)
        
        showsTouchWhenHighlighted = true
        backgroundColor = color
        layer.cornerRadius = 20
        layer.borderWidth = 2
        layer.borderColor = titleLabel?.textColor?.cgColor
        translatesAutoresizingMaskIntoConstraints = false
        
        setUpViews()
        configureViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Methods
    private func setUpViews() {
        addSubview(unicodeScalarSymbolLabel)
        NSLayoutConstraint.activate([
            unicodeScalarSymbolLabel.topAnchor.constraint(equalTo: safeAreaLayoutGuide.topAnchor, constant: 10),
            unicodeScalarSymbolLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor),
            unicodeScalarSymbolLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor),
            unicodeScalarSymbolLabel.heightAnchor.constraint(equalTo: safeAreaLayoutGuide.heightAnchor, multiplier: 0.6)
        ])
        
        addSubview(menuTitleLabel)
        NSLayoutConstraint.activate([
            menuTitleLabel.topAnchor.constraint(equalTo: unicodeScalarSymbolLabel.bottomAnchor),
            menuTitleLabel.leadingAnchor.constraint(equalTo: safeAreaLayoutGuide.leadingAnchor, constant: 5),
            menuTitleLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -5),
            menuTitleLabel.bottomAnchor.constraint(equalTo: safeAreaLayoutGuide.bottomAnchor, constant: -5)
        ])
    }
    
    private func configureViews() {
        unicodeScalarSymbolLabel.text = symbol.rawValue
        menuTitleLabel.text = title
    }
    
}
