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
    private var scannedBarCodes: [String] = []
    private var groceryItems: [UPC_Item] = [] {
        didSet {
            barcodeCollectionView.reloadData()
        }
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    lazy var barcodeCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .horizontal
        let cv = UICollectionView(frame: CGRect(origin: .zero, size: CGSize(width: view.frame.width, height: view.frame.height / 3)), collectionViewLayout: layout)
        cv.register(RecipeCollectionViewCell.self, forCellWithReuseIdentifier: "barcodeCell")
        cv.dataSource = self
        cv.delegate = self
        cv.backgroundColor = .clear
        layout.itemSize = CGSize(width: cv.frame.width / 4, height: cv.frame.height / 2)
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    lazy var barcodeScanArea: UIView = {
        let uv = UIView()
        uv.translatesAutoresizingMaskIntoConstraints = false
        return uv
    }()
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .white
        self.navigationController?.navigationBar.isHidden = true
        requestAVCapturePermissions()
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
    
    override func viewDidLayoutSubviews() {
        previewLayer.frame = barcodeScanArea.bounds
    }
    
    
    //MARK: - Private Functions
    private func requestAVCapturePermissions() {
        switch AVCaptureDevice.authorizationStatus(for: .video) {
            case .authorized: // The user has previously granted access to the camera.
                self.setupCaptureSession()
            
            case .notDetermined: // The user has not yet been asked for camera access.
                AVCaptureDevice.requestAccess(for: .video) { granted in
                    if granted {
                        self.setupCaptureSession()
                    }
            }
            
            case .denied: // The user has previously denied access.
                showAlert(message: "Camera access has been denied.")
                return
            
            
            case .restricted: // The user can't grant access due to restrictions.
                showAlert(message: "Camera access is restricted")
                return
            
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
        NSLayoutConstraint.activate([
            barcodeScanArea.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            barcodeScanArea.leadingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.leadingAnchor, constant: view.safeAreaLayoutGuide.layoutFrame.width / 6),
            barcodeScanArea.trailingAnchor.constraint(equalTo: view.safeAreaLayoutGuide.trailingAnchor, constant: -(view.safeAreaLayoutGuide.layoutFrame.width / 6)),
            barcodeScanArea.heightAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.height / 4)
        ])
        
        barcodeScanArea.layer.cornerRadius = 25
        
        previewLayer = AVCaptureVideoPreviewLayer(session: captureSession)
        previewLayer.videoGravity = .resizeAspectFill
        previewLayer.cornerRadius = barcodeScanArea.layer.cornerRadius
        
        barcodeScanArea.layer.addSublayer(previewLayer)
    }
    
    private func setupCollectionView() {
        view.addSubview(barcodeCollectionView)
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
        captureSession = nil
    }
    
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        //        captureSession.stopRunning()
        
        if let metadataObject = metadataObjects.first {
            guard let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject else { return }
            
            guard let stringValue = readableObject.stringValue, !scannedBarCodes.contains(stringValue) else { return }
            AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
            found(code: stringValue)
        }
        
        //        dismiss(animated: true)
    }
    
    private func found(code: String) {
        scannedBarCodes.append(code)
        UPC_ItemDB_Client.manager.getItem(upc: code) { (result) in
            switch result {
                case .failure(let error):
                    self.showAlert(message: "\(error.localizedDescription): \(error.rawValue)")
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
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "barcodeCell", for: indexPath) as? RecipeCollectionViewCell else { return UICollectionViewCell() }
        
        let groceryItem = groceryItems[indexPath.row]
        
        cell.foodImage.image = nil
        cell.foodInfoLabel.text = groceryItem.title
        
        guard let groceryItemsImages = groceryItem.images else {
            showAlert(message: "Could not find images associated with the item")
            return cell
        }
        
        UPC_ItemDB_Client.manager.getItemImage(barcode: groceryItem.upc!, imageURLs: groceryItemsImages) { (result) in
            switch result {
                case .failure:
                    //                    self.showAlert(message: "\(error.localizedDescription): \(error.rawValue)")
                    //                    cell.foodImage.image = UIImage(systemName: "photo")
                    
                    self.showCameraPrompt()
                
                case .success(let itemImage):
                    cell.foodImage.image = itemImage
            }
        }
        
        return cell
    }
    
}
