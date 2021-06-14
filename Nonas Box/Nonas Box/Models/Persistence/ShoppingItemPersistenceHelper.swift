//
//  ShoppingItemPersistenceHelper.swift
//  Nonas Box
//
//  Created by Jason on 3/14/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import Foundation

class ShoppingItemPersistenceHelper {
    // MARK: - Persistence Methods
    func save(key: String, item: ShoppingItem) throws {
        try persistenceHelper.save(key: key, newElement: item)
    }
    
    func delete(key: String? = nil, title: String? = nil) throws {
        try persistenceHelper.delete(key: key ?? title ?? "")
    }
    
    func deleteAll() throws {
        try persistenceHelper.deleteAll()
    }
    
    func getSavedItemsDictionary() throws -> [String: ShoppingItem] {
        return try persistenceHelper.getObjects()
    }
    
    func getSavedItems() throws -> [ShoppingItem] {
        return try persistenceHelper.getObjects().values.sorted(by: { (item1, item2) -> Bool in
            return item1.itemName < item2.itemName
        })
    }
    
    func contains(item: ShoppingItem) -> Bool {
        do {
            return try persistenceHelper.getObjects().values.map { $0 }.contains(item)
        } catch {
            return false
        }
    }
    
    static let manager = ShoppingItemPersistenceHelper()
    private let persistenceHelper = PersistenceHelper<ShoppingItem>(fileName: "ShoppingItems.plist")
    private init() {}
}
