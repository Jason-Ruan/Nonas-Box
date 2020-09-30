//
//  InventoryVC.swift
//  Nonas Box
//
//  Created by Jason Ruan on 9/29/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class InventoryVC: UIViewController {
    
    //MARK: - Properties
    var inventory: [UPC_Item] = []
    
    
    //MARK: - LifeCycle Methods
    override func viewDidLoad() {
        super.viewDidLoad()
        view.backgroundColor = .systemBlue
        loadInventory()
    }
    
    
    //MARK: - Private Functions
    private func loadInventory() {
        do {
            inventory = try Array( UPC_Item_PersistenceHelper.manager.getSavedItems().values)
        } catch {
            print("Unable to load save items")
        }
    }
    
    
}

