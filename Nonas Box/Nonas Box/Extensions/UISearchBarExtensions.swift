//
//  UISearchBarExtensions.swift
//  Nonas Box
//
//  Created by Jason Ruan on 12/12/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

extension UISearchBar {
    
    convenience init(placeHolderText: String) {
        self.init()
        placeholder = placeHolderText
        searchBarStyle = .minimal
    }
}
