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
    private lazy var itemCollectionView: UICollectionView = {
        let cv = UICollectionView(scrollDirection: .horizontal, scrollIndicatorsIsVisible: true)
        cv.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: "itemCell")
        cv.dataSource = self
        cv.delegate = self
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
        view.backgroundColor = .systemBackground
        navigationController?.navigationBar.isHidden = false
        constrainItemCollectionView()
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
    
    
    //MARK: - Constraints
    private func constrainItemCollectionView() {
        view.addSubview(itemCollectionView)
        itemCollectionView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            itemCollectionView.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            itemCollectionView.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor),
            itemCollectionView.leadingAnchor.constraint(equalTo: view.leadingAnchor),
            itemCollectionView.trailingAnchor.constraint(equalTo: view.trailingAnchor)
        ])
    }
    
    
}


//MARK: - CollectionView Methods
extension InventoryVC: UICollectionViewDataSource, UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return inventory.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        guard let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "itemCell", for: indexPath) as? ItemCollectionViewCell else { return UICollectionViewCell() }
        cell.item = inventory[indexPath.row]
        return cell
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, sizeForItemAt indexPath: IndexPath) -> CGSize {
        return CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width / 3, height: view.safeAreaLayoutGuide.layoutFrame.height / 4)
    }
    
}
