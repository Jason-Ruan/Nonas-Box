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
                              font: UIFont? = nil,
                              alignment: NSTextAlignment? = .natural) {
        
        self.init()
        
        textAlignment = alignment ?? .natural
        numberOfLines = numLines ?? 0
        adjustsFontSizeToFitWidth = true
        text = textString
        self.font = font
    }
}
