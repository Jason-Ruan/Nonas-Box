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
        underlinedSC.segmentedControl.layer.borderWidth = 0.25
        underlinedSC.segmentedControl.layer.borderColor = UIColor.lightGray.cgColor
        underlinedSC.segmentedControl.layer.maskedCorners = [.layerMinXMinYCorner, .layerMaxXMinYCorner]
        underlinedSC.segmentedControl.backgroundColor = #colorLiteral(red: 0.388763821, green: 0.388763821, blue: 0.388763821, alpha: 0.2483729148)
        return underlinedSC
    }()
    
    public lazy var tableView: UITableView = {
        let tableView = UITableView(frame: .zero, style: .grouped)
        tableView.backgroundColor = .clear
        tableView.layer.borderWidth = 0.25
        tableView.layer.borderColor = UIColor.lightGray.cgColor
        tableView.bounces = false
        tableView.register(IngredientTableViewCell.self, forCellReuseIdentifier: IngredientTableViewCell.reuseIdentifier)
        tableView.register(StepByStepInstructionTableViewCell.self, forCellReuseIdentifier: StepByStepInstructionTableViewCell.identifier)
        return tableView
    }()
    
    // MARK: - Initializers
    override init(frame: CGRect) {
        super.init(frame: frame)
        setUpViews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Public Properties
    public var numIngredients: Int? {
        didSet {
            underlinedSegmentedControl.segmentedControl.setTitle("Ingredients  (\(numIngredients ?? 0))", forSegmentAt: 0)
        }
    }
    
    weak var delegate: UITableViewDelegate? {
        didSet {
            guard let delegate = delegate else { return }
            tableView.delegate = delegate
        }
    }
    
    weak var dataSource: UITableViewDataSource? {
        didSet {
            guard let dataSource = dataSource else { return }
            tableView.dataSource = dataSource
        }
    }
    
    // MARK: - Public Functions
    public func reloadData() {
        tableView.reloadData()
    }
    
    public func reloadRows(at indexPaths: [IndexPath], with animation: UITableView.RowAnimation) {
        tableView.reloadRows(at: indexPaths, with: animation)
    }
    
    // MARK: - Private Functions
    private func setUpViews() {
        addSubview(underlinedSegmentedControl)
        underlinedSegmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            underlinedSegmentedControl.topAnchor.constraint(equalTo: topAnchor),
            underlinedSegmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            underlinedSegmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            underlinedSegmentedControl.heightAnchor.constraint(equalToConstant: 40)
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
        guard tableView.numberOfSections > underlinedSegmentedControl.segmentedControl.selectedSegmentIndex,
              tableView.numberOfRows(inSection: underlinedSegmentedControl.segmentedControl.selectedSegmentIndex) > 0 else { return }
        tableView.scrollToRow(at: IndexPath(row: 0, section: underlinedSegmentedControl.segmentedControl.selectedSegmentIndex), at: .top, animated: true)
    }

}
