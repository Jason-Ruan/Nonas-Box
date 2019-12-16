//
//  ViewController.swift
//  Nonas Box
//
//  Created by Jason Ruan on 11/20/19.
//  Copyright © 2019 Jason Ruan. All rights reserved.
//

import UIKit
import Speech
import AVFoundation

fileprivate enum DataEntryField: Int {
    case ingredients = 0, directions, notes
}

class RecipeCreationVC: UIViewController {
    //MARK: - IBOutlets
    @IBOutlet weak var instructionsTextView: UITextView!
    @IBOutlet weak var microphoneButton: UIButton!
    @IBOutlet weak var inputTextField: UITextField!
    @IBOutlet weak var segmentedControl: UISegmentedControl!
    @IBOutlet weak var nameOfDishTextField: UITextField!
    @IBOutlet weak var photoButton: UIButton!
    
    
    //MARK: - IBAction
    @IBAction func microphoneButtonPressed(_ sender: UIButton) {
        isRecording = !isRecording
        if isRecording {
            do {
                try startRecording()
            } catch {
                print(error)
            }
        } else {
            stopRecording()
        }
    }
    
    @IBAction func tappedOnSegmentedControl(_ sender: UISegmentedControl) {
        guard let switchedSegment = DataEntryField(rawValue: sender.selectedSegmentIndex) else {return}
        currentDataEntryField = switchedSegment
    }
    
    @IBAction func photoButtonPressed(_ sender: UIButton) {
        openImagePicker()
    }
    
    @IBAction func submitButtonPressed(_ sender: UIButton) {
           
    }
    
    //MARK: - Properties
    
    private var isRecording: Bool = false {
        didSet {
            self.isRecording ? microphoneButton.setImage(UIImage(systemName: "mic.fill"), for: .normal) : microphoneButton.setImage(UIImage(systemName: "mic"), for: .normal)
        }
    }
    
    private var currentDataEntryField: DataEntryField = .ingredients {
        didSet {
            switchTextForSegment(segment: self.currentDataEntryField)
        }
    }
    
    private var ingredientsText = ""
    private var directionsText = ""
    private var notesText = ""
    
    // AVAudioEngine processes input audio signals from the microphone.
    private var audioEngine = AVAudioEngine()
    
    // SFSpeechRecognizer is used for live transcriptions.
    private var speechRecognizer = SFSpeechRecognizer(locale: Locale.init(identifier: "en-US"))
    
    // SFSpeechAudioBufferRecognitionRequest is used by recognizer to access audioEngine.
    private var recognizerRequest = SFSpeechAudioBufferRecognitionRequest()
    
    // SFSpeechRecognitionTask is used to hold in reference when the transcription process begins.
    private var recognizerTask: SFSpeechRecognitionTask?
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        requestTranscribePermissions()
        setDelegates()
    }
    
    
    //MARK: - Private Functions
    private func requestTranscribePermissions() {
        SFSpeechRecognizer.requestAuthorization { (authStatus) in
            switch authStatus {
            case .authorized:
                print("User has authorized speech recognizer.")
            case .denied:
                print("Permission for speech recognition authorization was denied.")
            case .restricted:
                print("Authorization status is restricted. Speech recognition is not available on this device.")
            case .notDetermined:
                print("Not determined")
            default:
                print("Authorization status was not authorized, denies, restricted, or notDetermined")
            }
        }
    }
    
    private func setDelegates() {
        nameOfDishTextField.delegate = self
        instructionsTextView.delegate = self
        inputTextField.delegate = self
    }
    
    private func startRecording() throws {
        // Checks device's iOS version. Starting from iOS 13, offline live audio transcriptions are now possible and without 1 minute limitation.
        if #available(iOS 13, *) {
            if speechRecognizer?.supportsOnDeviceRecognition ?? false{
                recognizerRequest.requiresOnDeviceRecognition = true
            }
        }
        
        recognizerRequest.shouldReportPartialResults = true
        
        // Gets input audio node associated with device's microphone and its output format.
        let inputNode = audioEngine.inputNode
        inputNode.removeTap(onBus: 0)
        let inputNodeFormat = inputNode.outputFormat(forBus: 0)
        
        try prepareAudioSession()
        
        inputNode.installTap(onBus: 0, bufferSize: 1024, format: inputNodeFormat) { [unowned self] (buffer, _) in
            self.recognizerRequest.append(buffer)
        }
        
        audioEngine.prepare()
        try audioEngine.start()
        
        recognizerTask = speechRecognizer?.recognitionTask(with: recognizerRequest) { result, error in
            if let result = result {
                DispatchQueue.main.async {
                    self.inputTextField.text = "\(result.bestTranscription.formattedString)\n\n"
                }
            }
            if error != nil {
                self.stopRecording()
            }
        }
        
    }
    
    private func stopRecording() {
        // Frees up resources associated with audio engine.
        audioEngine.stop()
        
        // Tells request to stop listening for any more audio.
        recognizerRequest.endAudio()
        
        // Lets recognition task know that the process is complete and to free up resources.
        if let recognizerTask = recognizerTask {
            recognizerTask.cancel()
        }
        recognizerTask = nil
    }
    
    private func prepareAudioSession() throws {
        let audioSession = AVAudioSession.sharedInstance()
        try audioSession.setCategory(.record, mode: .measurement, options: .duckOthers)
        try audioSession.setActive(true, options: .notifyOthersOnDeactivation)
    }
    
    private func switchTextForSegment(segment: DataEntryField) {
        switch segment {
        case .ingredients:
            instructionsTextView.text = ingredientsText
        case .directions:
            instructionsTextView.text = directionsText
        case .notes:
            instructionsTextView.text = notesText
        }
    }
    
    private func updateDataFieldTextForSegment(segment: DataEntryField, text: String) {
        switch segment {
        case .ingredients:
            ingredientsText = text
        case .directions:
            directionsText = text
        case .notes:
            notesText = text
        }
    }
    
    private func openImagePicker() {
        let imagePicker = UIImagePickerController()
        imagePicker.delegate = self
        present(imagePicker, animated: true, completion: nil)
    }
    
}


extension RecipeCreationVC: UITextFieldDelegate {
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        if let text = textField.text {
            instructionsTextView.text.append("\n\(text)")
        }
        return true
    }
}
