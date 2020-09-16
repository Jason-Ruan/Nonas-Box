//
//  TimerVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 8/31/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class TimerVC: UIViewController {
    //MARK: - UI Objects
    lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.text = self.timerDisplayCount.description
        return label
    }()
    
    lazy var startTimerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Start", for: .normal)
        return button
    }()
    
    lazy var pauseTimerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Pause", for: .normal)
        return button
    }()
    
    lazy var resetTimerButton: UIButton = {
        let button = UIButton()
        button.setTitle("Reset", for: .normal)
        return button
    }()
    
    //MARK: - Properties
    var timer = Timer()
    var timerDisplayCount = 0.0
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
    }
    
    //MARK: - Methods
    
}
