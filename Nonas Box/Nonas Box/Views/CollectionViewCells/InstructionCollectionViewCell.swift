//
//  InstructionCollectionViewCell.swift
//  Nonas Box
//
//  Created by Jason Ruan on 10/9/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class InstructionCollectionViewCell: UICollectionViewCell {
    
    // MARK: - UI Objects
    lazy var stepNumberLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var stepInstructionLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        addSubviews()
        constrainSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Properties
    private var stepInstruction: Step! {
        didSet{
            configureCell(forStep: stepInstruction)
        }
    }
    
    static var identifier: String {
        return String(describing: self)
    }
    
    // MARK: - Private Methods
    private func addSubviews() {
        contentView.addSubview(stepNumberLabel)
        contentView.addSubview(stepInstructionLabel)
    }
    
    private func constrainSubviews() {
        NSLayoutConstraint.activate([
            stepNumberLabel.topAnchor.constraint(equalTo: contentView.topAnchor),
            stepNumberLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stepNumberLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
        NSLayoutConstraint.activate([
            stepInstructionLabel.topAnchor.constraint(equalTo: stepNumberLabel.bottomAnchor),
            stepInstructionLabel.leadingAnchor.constraint(equalTo: contentView.leadingAnchor),
            stepInstructionLabel.trailingAnchor.constraint(equalTo: contentView.trailingAnchor),
        ])
        
    }
    
    private func configureCell(forStep step: Step) {
        guard let stepInstruction = step.instruction, let stepNumber = step.number else { return }
        stepNumberLabel.text = "STEP \(stepNumber)"
        stepInstructionLabel.text = stepInstruction
    }
    
    
}
