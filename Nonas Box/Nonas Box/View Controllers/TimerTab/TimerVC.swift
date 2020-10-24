//
//  TimerVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 8/31/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import AVFoundation
import UIKit

class TimerVC: UIViewController {
    //MARK: - UI Objects
    lazy var timePickerView: UIPickerView = {
        let pickerView = UIPickerView()
        pickerView.translatesAutoresizingMaskIntoConstraints = false
        pickerView.dataSource = self
        pickerView.delegate = self
        pickerView.tintColor = .systemGray4
        return pickerView
    }()
    
    lazy var timerLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.text = self.timerDisplayCount.description
        label.textAlignment = .center
        label.font = UIFont(name: "Arial", size: 45)
        label.adjustsFontSizeToFitWidth = true
        label.isHidden = true
        return label
    }()
    
    lazy var hourLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.text = "hrs"
        label.textColor = .systemBlue
        return label
    }()
    
    lazy var minLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.text = "min"
        label.textColor = .systemBlue
        return label
    }()
    
    lazy var secLabel: UILabel = {
        let label = UILabel()
        label.translatesAutoresizingMaskIntoConstraints = false
        label.textAlignment = .right
        label.text = "s"
        label.textColor = .systemBlue
        return label
    }()
    
    lazy var toggleTimerButton: TimerButton = {
        let button = TimerButton(frame: CGRect(x: 0, y: 0,
                                               width: view.safeAreaLayoutGuide.layoutFrame.width / 4,
                                               height: view.safeAreaLayoutGuide.layoutFrame.width / 4),
                                 purpose: .start)
        button.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
        return button
    }()
    
    lazy var resetTimerButton: TimerButton = {
        let button = TimerButton(frame: CGRect(x: 0, y: 0,
                                               width: view.safeAreaLayoutGuide.layoutFrame.width / 4,
                                               height: view.safeAreaLayoutGuide.layoutFrame.width / 4),
                                 purpose: .reset)
        button.addTarget(self, action: #selector(resetTimer), for: .touchUpInside)
        return button
    }()
    
    lazy var overdueTimerCountLabel: UILabel = {
        let label = UILabel(frame: CGRect(x: 0, y: 0, width: 10, height: 10))
        label.numberOfLines = 0
        label.textColor = .red
        label.adjustsFontSizeToFitWidth = true
        label.textAlignment = .center
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    lazy var timerValueLabel: UILabel = {
        let label = UILabel()
        label.textColor = .lightGray
        label.layer.cornerRadius = 15
        label.layer.borderWidth = 2
        label.layer.borderColor = UIColor.lightGray.cgColor
        label.numberOfLines = 0
        label.font = UIFont(name: "Arial", size: 16)
        label.textAlignment = .center
        label.isHidden = true
        label.adjustsFontSizeToFitWidth = true
        label.translatesAutoresizingMaskIntoConstraints = false
        return label
    }()
    
    //MARK: - Properties
    var timer = Timer()
    var timerDisplayCount = 0 {
        willSet {
            if timerDisplayCount != 0 && newValue == 0 {
                AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            }
        }
        
        didSet {
            guard timerDisplayCount >= 0 else {
                tabBarItem.badgeValue = nil
                overdueTimerCountLabel.text = "\(timerDisplayCount.description) \(timerDisplayCount == -1 ? "second" : "seconds") overdue"
                return
            }
            adjustTimerLabelText(timerDisplayCount: timerDisplayCount)
            adjustTabBarBadge(timerDisplayCount: timerDisplayCount)
        }
    }
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        addSubviews()
    }
    
    
    // MARK: - Private Functions
    private func adjustTimerLabelText(timerDisplayCount: Int) {
        let hrsRemaining = timerDisplayCount / 3600
        let minsRemaining = (timerDisplayCount - hrsRemaining * 3600) / 60
        let secsRemaining = timerDisplayCount - hrsRemaining * 3600 - minsRemaining * 60
        timerLabel.text = "\(hrsRemaining) \(hrsRemaining != 1 ? "hrs" : "hr") : \(minsRemaining) min : \(secsRemaining) sec"
    }
    
    private func adjustTabBarBadge(timerDisplayCount: Int) {
        if timerDisplayCount >= 3600 {
            tabBarItem.badgeColor = .systemGreen
            tabBarItem.badgeValue = "\(timerDisplayCount / 3600)h"
        } else if timerDisplayCount >= 60 {
            tabBarItem.badgeColor = .systemBlue
            tabBarItem.badgeValue = "\(timerDisplayCount / 60)m"
        } else if timerDisplayCount < 60 {
            tabBarItem.badgeColor = .systemRed
            tabBarItem.badgeValue = "\(timerDisplayCount)s"
        }
    }
    
    private func adjustTimerValueLabelText() {
        var timeValues: [String] = []
        
        let numHours = timePickerView.selectedRow(inComponent: 0)
        let numMin = timePickerView.selectedRow(inComponent: 1)
        let numSec = timePickerView.selectedRow(inComponent: 2)
        
        if numHours > 0 {
            timeValues.append("\(numHours) hr")
        }
        if numMin > 0 {
            timeValues.append("\(numMin) min")
        }
        if numSec > 0 {
            timeValues.append("\(numSec) sec")
        }
        
        timerValueLabel.text = " Running timer for:\n\(timeValues.joined(separator: ", ")) "
    }
    
    
    //MARK: - Objective-C Methods
    @objc func startTimer() {
        // Converts timePickerView selections into total number of seconds
        let hoursToSec = timePickerView.selectedRow(inComponent: 0) * 3600
        let minsToSec = timePickerView.selectedRow(inComponent: 1) * 60
        let sec = timePickerView.selectedRow(inComponent: 2)
        timerDisplayCount = hoursToSec + minsToSec + sec
        
        guard timerDisplayCount > 0 else { return }
        
        resumeTimer()
        
        timePickerView.isHidden = true
        timerLabel.isHidden = false
        overdueTimerCountLabel.isHidden = false
        timerValueLabel.isHidden = false
        
        adjustTimerValueLabelText()
        
        // Change toggleTimerButton to have pause functionality after toggled on
        toggleTimerButton.removeTarget(self, action: #selector(startTimer), for: .touchUpInside)
        toggleTimerButton.addTarget(self, action: #selector(pauseTimer), for: .touchUpInside)
        
    }
    
    @objc func decrementTimer() {
        timerDisplayCount -= 1
    }
    
    @objc func resumeTimer() {
        // RunLoop allows the timer to continue running while scrolling through scrollViews
        timer = Timer(timeInterval: 1, target: self, selector: #selector(decrementTimer), userInfo: nil, repeats: true)
        RunLoop.main.add(timer, forMode: .common)
        
        // Change toggleTimerButton to have pause functionality
        toggleTimerButton.purpose = .pause
        toggleTimerButton.addTarget(self, action: #selector(pauseTimer), for: .touchUpInside)
    }
    
    @objc func pauseTimer() {
        timer.invalidate()
        
        // Change toggleTimerButton to have resume functionality
        toggleTimerButton.purpose = .resume
        toggleTimerButton.addTarget(self, action: #selector(resumeTimer), for: .touchUpInside)
    }
    
    @objc func resetTimer() {
        timer.invalidate()
        timerDisplayCount = 0
        
        timerLabel.isHidden = true
        timePickerView.isHidden = false
        overdueTimerCountLabel.isHidden = true
        overdueTimerCountLabel.text = nil
        timerValueLabel.isHidden = true
        tabBarItem.badgeValue = nil
        
        timerValueLabel.text = nil
        
        toggleTimerButton.purpose = .start
        toggleTimerButton.addTarget(self, action: #selector(startTimer), for: .touchUpInside)
    }
    
    
    //MARK: - Private Constraints
    private func addSubviews() {
        view.addSubview(timePickerView)
        NSLayoutConstraint.activate([
            timePickerView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.safeAreaLayoutGuide.layoutFrame.height / 10),
            timePickerView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            timePickerView.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.height / 2.5)
        ])
        
        view.addSubview(timerLabel)
        NSLayoutConstraint.activate([
            timerLabel.centerXAnchor.constraint(equalTo: timePickerView.centerXAnchor),
            timerLabel.centerYAnchor.constraint(equalTo: timePickerView.centerYAnchor),
            timerLabel.widthAnchor.constraint(equalTo: timePickerView.widthAnchor)
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
        
        view.addSubview(overdueTimerCountLabel)
        NSLayoutConstraint.activate([
            overdueTimerCountLabel.leadingAnchor.constraint(equalTo: timerLabel.leadingAnchor),
            overdueTimerCountLabel.trailingAnchor.constraint(equalTo: timerLabel.trailingAnchor),
            overdueTimerCountLabel.topAnchor.constraint(equalTo: timerLabel.bottomAnchor, constant: 25)
        ])
        
        view.addSubview(timerValueLabel)
        NSLayoutConstraint.activate([
            timerValueLabel.bottomAnchor.constraint(equalTo: timerLabel.topAnchor, constant: -50),
            timerValueLabel.centerXAnchor.constraint(equalTo: timerLabel.centerXAnchor),
            timerValueLabel.heightAnchor.constraint(equalTo: timerLabel.heightAnchor),
            timerValueLabel.widthAnchor.constraint(equalTo: timerLabel.widthAnchor, multiplier: 0.8)
        ])
        
        addUnitsLabelsToTimePickerView()
        
    }
    
    private func addUnitsLabelsToTimePickerView() {
        timePickerView.insertSubview(hourLabel, at: 0)
        timePickerView.insertSubview(minLabel, at: 0)
        timePickerView.insertSubview(secLabel, at: 0)
        
        let hourRowSizeForTimePickerView = timePickerView.rowSize(forComponent: 0)
        let minRowSizeForTimePickerView = timePickerView.rowSize(forComponent: 1)
        let secRowSizeForTimePickerView = timePickerView.rowSize(forComponent: 2)
        
        NSLayoutConstraint.activate([
            hourLabel.centerYAnchor.constraint(equalTo: timePickerView.centerYAnchor),
            minLabel.centerYAnchor.constraint(equalTo: timePickerView.centerYAnchor),
            secLabel.centerYAnchor.constraint(equalTo: timePickerView.centerYAnchor),
            
            hourLabel.widthAnchor.constraint(equalToConstant: hourRowSizeForTimePickerView.width),
            hourLabel.heightAnchor.constraint(equalToConstant: hourRowSizeForTimePickerView.height),
            hourLabel.leadingAnchor.constraint(equalTo: timePickerView.leadingAnchor),
            
            minLabel.widthAnchor.constraint(equalToConstant: minRowSizeForTimePickerView.width),
            minLabel.heightAnchor.constraint(equalToConstant: minRowSizeForTimePickerView.height),
            minLabel.centerXAnchor.constraint(equalTo: timePickerView.centerXAnchor),
            
            secLabel.widthAnchor.constraint(equalToConstant: secRowSizeForTimePickerView.width),
            secLabel.heightAnchor.constraint(equalToConstant: secRowSizeForTimePickerView.height),
            secLabel.trailingAnchor.constraint(equalTo: timePickerView.trailingAnchor, constant: -20)
            
        ])
        
    }
    
    
}

//MARK: - PickerView Methods
extension TimerVC: UIPickerViewDataSource, UIPickerViewDelegate {
    
    // PickerView DataSource Methods
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 3
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        switch component {
            case 0:
                return 24
            case 1:
                return 60
            case 2:
                return 60
            default:
                return 0
        }
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        return row.description
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        if component == 0 {
            hourLabel.text = row == 1 ? "hr" : "hrs"
        }
    }
    
    
}
