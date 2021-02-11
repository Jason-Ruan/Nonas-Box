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
    // MARK: - UI Objects
    private lazy var barcodeCollectionView: UICollectionView = {
        let cv = UICollectionView(scrollDirection: .horizontal,
                                  spacing: 5,
                                  scrollIndicatorsIsVisible: true)
        cv.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: ItemCollectionViewCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    private lazy var barcodeScanArea: BarcodeScanView = { return BarcodeScanView() }()
    
    
    //MARK: - Properties
    private var captureSession: AVCaptureSession!
    private var previewLayer: AVCaptureVideoPreviewLayer!
    
    private var scannedBarCodes: [String] = []
    private var groceryItems: [UPC_Item] = [] {
        didSet {
            barcodeCollectionView.reloadData()
        }
    }
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        title = "Barcode Scan"
        configureNavigationBarForTranslucence()
        requestAVCapturePermissions()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        if captureSession?.isRunning == false {
            captureSession?.startRunning()
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        if captureSession?.isRunning == true {
            captureSession?.stopRunning()
        }
    }
    
    
    override func viewDidLayoutSubviews() {
        guard previewLayer != nil else { return }
        previewLayer.frame = barcodeScanArea.bounds
    }
    
    
    //MARK: - Private Functions
    private func requestAVCapturePermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                setupCaptureSession()
                
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        DispatchQueue.main.async {
                            self.setupCaptureSession()
                        }
                    }
                }
                
            case .denied: // The user has previously denied access.
                showAlert(message: "Camera access has been denied.")
                
                
            case .restricted: // The user can't grant access due to restrictions.
                showAlert(message: "Camera access is restricted")
                
            default:
                return
        }
    }
    
    private func setupCaptureSession() {
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
        
        setupBarcodeScanArea()
        setupCollectionView()
        captureSession.startRunning()
    }
    
    private func setupBarcodeScanArea() {
        view.addSubview(barcodeScanArea)
        barcodeScanArea.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barcodeScanArea.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 30),
            barcodeScanArea.leadingAnchor.constraint(equalTo: view.leadingAnchor, constant: 50),
            barcodeScanArea.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -50),
            barcodeScanArea.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.height / 3.5)
        ])
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.cornerRadius = barcodeScanArea.layer.cornerRadius
        barcodeScanArea.layer.insertSublayer(previewLayer, at: 0)
    }
    
    private func setupCollectionView() {
        view.addSubview(barcodeCollectionView)
        barcodeCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            barcodeCollectionView.topAnchor.constraint(equalTo: barcodeScanArea.bottomAnchor, constant: 10),
            barcodeCollectionView.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: 10),
            barcodeCollectionView.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -10),
            barcodeCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -10)
        ])
    }
    
    
    //MARK: - AVCaptureSession methods
    private func failed() {
        let ac = UIAlertController(title: "Scanning not supported", message: "Your device does not support scanning a code from an item. Please use a device with a camera.", preferredStyle: .alert)
        ac.addAction(UIAlertAction(title: "OK", style: .default))
        present(ac, animated: true)
        captureSession.stopRunning()
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            
            guard let stringValue = readableObject.stringValue, !scannedBarCodes.contains(stringValue) else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
    }
    
    private func found(code: String) {
        scannedBarCodes.append(code)
        UPC_ItemDB_Client.manager.getItem(barcode: code) { (result) in
            switch result {
                case .failure:
                    self.showAlert(message: "Oops, looks like we don't have this item in our database")
                case .success(let upc_item):
                    self.groceryItems.append(upc_item)
            }
        }
    }
    
    private func showCameraPrompt() {
        let action = UIAlertAction(title: "Ok", style: .default, handler: { (action) in
            let cameraCaptureSession = AVCaptureSession()
            guard let cameraCaptureDevice = AVCaptureDevice.default(for: .video) else { return }
            let cameraInput: AVCaptureDeviceInput
            
            do {
                cameraInput = try AVCaptureDeviceInput(device: cameraCaptureDevice)
                
                if (cameraCaptureSession.canAddInput(cameraInput)) {
                    cameraCaptureSession.addInput(cameraInput)
                } else {
                    self.failed()
                    return
                }
                
            } catch {
                print(error)
            }
            
            let metadataOutput = AVCaptureMetadataOutput()
            
            if (cameraCaptureSession.canAddOutput(metadataOutput)) {
                cameraCaptureSession.addOutput(metadataOutput)
                
                metadataOutput.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
                metadataOutput.metadataObjectTypes = [.ean8, .ean13, .pdf417, .upce]
            } else {
                self.failed()
                return
            }
            
        })
        self.showAlertWithAction(title: "Uh-oh", message: "We could not find an image for that item in our database. Would you like to take a photo of this item?", withAction: action)
    }
    
    
}


//MARK - CollectionView DataSource and DelegateFlowLayout Methods
extension BarcodeScanVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return groceryItems.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: ItemCollectionViewCell.identifier, for: indexPath) as? ItemCollectionViewCell else { return UICollectionViewCell() }
        cell.item = groceryItems[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.frame.width / 3, height: collectionView.frame.height / 2.5)
    }
    
}
