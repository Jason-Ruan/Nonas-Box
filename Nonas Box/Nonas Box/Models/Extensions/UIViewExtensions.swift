//
//  UIViewExtensions.swift
//  Nonas Box
//
//  Created by Jason Ruan on 2/3/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import UIKit

extension UIView {
    func setUpViews(_ subviews: [UIView]) {
        subviews.forEach {
            addSubview($0)
            $0.translatesAutoresizingMaskIntoConstraints = false
        }
    }
    
    func addGradientLayer(colors: [UIColor]) {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = colors.map { $0.cgColor }
        gradientLayer.frame = frame
        layer.addSublayer(gradientLayer)
    }

}
