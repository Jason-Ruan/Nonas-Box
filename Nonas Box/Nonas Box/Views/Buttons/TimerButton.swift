//
//  TimerButton.swift
//  Nonas Box
//
//  Created by Jason Ruan on 10/7/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class TimerButton: UIButton {
    
    // MARK: - Enums
    enum TimerButtonPurpose: String {
        case reset = "Reset"
        case start = "Start"
        case resume = "Resume"
        case pause = "Pause"
    }
    
    // MARK: - Properties
    var purpose: TimerButtonPurpose! {
        didSet {
            setTitle(purpose.rawValue, for: .normal)
            removeTarget(nil, action: nil, for: .allEvents)
            changeButtonColor(purpose: purpose)
        }
    }
    
    
    // MARK: - Initializers
    required init(frame: CGRect, purpose: TimerButtonPurpose) {
        super.init(frame: frame)
        defer { self.purpose = purpose }
        
        translatesAutoresizingMaskIntoConstraints = false
        layer.cornerRadius = frame.height / 2
        layer.borderWidth = 5
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    // MARK: - Private Functions
    private func changeButtonColor(purpose: TimerButtonPurpose) {
        switch purpose {
            case .reset:
                layer.borderColor = #colorLiteral(red: 0.6281864643, green: 0, blue: 0.2587452531, alpha: 0.6612799658)
                backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
                setTitleColor(UIColor.white, for: .normal)
                setTitleColor(UIColor.systemRed, for: .highlighted)
            case .start:
                layer.borderColor = #colorLiteral(red: 0, green: 0.8449820876, blue: 0.3828604817, alpha: 0.7905072774)
                backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
                setTitleColor(UIColor.white, for: .normal)
                setTitleColor(UIColor.systemGreen, for: .highlighted)
            case .resume:
                layer.borderColor = #colorLiteral(red: 0, green: 0.6811785102, blue: 0.07376856357, alpha: 0.611515411)
                backgroundColor = #colorLiteral(red: 0, green: 0.7343283296, blue: 0.1089321449, alpha: 0.4229719606)
                setTitleColor(UIColor.white, for: .normal)
                setTitleColor(UIColor.systemGreen, for: .highlighted)
            case .pause:
                layer.borderColor = UIColor.systemOrange.cgColor
                backgroundColor = UIColor.systemYellow
                setTitleColor(UIColor.white, for: .normal)
                setTitleColor(UIColor.systemOrange, for: .highlighted)
        }
    }
    
    
}
