//
//  UILabelExtensions.swift
//  Nonas Box
//
//  Created by Jason Ruan on 11/29/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

public extension UILabel {
    
    // MARK: - Iniitializers
    internal convenience init(text textString: String? = nil,
                     numLines: Int? = nil,
                     fontName: Fonts? = nil,
                     fontSize: CGFloat? = nil,
                     alignment: NSTextAlignment? = .natural) {
        
        self.init()
    
        textAlignment = alignment ?? .natural
        numberOfLines = numLines ?? 0
        adjustsFontSizeToFitWidth = true
        text = textString
        
        if let fontName = fontName, let fontSize = fontSize {
            font = UIFont(name: fontName.rawValue, size: fontSize)
        }
    }
}

