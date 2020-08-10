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
    case refillInventory = "Refill Inventory"
    case sendMessage = "Send Message"
    case connectWithOthers = "Connect with Others"
}

class MyStuffVC: UIViewController {
    
    //MARK: - UI Objects
    private lazy var myStuffButtonsCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        let cv = UICollectionView(frame: .zero, collectionViewLayout: layout)
        cv.contentMode = .center
        cv.backgroundColor = .clear
        cv.register(MyStuffOptionCollectionViewCell.self, forCellWithReuseIdentifier: "myStuffOptionCell")
        cv.translatesAutoresizingMaskIntoConstraints = false
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    //MARK: - Private Properties
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        title = "My Stuff"
        let gradientLayer = CAGradientLayer()
        gradientLayer.colors = [UIColor.clear.cgColor, UIColor.systemBlue.cgColor]
        gradientLayer.frame = self.view.bounds
        view.layer.insertSublayer(gradientLayer, at: 0)
        
        view.addSubview(myStuffButtonsCollectionView)
        constrainMyStuffButtonsCollectionView()
    }
    
}


extension MyStuffVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    //MARK: - CollectionView DataSource and Delegate Methods
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        print(MyStuffButtonOptions.allCases.count)
        return MyStuffButtonOptions.allCases.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "myStuffOptionCell", for: indexPath) as? MyStuffOptionCollectionViewCell else { return UICollectionViewCell() }
        cell.myStuffButtonOption = MyStuffButtonOptions.allCases[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: collectionView.bounds.width, height: collectionView.bounds.height / CGFloat(MyStuffButtonOptions.allCases.count) - 20)
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        guard let cell = collectionView.cellForItem(at: indexPath) as? MyStuffOptionCollectionViewCell else {
            print("Not a mystuffcell")
            return
        }
        switch cell.myStuffButtonOption {
            case .addToInventory:
                self.navigationController?.pushViewController(BarcodeScanVC(), animated: true)
            default:
                print("Not a valid option")
        }
        
    }
    
    
}


//MARK: Constraints
extension MyStuffVC {
    private func constrainMyStuffButtonsCollectionView() {
        NSLayoutConstraint.activate([
            myStuffButtonsCollectionView.centerXAnchor.constraint(equalTo: view.safeAreaLayoutGuide.centerXAnchor),
            myStuffButtonsCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: view.safeAreaLayoutGuide.layoutFrame.height / 20),
            myStuffButtonsCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -(view.safeAreaLayoutGuide.layoutFrame.height / 20)),
            myStuffButtonsCollectionView.widthAnchor.constraint(equalToConstant: view.safeAreaLayoutGuide.layoutFrame.width * 3 / 4)
        ])
    }
}
