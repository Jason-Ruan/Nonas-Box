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
        
        let foodInfoText = NSMutableAttributedString(string: "\(title)", attributes: [.font : UIFont(name: Fonts.optima.rawValue, size: 20)!])
        
        let image1TextAttachment = NSTextAttachment(image: UIImage(systemName: "person.2.fill")!)
        let image2TextAttachment = NSTextAttachment(image: UIImage(systemName: "clock.fill")!)
        let image1TextString = NSAttributedString(attachment: image1TextAttachment)
        let image2TextString = NSAttributedString(attachment: image2TextAttachment)
        
        let prepInfo = NSMutableAttributedString(string: "\n\n")
        
        if let servings = servings, let prepTime = readyInMinutes  {
            prepInfo.append(image1TextString)
            prepInfo.append(NSAttributedString(string: servings.description))
            prepInfo.append(NSAttributedString(string: "  |  "))
            prepInfo.append(image2TextString)
            prepInfo.append(convertMinutesToString(time: prepTime))
        }
        
        foodInfoText.append(prepInfo)
        attributedText = foodInfoText
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
