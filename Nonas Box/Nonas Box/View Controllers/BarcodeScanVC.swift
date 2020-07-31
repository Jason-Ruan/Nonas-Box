//
//  BarcodeScanVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/20/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import AVFoundation
import UIKit

class BarcodeScanVC: UIViewController, AVCaptureMetadataOutputObjectsDelegate {
    //MARK: - Properties
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    private var scannedBardCodes: [String] = [] {
        didSet {
            barcodeCollectionView.reloadData()
        }
    }
    
    lazy var barcodeCollectionView: UICollectionView = {
       let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: view.frame.height / 3)), collectionViewLayout: layout)
        cv.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: "barcodeCell")
        cv.dataSource = self
        cv.delegate = self
        layout.itemSize = CGSize(width: cv.frame.width / 5, height: cv.frame.height / 2)
        return cv
    }()

    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        
        captureSession = AVCaptureSession()

        guard let videoCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
        let videoInput: AVCaptureDeviceInput

        do {
            videoInput = try AVCaptureDeviceInput(device: videoCaptureDevice)
        } catch {
            return
        }

        if (captureSession.canAddInput(videoInput)) {
            captureSession.addInput(videoInput)
        } else {
            failed()
            return
        }

        let metadataOutput = AVCaptureMetadataOutput()

        if (captureSession.canAddOutput(metadataOutput)) {
            captureSession.addOutput(metadataOutput)

            metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .upce]
        } else {
            failed()
            return
        }

        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.frame = CGRect(origin: CGPoint(x: view.layer.frame.minX, y: view.layer.frame.midY / 2), size: CGSize(width: view.layer.frame.width, height: view.layer.frame.height / 3))
        previewLayer.borderWidth = 5
        previewLayer.borderColor = UIColor.black.cgColor
        previewLayer.videoGravity = .resizeAspectFill
        view.layer.addSublayer(previewLayer)
        captureSession.startRunning()
        
        view.addSubview(barcodeCollectionView)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        if (captureSession?.isRunning == false) {
            captureSession.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
           super.viewWillDisappear(animated)

           if (captureSession?.isRunning == true) {
               captureSession.stopRunning()
           }
       }
    
    
    //MARK: - Private Functions
    private func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession = nil
    }

    
    //MARK: - AVCaptureSession methods
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
//        captureSession.stopRunning()

        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            
            guard let stringValue = readableObject.stringValue, !scannedBardCodes.contains(stringValue) else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }

//        dismiss(animated: true)
    }

    private func found(code: String) {
        print("https://api.upcitemdb.com/prod/trial/lookup?upc=\(code)")
        scannedBardCodes.append(code)
    }

    override var prefersStatusBarHidden: Bool {
        return true
    }

    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}
