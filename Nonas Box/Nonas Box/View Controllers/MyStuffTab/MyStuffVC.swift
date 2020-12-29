//
//  MyStuffVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/31/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

public enum MyStuffButtonOptions: String, CaseIterable {
    case checkInventory = "Check Inventory"
    case addToInventory = "Add to Inventory"
    case recipesFromPantry = "Recipes from Pantry"
}

class MyStuffVC: UIViewController {
    
    //MARK: - UI Objects
    private lazy var myStuffButtonsCollectionView: UICollectionView = {
        let cv = UICollectionView(scrollDirection: .vertical, scrollIndicatorsIsVisible: true)
        cv.register(MyStuffOptionCollectionViewCell.self, forCellWithReuseIdentifier: MyStuffOptionCollectionViewCell.identifier)
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    //MARK: - Private Properties
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        setBackgroundColor()
        setUpViews()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        navigationController?.navigationBar.isHidden = true
    }
    
    
    // MARK: - Private Functions
    private func setBackgroundColor() {
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.systemBlue.cgColor, UIColor.white.cgColor]
        gradientLayer.frame = self.view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
    }
    
    private func setUpViews() {
        view.addSubview(myStuffButtonsCollectionView)
        
        myStuffButtonsCollectionView.translatesAutoresizingMaskIntoConstraints = false
        myStuffButtonsCollectionView.frame = view.bounds
    }
    
}


extension MyStuffVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK: - CollectionView DataSource and Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return MyStuffButtonOptions.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: MyStuffOptionCollectionViewCell.identifier, for: indexPath) as? MyStuffOptionCollectionViewCell else { return UICollectionViewCell() }
        cell.myStuffButtonOption = MyStuffButtonOptions.allCases[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width * 0.9, height: collectionView.bounds.height / 6)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MyStuffOptionCollectionViewCell else { return }
        switch cell.myStuffButtonOption {
            case .checkInventory:
                navigationController?.pushViewController(InventoryVC(), animated: true)
            case .addToInventory:
                navigationController?.pushViewController(BarcodeScanVC(), animated: true)
            default:
                print("Not a valid option")
        }
        
    }
    
    
}
