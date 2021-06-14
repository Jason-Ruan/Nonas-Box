//
//  Fonts.swift
//  Nonas Box
//
//  Created by Jason Ruan on 1/10/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import UIKit

enum Fonts: String {
    case arial
    case avenir
    case circular
    case chalkduster
    case chalkboard
    case copperplate
    case courier
    case handwriting
    case tamil
    case wideMarker
    case optima
    
    var fontName: String {
        switch self {
        case .chalkboard:       return "ChalkboardSE"
        case .handwriting:      return "BradleyHandITCTT-Bold"
        case .tamil:            return "TamilSangamMN"
        case .wideMarker:       return "MarkerFelt-Wide"
        default:                return rawValue.capitalized
        }
    }
    
    var isUnique: Bool {
        switch self {
        case .handwriting, .wideMarker:     return true
        default:                           return false
        }
    }
}

enum FontWeight: String {
    case bold = "-Bold"
    case boldItalic = "-BoldItalic"
    case condensedBlack = "-CondensedBlack"
    case condensedBold = "-CondensedBold"
    case italic = "-Italic"
    case light = "-Light"
    case lightItalic = "-LightItalic"
    case medium = "-Medium"
    case ultraLight = "-UltraLight"
    case ultraLightItalic = "-UltraLightItalic"
}
