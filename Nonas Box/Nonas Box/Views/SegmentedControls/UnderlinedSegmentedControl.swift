//
//  UnderlinedSegmentedControl.swift
//  Nonas Box
//
//  Created by Jason Ruan on 11/21/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class UnderlinedSegmentedControl: UIControl {
    
    // MARK: - UI Objects
    public lazy var segmentedControl: UISegmentedControl = {
        let segmentCtrl = UISegmentedControl(items: self.items)
        segmentCtrl.selectedSegmentIndex = 0
        
        // Changes backgroundColor and divider images to clear
        segmentCtrl.setBackgroundImage(UIImage(color: .clear, size: CGSize(width: 1, height: 50)), for: .normal, barMetrics: .default)
        segmentCtrl.setBackgroundImage(UIImage(color: #colorLiteral(red: 1, green: 0.9918877858, blue: 0.9991216787, alpha: 0.2), size: CGSize(width: 1, height: 50)), for: .selected, barMetrics: .default)
        segmentCtrl.setDividerImage(UIImage(color: .lightGray, size: CGSize(width: 0.5, height: 0.5)), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        // Changes color of title colors for selected / unselected segements
        segmentCtrl.setTitleTextAttributes([.foregroundColor: UIColor.systemGray], for: .normal)
        segmentCtrl.setTitleTextAttributes([.foregroundColor: UIColor.white], for: .selected)
        segmentCtrl.addTarget(self, action: #selector(changeSegmentedControlLine), for: .valueChanged)
        
        return segmentCtrl
    }()
    
    private lazy var underlineView: UIView = {
        let view = UIView(frame: CGRect(x: 20, y: 20, width: 20, height: 20))
        view.backgroundColor = .systemBlue
        return view
    }()
    
    // MARK: - Private Properties
    private var items: [String]
    private lazy var underLineLeadingConstraint: NSLayoutConstraint = {
        return self.underlineView.leadingAnchor.constraint(equalTo: leadingAnchor)
    }()
    
    private let underLineViewHeight: CGFloat = 5
    
    // MARK: - Public Properties
    public var index: Int? {
        didSet {
            changeSegmentedControlLine()
        }
    }
    
    // MARK: - Initializers
    init(items: [String]) {
        self.items = items
        super.init(frame: .zero)
        configureSubviews()
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Private Functions
    private func configureSubviews() {
        addSubview(segmentedControl)
        segmentedControl.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            segmentedControl.topAnchor.constraint(equalTo: topAnchor),
            segmentedControl.leadingAnchor.constraint(equalTo: leadingAnchor),
            segmentedControl.trailingAnchor.constraint(equalTo: trailingAnchor),
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor)
        ])
        
        addSubview(underlineView)
        underlineView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            underlineView.bottomAnchor.constraint(equalTo: bottomAnchor),
            underlineView.heightAnchor.constraint(equalToConstant: underLineViewHeight),
            underlineView.widthAnchor.constraint(equalTo: segmentedControl.widthAnchor, multiplier: 1 / CGFloat(segmentedControl.numberOfSegments)),
            underLineLeadingConstraint
        ])
    }
    
    @objc
    private func changeSegmentedControlLine() {
        let segmentIndex = CGFloat(segmentedControl.selectedSegmentIndex)
        let segmentWidth = segmentedControl.frame.width / CGFloat(segmentedControl.numberOfSegments)
        let leadingDistance = segmentWidth * segmentIndex
        UIView.animate(withDuration: 0.2, animations: { [weak self] in
            self?.underLineLeadingConstraint.constant = leadingDistance
            self?.underlineView.backgroundColor = segmentIndex == 0 ? .systemBlue : .systemOrange
            self?.layoutIfNeeded()
        })
    }
    
}
