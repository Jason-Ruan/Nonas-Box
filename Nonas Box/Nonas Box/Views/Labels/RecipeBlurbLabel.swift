//
//  BlurbLabel.swift
//  Nonas Box
//
//  Created by Jason Ruan on 11/12/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class BlurbLabel: UILabel {
    
    init(title: String?, servings: Int?, readyInMinutes: Int?) {
        super.init(frame: .zero)
        textAlignment = .center
        attributedText = configureText(title: title, servings: servings, readyInMinutes: readyInMinutes)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureText(title: String?, servings: Int?, readyInMinutes: Int?) -> NSMutableAttributedString? {
        let recipeTitle = NSAttributedString(string: "\(title ?? "placeholder title")\n", attributes: [.font : UIFont.systemFont(ofSize: 20, weight: .bold)])
        let recipeServings = NSAttributedString(string: "\nServings: \(servings ?? 1)", attributes: [.font : UIFont.systemFont(ofSize: 14, weight: .light)])
        let recipeTime = NSAttributedString(string: "\nTime: \(readyInMinutes ?? 1) minutes", attributes: [.font : UIFont.systemFont(ofSize: 14, weight: .medium)])
        
        let summaryAttributedString = NSMutableAttributedString()
        summaryAttributedString.append(recipeTitle)
        summaryAttributedString.append(recipeServings)
        summaryAttributedString.append(recipeTime)
        
        return summaryAttributedString
    }
    
}
