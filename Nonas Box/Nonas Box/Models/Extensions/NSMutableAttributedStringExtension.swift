//
//  NSMutableAttributedStringExtension.swift
//  Nonas Box
//
//  Created by Jason on 3/19/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import UIKit

extension NSMutableAttributedString {
    
    static func superscript(string: String) -> NSMutableAttributedString {
        return NSMutableAttributedString(string: string, attributes: [.font : UIFont.boldSystemFont(ofSize: 12)])
    }
    
}
