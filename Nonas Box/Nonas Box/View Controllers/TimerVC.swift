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
    lazy var timePickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self
        return pickerView
    }()
    
    lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.timerDisplayCount.description
        label.textAlignment = .center
        label.font = UIFont(name: "Arial", size: 20)
        label.isHidden = true
        return label
    }()
    
    lazy var toggleTimerButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0,
                                            width: view.safeAreaLayoutGuide.layoutFrame.width / 4,
                                            height: view.safeAreaLayoutGuide.layoutFrame.width / 4))
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.borderWidth = 5
        button.layer.borderColor = #colorLiteral(red: 0, green: 0.8449820876, blue: 0.3828604817, alpha: 0.7905072774)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Start", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.4666666687, green: 0.7647058964, blue: 0.2666666806, alpha: 1)
        button.setTitleColor(UIColor.systemBlue, for: .highlighted)
        button.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        return button
    }()
    
    lazy var resetTimerButton: UIButton = {
        let button = UIButton(frame: CGRect(x: 0, y: 0,
                                            width: view.safeAreaLayoutGuide.layoutFrame.width / 4,
                                            height: view.safeAreaLayoutGuide.layoutFrame.width / 4))
        button.layer.cornerRadius = button.frame.height / 2
        button.layer.borderWidth = 5
        button.layer.borderColor = #colorLiteral(red: 0.6281864643, green: 0, blue: 0.2587452531, alpha: 0.6612799658)
        button.translatesAutoresizingMaskIntoConstraints = false
        button.setTitle("Reset", for: .normal)
        button.backgroundColor = #colorLiteral(red: 0.8078431487, green: 0.02745098062, blue: 0.3333333433, alpha: 1)
        button.setTitleColor(UIColor.systemBlue, for: .highlighted)
        button.addTarget(self, action: #selector(resetTimer), for: .touchUpInside)
        return button
    }()
    
    //MARK: - Properties
    var timer = Timer()
    var timerDisplayCount = 0
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        view.backgroundColor = #colorLiteral(red: 1, green: 1, blue: 1, alpha: 1)
        addSubviews()
    }
    
    //MARK: - Methods
    @objc func startTimer() {
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(incrementTimer), userInfo: nil, repeats: true)
        timePickerView.isHidden = true
        timerLabel.isHidden = false
    }
    
    @objc func incrementTimer() {
        timerDisplayCount += 1
        timerLabel.text = timerDisplayCount.description
    }
    
    @objc func pauseTimer() {
        timer.invalidate()
        toggleTimerButton.removeTarget(self, action: #selector(startTimer), for: .touchUpInside)
    }
    
    @objc func resetTimer() {
        timer.invalidate()
        timerDisplayCount = 0
        timerLabel.text = timerDisplayCount.description
        timerLabel.isHidden = true
        timePickerView.isHidden = false
    }
    
    
    //MARK: - Private Constraints
    private func addSubviews() {
        view.addSubview(timePickerView)
        NSLayoutConstraint.activate([
            timePickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            timePickerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            timePickerView.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.height / 3)
        ])
        
        view.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            timerLabel.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            timerLabel.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.height / 5)
        ])
        
        view.addSubview(resetTimerButton)
        NSLayoutConstraint.activate([
            resetTimerButton.topAnchor.constraint(equalTo: timePickerView.bottomAnchor, constant: 30),
            resetTimerButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: -(view.safeAreaLayoutGuide.layoutFrame.width / 4) ),
            resetTimerButton.widthAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.width / 4),
            resetTimerButton.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.width / 4)
        ])
        
        view.addSubview(toggleTimerButton)
        NSLayoutConstraint.activate([
            toggleTimerButton.topAnchor.constraint(equalTo: timePickerView.bottomAnchor, constant: 30),
            toggleTimerButton.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor, constant: view.safeAreaLayoutGuide.layoutFrame.width / 4),
            toggleTimerButton.widthAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.width / 4),
            toggleTimerButton.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.width / 4)
        ])
   
    }
    
    
}
