//
//  StepByStepInstructionTableViewCell.swift
//  Nonas Box
//
//  Created by Jason Ruan on 10/18/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class StepByStepInstructionTableViewCell: UITableViewCell {
    
    // MARK: - Initializers
    override init(style: UITableViewCell.CellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        addSubviews()
        selectionStyle = .none
        backgroundColor = .clear
        
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Properties
    var step: Step? {
        didSet {
            guard let stepInstruction = step else { return }
            configureCell(step: stepInstruction)
        }
    }
    
    
    // MARK: - UI Objects
    lazy var stepNumberLabel: UILabel = {
        let label = UILabel()
        label.textColor = .orange
        label.textAlignment = .center
        //        label.font = UIFont(name: "Chalkduster-Bold", size: 30)
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var stepInstructionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont(name: "Avenir", size: 16)
        label.numberOfLines = 0
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    
    // MARK: - Private Functions
    private func addSubviews() {
        contentView.addSubview(stepNumberLabel)
        NSLayoutConstraint.activate([
            stepNumberLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor),
            stepNumberLabel.leadingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.leadingAnchor),
            stepNumberLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor),
            stepNumberLabel.widthAnchor.constraint(equalToConstant: contentView.safeAreaLayoutGuide.layoutFrame.width / 6)
        ])
        
        contentView.addSubview(stepInstructionLabel)
        NSLayoutConstraint.activate([
            stepInstructionLabel.topAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.topAnchor, constant: 10),
            stepInstructionLabel.leadingAnchor.constraint(equalTo: stepNumberLabel.trailingAnchor),
            stepInstructionLabel.trailingAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.trailingAnchor),
            stepInstructionLabel.bottomAnchor.constraint(equalTo: contentView.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    private func configureCell(step: Step) {
        if let stepNumber = step.number?.description {
            let num = NSAttributedString(string: stepNumber, attributes:
                [   NSAttributedString.Key.foregroundColor : UIColor.orange,
                    NSAttributedString.Key.strokeColor : UIColor.black,
                    NSAttributedString.Key.strokeWidth : -0.2,
                    NSAttributedString.Key.font : UIFont(name: "Courier", size: 30)!
                ])
        
            stepNumberLabel.attributedText = num
        }
        
        stepInstructionLabel.text = step.step?.description
    }
    
}
