//
//  SpoonacularClient.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/9/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

class SpoonacularAPIClient {
    
    func getRecipes(query: String, offset: Int? = nil, completionHandler: @escaping (Result<[Recipe], AppError>) -> () ) {
        let formattedQuery = query.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? ""
        let urlString = "https://api.spoonacular.com/recipes/search?query=\(formattedQuery)&number=10&offset=\(offset ?? 0)&instructionsRequired=true&apiKey=\(Secrets.spoonacular_api_key)"
        
        GenericAPIClient.manager.fetchJSON(ofType: SpoonacularResults.self, urlString: urlString) { result in
            switch result {
            case .success(let spoonacularResults):
                guard let recipeResults = spoonacularResults.results else { return completionHandler(.failure(.invalidJSONResponse)) }
                completionHandler(.success(recipeResults))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    func getRecipesForIngredients(withIngredients: [String], completionHandler: @escaping (Result<[Recipe], AppError>) -> () ) {
        let urlString = "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(withIngredients.joined(separator: ",+"))&ranking=1&ignorePantry=true&apiKey=\(Secrets.spoonacular_api_key)"
        
        GenericAPIClient.manager.fetchJSON(ofType: [Recipe].self, urlString: urlString) { result in
            switch result {
            case .success(let recipes):
                completionHandler(.success(recipes))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
        
    }
    
    func getRecipeDetails(recipeID: Int, completionHandler: @escaping (Result<RecipeDetails, AppError>) -> () ) {
        let urlString = "https://api.spoonacular.com/recipes/\(recipeID.description)/information?includeNutrition&apiKey=\(Secrets.spoonacular_api_key)"
        
        GenericAPIClient.manager.fetchJSON(ofType: RecipeDetails.self, urlString: urlString) { result in
            switch result {
            case .success(let recipeDetails):
                completionHandler(.success(recipeDetails))
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
    private init() {}
    static let manager = SpoonacularAPIClient()
}
