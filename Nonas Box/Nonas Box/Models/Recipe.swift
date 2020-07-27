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
    
    var imageURL: URL? {
        return URL(string: "https://spoonacular.com/recipeImages/\(image ?? "\(id)-636x393")")
    }

}

extension Recipe: Hashable {
    
    static func == (lhs: Recipe, rhs: Recipe) -> Bool {
        return lhs.id == rhs.id
    }
    
    func hash(into hasher: inout Hasher) {
        hasher.combine(id)
    }
    
}
