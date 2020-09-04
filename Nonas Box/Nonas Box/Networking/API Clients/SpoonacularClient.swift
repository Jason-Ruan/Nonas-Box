//
//  SpoonacularClient.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/9/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class SpoonacularAPIClient {
    
    func getRecipes(query: String, completionHandler: @escaping (Result<[Recipe], AppError>) -> () ) {
        let formattedQuery = query.replacingOccurrences(of: " ", with: "%20")
        let urlString = "https://api.spoonacular.com/recipes/search?query=\(formattedQuery)&number=100&instructionsRequired=true&apiKey=\(Secrets.spoonacular_api_key)"
        guard let url = URL(string: urlString) else {
            completionHandler(.failure(AppError.badURL))
            return
        }
        
        NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { (result) in
            switch result {
                case .success(let data):
                    do {
                        let recipeResults = try JSONDecoder().decode(SpoonacularResults.self, from: data)
                        guard let recipes = recipeResults.results else {
                            completionHandler(.failure(.invalidJSONResponse))
                            return
                        }
                        completionHandler(.success(recipes))
                    } catch {
                        completionHandler(.failure(.couldNotParseJSON))
                }
                
                case .failure:
                    completionHandler(.failure(.noDataReceived))
            }
        }
    }
    
    func getRecipesForIngredients(withIngredients: [String], completionHandler: @escaping (Result<[Recipe], AppError>) -> () ) {
        guard let url = URL(string: "https://api.spoonacular.com/recipes/findByIngredients?ingredients=\(withIngredients.joined(separator: ",+"))&apiKey=\(Secrets.spoonacular_api_key)") else {
            completionHandler(.failure(.badURL))
            return
        }
        
        NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { (result) in
            switch result {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(let data):
                    do {
                        let recipeResults = try JSONDecoder().decode([Recipe].self, from: data)
                        completionHandler(.success(recipeResults))
                    } catch {
                        completionHandler(.failure(.invalidJSONResponse))
                    }
            }
        }
        
    }
    
    func getRecipeDetails(recipeID: Int, completionHandler: @escaping (Result<RecipeDetails, AppError>) -> () ) {
        guard let url = URL(string: "https://api.spoonacular.com/recipes/\(recipeID.description)/information?apiKey=\(Secrets.spoonacular_api_key)") else {
            completionHandler(.failure(.badURL))
            return
        }
        
        NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { (result) in
            switch result {
                case .failure(let error):
                    completionHandler(.failure(error))
                case .success(let data):
                    do {
                        let recipeDetails = try JSONDecoder().decode(RecipeDetails.self, from: data)
                        completionHandler(.success(recipeDetails))
                    } catch {
                        completionHandler(.failure(.couldNotParseJSON))
                }
            }
        }
    }
    
    func getImage(recipe: Recipe, completionHandler: @escaping (Result<UIImage, AppError>) -> () ) {
        if let imageURL = recipe.imageURL {
            ImageHelper.shared.getImage(url: imageURL) { (result) in
                switch result {
                    case .success(let image):
                        completionHandler(.success(image))
                    case .failure:
                        completionHandler(.failure(.notAnImage))
                }
            }
        } else {
            completionHandler(.failure(.badURL))
        }
    }
    
    private init() {}
    static let manager = SpoonacularAPIClient()
    
}
