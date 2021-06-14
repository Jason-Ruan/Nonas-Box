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
        return NSMutableAttributedString(string: string, attributes: [.font: UIFont.boldSystemFont(ofSize: 12)])
    }
    
    func appendImageAsText(systemName: SystemImageNames) {
        guard let image = UIImage(systemName: systemName) else { return }
        let imageTextAttachmentString = NSAttributedString(attachment: NSTextAttachment(image: image))
        self.append(imageTextAttachmentString)
    }
    
    func appendLineBreaks(_ count: Int?) {
        self.append(NSAttributedString(string: String(repeating: "\n", count: count ?? 1)))
    }
    
    func appendString(string: String, attributes: [NSAttributedString.Key: Any]? = nil) {
        self.append(NSAttributedString(string: string, attributes: attributes))
    }
}
