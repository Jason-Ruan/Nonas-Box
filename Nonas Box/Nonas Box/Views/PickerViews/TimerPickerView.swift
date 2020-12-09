//
//  TimerPickerView.swift
//  Nonas Box
//
//  Created by Jason Ruan on 12/8/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

import UIKit

class TimerPickerView: UIPickerView {
    
    // MARK: - Properties
    private lazy var hourLabel: UILabel = { unitLabel() }()
    private lazy var minLabel: UILabel = { unitLabel() }()
    private lazy var secLabel: UILabel = { unitLabel() }()
    
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        tintColor = .systemGray4
        backgroundColor = .clear
        setUpViews()
        configureLabelsText()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    

    // MARK: - Private Functions
    private func setUpViews() {
        insertSubview(hourLabel, at: 0)
        hourLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            hourLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            hourLabel.leadingAnchor.constraint(equalTo: leadingAnchor),
            hourLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33)
        ])
        
        insertSubview(minLabel, at: 0)
        minLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            minLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            minLabel.centerXAnchor.constraint(equalTo: centerXAnchor),
            minLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33)
        ])
        
        insertSubview(secLabel, at: 0)
        secLabel.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            secLabel.centerYAnchor.constraint(equalTo: centerYAnchor),
            secLabel.trailingAnchor.constraint(equalTo: safeAreaLayoutGuide.trailingAnchor, constant: -20),
            secLabel.widthAnchor.constraint(equalTo: widthAnchor, multiplier: 0.33)
        ])
    }
    
    private func configureLabelsText() {
        hourLabel.text = "hr"
        minLabel.text = "min"
        secLabel.text = "s"
    }
    
    private func unitLabel() -> UILabel {
        let unitLabel: UILabel = UILabel()
        unitLabel.textAlignment = .right
        unitLabel.textColor = .systemBlue
        return unitLabel
    }
    
}
