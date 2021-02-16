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
                     spacing: CGFloat,
                     scrollIndicatorsIsVisible: Bool,
                     shouldInset: Bool) {
        
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = scrollDirection
        layout.minimumInteritemSpacing = spacing
        layout.minimumLineSpacing = spacing
        if shouldInset {
            layout.sectionInset = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        }
        
        self.init(frame: .zero, collectionViewLayout: layout)
        
        backgroundColor = .clear
        
        if shouldInset {
            contentInset = UIEdgeInsets(top: 10, left: 10, bottom: 10, right: 10)
        }
        
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
