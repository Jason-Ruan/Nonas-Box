//
//  SpoonacularClient.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/9/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

class SpoonacularAPIClient {
    
    func getRecipes(query: String, completionHandler: @escaping (Result<[Recipe], AppError>) -> () ) {
        let formattedQuery = query.replacingOccurrences(of: " ", with: "%20")
        let urlString = "https://api.spoonacular.com/recipes/search?query=\(formattedQuery)&number=100&apiKey=\(Secrets.spoonacular_api_key)"
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
                            completionHandler(.failure(AppError.invalidJSONResponse))
                            return
                        }
                        completionHandler(.success(recipes))
                    } catch {
                        completionHandler(.failure(AppError.couldNotParseJSON(rawError: error)))
                }
                
                case .failure:
                    completionHandler(.failure(AppError.noDataReceived))
            }
        }
    }
    
    private init() {}
    static let manager = SpoonacularAPIClient()
    
}
