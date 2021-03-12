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
        let c = UISegmentedControl(items: self.items)
        c.selectedSegmentIndex = 0
        
        // Changes backgroundColor and divider images to clear
        c.setBackgroundImage(UIImage(color: .clear, size: CGSize(width: 1, height: 50)), for: .normal, barMetrics: .default)
        c.setDividerImage(UIImage(color: .clear, size: CGSize(width: 1, height: 50)), forLeftSegmentState: .normal, rightSegmentState: .normal, barMetrics: .default)
        
        // Changes color of title colors for selected / unselected segements
        c.setTitleTextAttributes([.foregroundColor : UIColor.systemGray], for: .normal)
        c.setTitleTextAttributes([.foregroundColor : UIColor.white], for: .selected)
        c.addTarget(self, action: #selector(changeSegmentedControlLine), for: .valueChanged)
        return c
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
            segmentedControl.bottomAnchor.constraint(equalTo: bottomAnchor, constant: -underLineViewHeight)
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
        UIView.animate(withDuration: 0.3, animations: { [weak self] in
            self?.underLineLeadingConstraint.constant = leadingDistance
            self?.underlineView.backgroundColor = segmentIndex == 0 ? .systemBlue : .systemOrange
            self?.layoutIfNeeded()
        })
    }
    
}
