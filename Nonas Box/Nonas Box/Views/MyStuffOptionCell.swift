//
//  MyStuffOptionCell.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/31/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class MyStuffOptionCollectionViewCell: UICollectionViewCell {
    
    //MARK: - UI Objects
//    private lazy var button: UIButton = {
//        let button = UIButton(type: .roundedRect)
//        button.titleLabel?.adjustsFontForContentSizeCategory = true
//        button.titleLabel?.adjustsFontSizeToFitWidth = true
//        button.titleLabel?.font = UIFont(name: "Thonburi", size: 30)
//        layer.borderWidth = 3
//        layer.borderColor = #colorLiteral(red: 0, green: 0, blue: 0, alpha: 1)
//        layer.shadowColor = UIColor.black.cgColor
//        layer.shadowOpacity = 0.5
//        layer.shadowOffset = CGSize(width: 0, height: 1.0)
//        layer.shadowRadius = 5
//        layer.shadowPath = UIBezierPath(roundedRect: bounds, cornerRadius: 25).cgPath
//        button.addTarget(self, action: #selector(self.navigateToCorrespondingFeatureVC), for: .touchUpInside)
//        return button
//    }()
    
    private lazy var buttonLabel: UILabel = {
        let label = UILabel(frame: self.bounds)
        label.adjustsFontSizeToFitWidth = true
        label.numberOfLines = 0
        label.font = UIFont(name: "Thonburi", size: 30)
        label.textAlignment = .center
        label.textColor = #colorLiteral(red: 0.1901198924, green: 0.45225209, blue: 0.8538054824, alpha: 0.696088399)
        return label
    }()
    
    //MARK: - Properties
    var myStuffButtonOption: MyStuffButtonOptions! {
        didSet {
            configureCell(myStuffButtonOption: self.myStuffButtonOption.rawValue)
        }
    }
    
    //MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.backgroundColor = .white
        self.layer.cornerRadius = 25
        self.layer.borderWidth = 3
        self.layer.borderColor = #colorLiteral(red: 0.3385839164, green: 0.9114860296, blue: 1, alpha: 0.5)
        self.layer.masksToBounds = true
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    //MARK: - Private Functions
    private func setUpViews() {
        self.addSubview(buttonLabel)
    }
    
    private func configureCell(myStuffButtonOption: String) {
//        button.setTitle(myStuffButtonOption.description, for: .normal)
        buttonLabel.text = self.myStuffButtonOption.rawValue
    }
    
}

