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
        view.backgroundColor = #colorLiteral(red: 0.09753478318, green: 0.0969626084, blue: 0.09797952324, alpha: 0.8515625)
        view.layer.cornerRadius = 25
        view.layer.borderWidth = 1
        view.layer.borderColor = UIColor.systemGray3.cgColor
        return view
    }()
    
    private lazy var loadingIndicatorView: UIActivityIndicatorView = {
        let spinner = UIActivityIndicatorView(style: .large)
        spinner.color = .white
        spinner.hidesWhenStopped = true
        return spinner
    }()
    
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = .systemBackground
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
            loadingBackgroundView.centerYAnchor.constraint(equalTo: safeAreaLayoutGuide.centerYAnchor),
            loadingBackgroundView.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.25),
            loadingBackgroundView.heightAnchor.constraint(equalTo: loadingBackgroundView.widthAnchor)
        ])
        
        loadingBackgroundView.addSubview(loadingIndicatorView)
        loadingIndicatorView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            loadingIndicatorView.centerXAnchor.constraint(equalTo: loadingBackgroundView.centerXAnchor),
            loadingIndicatorView.centerYAnchor.constraint(equalTo: loadingBackgroundView.centerYAnchor),
        ])
    }
    
}
