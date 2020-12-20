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
    func save(recipeID: Int, recipeDetails: RecipeDetails) throws {
        try persistenceHelper.save(key: recipeID.description, newElement: recipeDetails)
    }
    
    func delete(recipeID: Int) throws {
        try persistenceHelper.delete(key: recipeID.description)
    }
    
    func getSavedRecipesDictionary() throws -> [String : RecipeDetails] {
        return try persistenceHelper.getObjects()
    }
    
    func getSavedRecipes() throws -> [RecipeDetails] {
        return try persistenceHelper.getObjects().values.sorted(by: { (recipe1, recipe2) -> Bool in
            guard let title1 = recipe1.title, let title2 = recipe2.title else { return false }
            return title1 < title2
        })
    }
    
    func checkIsSaved(forRecipeID recipeID: Int) throws -> Bool {
        return try persistenceHelper.getObjects()[recipeID.description] != nil
    }
    
    //MARK: - Singleton Properties
    static let manager = Spoonacular_PersistenceHelper()
    private let persistenceHelper = PersistenceHelper<RecipeDetails>(fileName: "SpoonacularRecipeDetails.plist")
    private init() {}
}
