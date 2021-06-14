//
//  BarcodeScanView.swift
//  Nonas Box
//
//  Created by Jason Ruan on 12/17/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class BarcodeScanView: UIView {
    
    // MARK: - Initializers
    init() {
        super.init(frame: .zero)
        layer.cornerRadius = 25
        configureInnerViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Functions
    private func configureInnerViews() {
        let windowView = UIView()
        windowView.layer.borderWidth = 2
        windowView.layer.borderColor = UIColor.white.cgColor
        windowView.backgroundColor = .clear
        windowView.translatesAutoresizingMaskIntoConstraints = false
        
        addSubview(windowView)
        NSLayoutConstraint.activate([
            windowView.topAnchor.constraint(equalTo: topAnchor, constant: 30),
            windowView.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -30),
            windowView.leadingAnchor.constraint(equalTo: leadingAnchor, constant: 30),
            windowView.trailingAnchor.constraint(equalTo: trailingAnchor, constant: -30)
        ])
    }
    
}
