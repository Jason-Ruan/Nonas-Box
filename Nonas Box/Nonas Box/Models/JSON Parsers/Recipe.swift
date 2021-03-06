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
    // For recipe blurb info
    let id: Int
    let title: String?
    let readyInMinutes: Int?
    let servings: Int?
    
    // For searching recipes based on ingredients
    let missedIngredientCount: Int?
    let missedIngredients: [IngredientUsedInRecipe]?
    let usedIngredients: [IngredientUsedInRecipe]?
    
    private let image: String?
    
    var imageURL: URL? {
        if let imageString = image, imageString.contains("http"), let imageURL = URL(string: imageString) {
            return imageURL
        } else {
            return URL(string: "https://spoonacular.com/recipeImages/\(image ?? "\(id)-636x393")")
        }
    }
    
}

struct RecipeDetails: Codable {
    let id: Int
    let title: String?
    let readyInMinutes: Int?
    let servings: Int?
    let imageURL: URL?
    let summary: String?
    let extendedIngredients: [Ingredient]
    let analyzedInstructions: [StepByStepInstructions]?
    let sourceUrl: URL?
    
    private enum CodingKeys: String, CodingKey {
        case id, title, readyInMinutes, servings, summary, extendedIngredients, analyzedInstructions, sourceUrl
        case imageURL = "image"
    }
    
    var numOfSectionsOfInstructions: Int {
        return analyzedInstructions?.count ?? 0
    }
}

struct StepByStepInstructions: Codable {
    let name: String?
    let steps: [Step]?
}

struct Step: Codable {
    let number: Int?
    private let step: String?
    
    // To fix formatting for sentences that begin right after a period.
    // before: This sentence stops here.And this sentence starts here.
    // after: This sentence stops here. And this sentence starts here.
    var instruction: String? {
        guard let step = step else { return nil }
        return step.components(separatedBy: ".")
            .map {
                if $0.first == " " {
                    return String($0.dropFirst())
                } else {
                    return $0
                }
            }
            .joined(separator: ". ")
    }
}

struct Ingredient: Codable {
    let id: Int?
    let name: String?
    let originalString: String?
    let measures: IngredientMeasurements
    
    private let image: String?
    
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
    var amount: Double?
    private let unitShort: String?
    private let unitLong: String?
    
    var shortHandMeasurement: String? {
        guard let amount = amount, let unitShort = unitShort else { return nil }
        return "\(String(format: "%.3g", amount)) \(unitShort)"
    }
    
    var fullMeasurement: String? {
        guard let amount = amount, let unitLong = unitLong else { return nil }
        return "\(String(format: "%.3g", amount)) \(unitLong)"
    }
}

struct IngredientUsedInRecipe: Codable {
    let aisle: String?
    let amount: Double?
    let unitLong: String?
    let unitShort: String?
    let extendedName: String?
    let id: Int?
    let imageURL: URL?
    let original: String?
    let name: String?
    
    private enum CodingKeys: String, CodingKey {
        case aisle, amount, unitLong, unitShort, extendedName, id, original, name
        case imageURL = "image"
    }
}
