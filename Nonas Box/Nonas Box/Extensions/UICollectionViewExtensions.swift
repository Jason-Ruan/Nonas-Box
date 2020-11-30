//
//  UICollectionViewExtensions.swift
//  Nonas Box
//
//  Created by Jason Ruan on 11/29/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

public extension UICollectionView {
    // MARK: - Initializers
    convenience init(scrollDirection: UICollectionView.ScrollDirection,
                     scrollIndicatorsIsVisible: Bool) {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        layout.minimumInteritemSpacing = 5
        layout.minimumLineSpacing = 5
        
        self.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        
        switch scrollDirection {
            case .horizontal:
                showsHorizontalScrollIndicator = scrollIndicatorsIsVisible
            case .vertical:
                showsVerticalScrollIndicator = scrollIndicatorsIsVisible
            default:
                return
        }
    }
    
}
