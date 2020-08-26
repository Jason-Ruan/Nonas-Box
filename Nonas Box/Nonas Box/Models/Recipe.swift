//
//  Recipe.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/9/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

struct SpoonacularResults: Codable {
    let results: [Recipe]?
}

struct Recipe: Codable {
    let id: Int
    let title: String?
    let readyInMinutes: Int?
    let servings: Int?
    let image: String?
    
    let missedIngredientCount: Int?
    let missedIngredients: [IngredientUsedInRecipe]?
    let usedIngredients: [IngredientUsedInRecipe]?
    
    var imageURL: URL? {
        if let imageString = image, let imageURL = URL(string: imageString) {
            return imageURL
        }
        else {
            return URL(string: "https://spoonacular.com/recipeImages/\(image ?? "\(id)-636x393")")
        }
    }

}

struct RecipeDetails: Codable {
    let summary: String?
    let extendedIngredients: [Ingredient]
    let analyzedInstructions: [StepByStepInstructions]?
}

struct StepByStepInstructions: Codable {
    let steps: [Step]?
}

struct Step: Codable {
    let number: Int?
    let step: String?
}


struct Ingredient: Codable {
    let id: Int?
    let name: String?
    let originalString: String?
    let image: String?
    let measures: IngredientMeasurements
    
    var imageURL: URL? {
        guard let image = image else { return nil }
        return URL(string: "https://spoonacular.com/cdn/ingredients_100x100/\(image)")
    }
}

struct IngredientMeasurements: Codable {
    let us: Measurement
    let metric: Measurement
}

struct Measurement: Codable {
    let amount: Double?
    let unitShort: String?
    let unitLong: String?
    
    var shortHandMeasurement: String? {
        guard let amount = amount, let unitShort = unitShort else { return nil }
        return "\(amount) \(unitShort)"
    }
    
    var fullMeasurement: String? {
        guard let amount = amount, let unitLong = unitLong else { return nil }
        return "\(amount) \(unitLong)"
    }
}

