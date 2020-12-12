//
//  Spoonacular_PersistenceHelper.swift
//  Nonas Box
//
//  Created by Jason Ruan on 12/12/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

class Spoonacular_PersistenceHelper {
    //MARK: - Persistence Methods
    func save(key: String, item: RecipeDetails) throws {
        try persistenceHelper.save(key: key, newElement: item)
    }
    
    func delete(barcode: String) throws {
        try persistenceHelper.delete(key: barcode)
    }
    
    func getSavedItems() throws -> [String : RecipeDetails] {
        return try persistenceHelper.getObjects()
    }
    
    //MARK: - Singleton Properties
    static let manager = Spoonacular_PersistenceHelper()
    private let persistenceHelper = PersistenceHelper<RecipeDetails>(fileName: "SpoonacularRecipeDetails.plist")
    private init() {}
}
