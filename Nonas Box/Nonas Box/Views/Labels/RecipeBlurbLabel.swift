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
        guard let title = title else { return }
        let blurbText = NSMutableAttributedString()
        
        blurbText.appendString(string: title, attributes: [.font: UIFont.makeFont(.optima, 20)])
        blurbText.appendLineBreaks(2)
        
        if let servings = servings, let prepTime = readyInMinutes {
            blurbText.appendImageAsText(systemName: .twoPersonFill)
            blurbText.appendString(string: servings.description)
            blurbText.appendString(string: "  |  ")
            blurbText.appendImageAsText(systemName: .clockFill)
            blurbText.append(convertMinutesToString(time: prepTime))
        }
        
        attributedText = blurbText
    }
    
    private func convertMinutesToString(time: Int) -> NSMutableAttributedString {
        guard time > 60 else {
            let timeString: NSMutableAttributedString = NSMutableAttributedString(string: time.description)
            timeString.append(NSMutableAttributedString.superscript(string: "min"))
            return timeString
        }
        
        let hours = time / 60
        let minutes = time % 60
        
        let timeString: NSMutableAttributedString = NSMutableAttributedString(string: hours.description)
        timeString.append(NSMutableAttributedString.superscript(string: hours > 1 ? "hrs" : "hr"))
        
        guard minutes > 0 else {
            return timeString
        }
        
        timeString.append(NSAttributedString(string: " \(minutes)"))
        timeString.append(NSMutableAttributedString.superscript(string: "min"))
        
        return timeString
    }
}
