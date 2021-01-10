//
//  RecipeBlurbLabel.swift
//  Nonas Box
//
//  Created by Jason Ruan on 11/12/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class RecipeBlurbLabel: UILabel {
    
    // MARK: Initializers
    init() {
        super.init(frame: .zero)
        textAlignment = .center
        numberOfLines = 0
        adjustsFontSizeToFitWidth = true
        minimumScaleFactor = 0.5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Public Functions
    public func configureAttributedText(title: String?, servings: Int?, readyInMinutes: Int?) {
        let recipeTitle = NSAttributedString(string: "\n\(title ?? "placeholder title")\n", attributes: [.font : UIFont.systemFont(ofSize: 20, weight: .bold)])
        let recipeServings = NSAttributedString(string: "\nServings: \(servings ?? 1)", attributes: [.font : UIFont.systemFont(ofSize: 14, weight: .medium)])
        let recipeTime = NSAttributedString(string: "\nTime: \(formatMinutesToString(minutes: readyInMinutes ?? 1))\n", attributes: [.font : UIFont.systemFont(ofSize: 14, weight: .semibold)])
        
        let summaryAttributedString = NSMutableAttributedString()
        summaryAttributedString.append(recipeTitle)
        summaryAttributedString.append(recipeServings)
        summaryAttributedString.append(recipeTime)
        
        attributedText = summaryAttributedString
    }
    
    private func formatMinutesToString(minutes: Int) -> String {
        let numHours = minutes / 60
        let numMinutes = minutes % 60
        
        if numHours == 1 {
            return "1 hour\(numMinutes > 0 ? ", \(numMinutes) minutes" : "")"
        } else if numHours > 1 {
            return "\(numHours) hours\(numMinutes > 0 ? ", \(numMinutes) minutes" : "")"
        } else {
            return "\(minutes) minutes"
        }
    }
    
}
