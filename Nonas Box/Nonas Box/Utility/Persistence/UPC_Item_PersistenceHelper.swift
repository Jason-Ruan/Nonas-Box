//
//  UPC_Item_PersistenceHelper.swift
//  Nonas Box
//
//  Created by Jason Ruan on 9/25/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

class UPC_Item_PersistenceHelper {
    //MARK: - Persistence Methods
    func save(key: String, item: UPC_Item) throws {
        try persistenceHelper.save(key: key, newElement: item)
    }
    
    func delete(barcode: String) throws {
        try persistenceHelper.delete(key: barcode)
    }
    
    func getSavedItems() throws -> [String : UPC_Item] {
        return try persistenceHelper.getObjects()
    }
    
    //MARK: - Singleton Properties
    static let manager = UPC_Item_PersistenceHelper()
    private let persistenceHelper = PersistenceHelper<UPC_Item>(fileName: "UPC_Items.plist")
    private init() {}
}
