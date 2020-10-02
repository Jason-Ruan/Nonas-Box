//
//  InventoryVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 9/29/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class InventoryVC: UIViewController {
    
    //MARK: - UI Objects
    lazy var itemCollectionView: UICollectionView = {
        let layout = UICollectionViewFlowLayout()
        layout.scrollDirection = .vertical
        layout.itemSize = CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width / 3,
                                 height: view.safeAreaLayoutGuide.layoutFrame.height / 5)
        layout.minimumLineSpacing = 10
        
        let cv = UICollectionView(frame: view.bounds, collectionViewLayout: layout)
        cv.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: "itemCell")
        cv.backgroundColor = .clear
        cv.layer.borderWidth = 5
        cv.layer.borderColor = UIColor.black.cgColor
        cv.dataSource = self
        cv.delegate = self
        cv.translatesAutoresizingMaskIntoConstraints = false
        return cv
    }()
    
    
    //MARK: - Properties
    var inventory: [UPC_Item] = [] {
        didSet {
            itemCollectionView.reloadData()
        }
    }
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        view.addSubview(itemCollectionView)
        loadInventory()
    }
    
    
    //MARK: - Private Functions
    private func loadInventory() {
        do {
            inventory = try Array( UPC_Item_PersistenceHelper.manager.getSavedItems().values).sorted(by: { (item1, item2) -> Bool in
                guard let item1Title = item1.title, let item2Title = item2.title else { return false }
                return item1Title < item2Title
            })
        } catch {
            print("Unable to load save items")
        }
    }
    
    
}


extension InventoryVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inventory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCollectionViewCell else { return UICollectionViewCell() }
        cell.item = inventory[indexPath.row]
        return cell
    }
    
    
}
