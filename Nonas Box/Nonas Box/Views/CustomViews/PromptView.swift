//
//  PromptView.swift
//  Nonas Box
//
//  Created by Jason Ruan on 3/10/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import UIKit

class PromptView: UIView {
    
    // MARK: UI Objects
    private lazy var imageView: UIImageView = {
        let iv = UIImageView()
        iv.tintColor = colorTheme
        iv.contentMode = .scaleAspectFill
        return iv
    }()
    
    private lazy var titleLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: titleFontSize)
        label.adjustsFontSizeToFitWidth = true
        label.textColor = colorTheme
        return label
    }()
    
    private lazy var messageLabel: UILabel = {
       let label = UILabel()
        label.textAlignment = .center
        label.font = UIFont.boldSystemFont(ofSize: messageFontSize)
        label.textColor = colorTheme
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        return label
    }()
    
    
    // MARK: - Private Properties
    private let titleFontSize: CGFloat = 45
    private let messageFontSize: CGFloat = 14
    private var colorTheme: UIColor!
    
    
    // MARK: - Initializers
    init(colorTheme: UIColor, image: UIImage, title: String?, message: String?) {
        self.colorTheme = colorTheme
        super.init(frame: .zero)
        setUpViews()
        configureViews(image: image, title: title, message: message)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MAARK: - Private Functions
    private func setUpViews() {
        addSubview(imageView)
        addSubview(titleLabel)
        addSubview(messageLabel)
        
        imageView.translatesAutoresizingMaskIntoConstraints = false
        titleLabel.translatesAutoresizingMaskIntoConstraints = false
        messageLabel.translatesAutoresizingMaskIntoConstraints = false
        
        NSLayoutConstraint.activate([
            imageView.topAnchor.constraint(equalTo: topAnchor),
            imageView.centerXAnchor.constraint(equalTo: centerXAnchor),
            imageView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33),
            imageView.heightAnchor.constraint(equalTo: imageView.widthAnchor)
        ])
        
        NSLayoutConstraint.activate([
            titleLabel.topAnchor.constraint(equalTo: imageView.bottomAnchor, constant: 5),
            titleLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            titleLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.75)
        ])
        
        NSLayoutConstraint.activate([
            messageLabel.topAnchor.constraint(equalTo: titleLabel.bottomAnchor),
            messageLabel.widthAnchor.constraint(equalTo: widthAnchor),
            messageLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            messageLabel.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    private func configureViews(image: UIImage, title: String?, message: String?) {
        imageView.image = image
        titleLabel.text = title
        messageLabel.text = message
    }
    
}
