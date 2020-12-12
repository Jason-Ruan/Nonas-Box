//
//  StepByStepInstructionsTableView.swift
//  Nonas Box
//
//  Created by Jason Ruan on 12/12/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class StepByStepInstructionsTableView: UIView {
    
    // MARK: UI Objects
    public lazy var underlinedSegmentedControl: UnderlinedSegmentedControl = {
        let underlinedSC = UnderlinedSegmentedControl(items: ["Ingredients", "Directions"])
        underlinedSC.segmentedControl.addTarget(self, action: #selector(jumpToSection), for: .valueChanged)
        return underlinedSC
    }()
    
    public lazy var tableView: UITableView = {
        let tv = UITableView(frame: .zero, style: .grouped)
        tv.backgroundColor = .clear
        tv.bounces = false
        tv.register(UITableViewCell.self, forCellReuseIdentifier: "ingredientCell")
        tv.register(StepByStepInstructionTableViewCell.self, forCellReuseIdentifier: StepByStepInstructionTableViewCell.identifier)
        return tv
    }()
    
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private Functions
    private func setUpViews() {
        addSubview(underlinedSegmentedControl)
        underlinedSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            underlinedSegmentedControl.topAnchor.constraint(equalTo: topAnchor),
            underlinedSegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlinedSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            underlinedSegmentedControl.heightAnchor.constraint(equalTo: heightAnchor, multiplier: 0.15)
        ])
        
        addSubview(tableView)
        tableView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            tableView.topAnchor.constraint(equalTo: underlinedSegmentedControl.bottomAnchor),
            tableView.leadingAnchor.constraint(equalTo: leadingAnchor),
            tableView.trailingAnchor.constraint(equalTo: trailingAnchor),
            tableView.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
    }
    
    
    // MARK: - Private ObjC Functions
    @objc
    private func jumpToSection() {
        tableView.scrollToRow(at: IndexPath(row: 0, section: underlinedSegmentedControl.segmentedControl.selectedSegmentIndex), at: .top, animated: true)
    }

}
