//
//  ButtonStackView.swift
//  Nonas Box
//
//  Created by Jason Ruan on 12/13/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class ButtonStackView: UIStackView {
    
    // MARK: - Public Properties
    let bookmarkButton: UIButton
    let shoppingBagButton: UIButton
    let weblinkButton: UIButton
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        let bookmarkButton = UIButton(type: .system)
        bookmarkButton.tintColor = .systemRed
//        bookmarkButton.setTitle("Bookmark", for: .normal)
//        bookmarkButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.bookmarkButton = bookmarkButton
        
        let shoppingBagButton = UIButton(type: .system)
        shoppingBagButton.tintColor = TabBarItemType.shopping.colorScheme
        shoppingBagButton.setImage(UIImage(systemName: .bag), for: .normal)
        self.shoppingBagButton = shoppingBagButton
        
        let webLinkButton = UIButton(type: .system)
        webLinkButton.setImage(UIImage(systemName: "safari.fill"), for: .normal)
//        webLinkButton.setTitle("Source", for: .normal)
//        webLinkButton.titleLabel?.adjustsFontSizeToFitWidth = true
        self.weblinkButton = webLinkButton
        
        super.init(frame: frame)
        addArrangedSubview(bookmarkButton)
        addArrangedSubview(shoppingBagButton)
        addArrangedSubview(webLinkButton)
        
        axis = .horizontal
        distribution = .equalSpacing
        spacing = 30
    }
    
    required init(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
