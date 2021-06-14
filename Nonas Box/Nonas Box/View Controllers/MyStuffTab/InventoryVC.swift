//
//  InventoryVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 9/29/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class InventoryVC: UIViewController {
    
    // MARK: - UI Objects
    private lazy var itemCollectionView: UICollectionView = {
        let cv = UICollectionView(scrollDirection: .vertical,
                                  spacing: 5,
                                  scrollIndicatorsIsVisible: true,
                                  shouldInset: true)
        cv.register(ItemCollectionViewCell.self, forCellWithReuseIdentifier: "itemCell")
        cv.dataSource = self
        cv.delegate = self
        return cv
    }()
    
    // MARK: - Properties
    var inventory: [UPC_Item] = [] {
        didSet {
            itemCollectionView.reloadData()
        }
    }

    // MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBackground
        configureNavigationBarForTranslucence()
        configureNavigationBarItems()
        configureCollectionViewLongPress()
        constrainItemCollectionView()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        loadInventory()
        navigationController?.navigationBar.isHidden = false
    }
    
    // MARK: - Private Functions
    private func loadInventory() {
        do {
            inventory = try UPC_Item_PersistenceHelper.manager.getSavedItems()
        } catch {
            print("Unable to load save items")
        }
    }
    
    private func configureNavigationBarItems() {
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .add, target: self, action: #selector(presentBarcodeScanVC))
    }
    
    private func configureCollectionViewLongPress() {
        let longPress = UILongPressGestureRecognizer(target: self, action: #selector(showActionSheet(gesture:)))
        itemCollectionView.addGestureRecognizer(longPress)
    }
    
    // MARK: - ObjC Functions
    @objc
    private func presentBarcodeScanVC() {
        present(BarcodeScanVC(), animated: true, completion: nil)
    }
    
    @objc
    private func showActionSheet(gesture: UILongPressGestureRecognizer) {
        let point = gesture.location(in: itemCollectionView)
        guard let indexPath = itemCollectionView.indexPathForItem(at: point) else { return }
        
        let actionSheet = UIAlertController(title: "What would you like to do with this item?", message: nil, preferredStyle: .actionSheet)
        actionSheet.addAction(UIAlertAction(title: "Delete", style: .destructive, handler: { [weak self] _ in
            let item = self?.inventory[indexPath.row]
            do {
                try UPC_Item_PersistenceHelper.manager.delete(barcode: item?.barcode, title: item?.title)
                self?.loadInventory()
            } catch {
                print(error)
            }
        }))
        actionSheet.addAction(UIAlertAction(title: "Edit", style: .default, handler: nil))
        actionSheet.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: nil))
        present(actionSheet, animated: true, completion: nil)
    }
    
    // MARK: - Constraints
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

// MARK: - CollectionView Methods
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
        return CGSize(width: view.safeAreaLayoutGuide.layoutFrame.width * 0.9, height: view.safeAreaLayoutGuide.layoutFrame.height / 4)
    }
}
