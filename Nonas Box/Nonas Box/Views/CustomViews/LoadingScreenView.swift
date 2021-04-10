//
//  LoadingScreenView.swift
//  Nonas Box
//
//  Created by Jason Ruan on 12/10/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class LoadingScreenView: UIView {

    // MARK: - UI Objects
    private lazy var loadingBackgroundView: UIView = {
        let view = UIView()
        view.backgroundColor = #colorLiteral(red: 0.09753478318, green: 0.0969626084, blue: 0.09797952324, alpha: 0.8475374388)
        view.layer.cornerRadius = 20
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray3.cgColor
        return view
    }()
    
    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = #colorLiteral(red: 1, green: 0.687940836, blue: 0.5207877159, alpha: 1)
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    private lazy var textLabel: UILabel = {
       let label = UILabel()
        label.text = "LOADING"
        label.font = UIFont.boldSystemFont(ofSize: 12)
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    
    // MARK: - Initializers
    init(frame: CGRect, blockBackgroundViews: Bool) {
        super.init(frame: frame)
        backgroundColor = blockBackgroundViews ? .systemBackground : .clear
        configureLoadingScreenView()
        loadingIndicatorView.startAnimating()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private Functions
    private func configureLoadingScreenView() {
        addSubview(loadingBackgroundView)
        loadingBackgroundView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingBackgroundView.centerXAnchor.constraint(equalTo: centerXAnchor),
            loadingBackgroundView.centerYAnchor.constraint(equalTo: centerYAnchor),
            loadingBackgroundView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            loadingBackgroundView.heightAnchor.constraint(equalTo: loadingBackgroundView.widthAnchor)
        ])
        
        loadingBackgroundView.addSubview(loadingIndicatorView)
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicatorView.centerXAnchor.constraint(equalTo: loadingBackgroundView.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: loadingBackgroundView.centerYAnchor),
        ])
        
        loadingBackgroundView.addSubview(textLabel)
        textLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            textLabel.bottomAnchor.constraint(equalTo: loadingBackgroundView.bottomAnchor, constant: -5),
            textLabel.centerXAnchor.constraint(equalTo: loadingBackgroundView.centerXAnchor),
            textLabel.topAnchor.constraint(equalTo: loadingIndicatorView.bottomAnchor, constant: 5)
        ])
    }
    
}
