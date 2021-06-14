//
//  UIFont+.swift
//  Nonas Box
//
//  Created by Jason Ruan on 6/14/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import UIKit

extension UIFont {
    static func makeFont(_ font: Fonts, _ size: CGFloat, _ fontWeight: FontWeight? = nil) -> UIFont {
        var fontName = font.fontName
        if fontWeight != nil && !font.isUnique {
            fontName.append(fontWeight!.rawValue)
        }
        return UIFont(name: fontName, size: size) ?? UIFont.boldSystemFont(ofSize: size)
    }
}
