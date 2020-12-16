//
//  BackgroundImageView.swift
//  Nonas Box
//
//  Created by Jason Ruan on 12/13/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class BackgroundImageView: UIImageView {
    
    // MARK: - Private Properties
    private let visualEffectView: UIVisualEffectView

    
    // MARK: - Initializers
    override init(frame: CGRect) {
        self.visualEffectView = UIVisualEffectView(frame: frame)
        super.init(frame: frame)
        contentMode = .scaleAspectFill
        clipsToBounds = true
        setUpVisualEffects()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func setUpVisualEffects() {
        addSubview(visualEffectView)
        let blurEffect = traitCollection.userInterfaceStyle == .dark ?
            UIBlurEffect(style: .dark) : UIBlurEffect(style: .systemThinMaterialLight)
        visualEffectView.effect = blurEffect
    }
    
}
