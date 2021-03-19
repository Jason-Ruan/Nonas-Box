//
//  ShoppingItem.swift
//  Nonas Box
//
//  Created by Jason on 3/17/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import Foundation

struct ShoppingItem: Codable, Equatable {
    var itemName: String
    var itemQuantity: Double?
    var itemCustomaryUnit: String?
    var itemMetricUnit: String?
    var ingredientCount: Int?
    var imageURL: URL?
    var itemUnit: String?
    
    init?(fromRecipe recipe: RecipeDetails) {
        self.itemName = recipe.title ?? "Error: missing recipe name"
        self.itemQuantity = Double(recipe.extendedIngredients.count)
        self.itemCustomaryUnit = "ingredients"
        self.itemMetricUnit = "ingredients"
        self.imageURL = recipe.imageURL
    }
    
    init?(fromUPC_Item item: UPC_Item, itemQuantity: Double?, itemUnit: String?) {
        self.itemName = item.title ?? "Error: missing item name"
        self.itemQuantity = itemQuantity
        self.itemUnit = itemUnit
        self.imageURL = item.images?.first
    }
    
    init?(itemName: String, itemQuantity: Double? = 1, itemUnit: String? = nil, imageURL: URL? = nil) {
        self.itemName = itemName
        self.itemQuantity = itemQuantity
        self.itemUnit = itemUnit
        self.imageURL = imageURL
    }
    
    var itemUSMeasurement: String {
        return "\(String(format: "%.3g", itemQuantity ?? 1))"
    }
    
}
