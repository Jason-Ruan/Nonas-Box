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
    
    func delete(barcode: String? = nil, title: String? = nil) throws {
        try persistenceHelper.delete(key: barcode ?? title ?? "")
    }
    
    func getSavedItemsDictionary() throws -> [String : UPC_Item] {
        return try persistenceHelper.getObjects()
    }
    
    func getSavedItems() throws -> [UPC_Item] {
        return try persistenceHelper.getObjects().values.sorted(by: { (item1, item2) -> Bool in
            guard let title1 = item1.title, let title2 = item2.title else { return false }
            return title1 < title2
        })
    }
    
    //MARK: - Singleton Properties
    static let manager = UPC_Item_PersistenceHelper()
    private let persistenceHelper = PersistenceHelper<UPC_Item>(fileName: "UPC_Items.plist")
    private init() {}
}
