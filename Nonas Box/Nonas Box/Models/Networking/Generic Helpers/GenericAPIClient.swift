//
//  GenericAPIClient.swift
//  Nonas Box
//
//  Created by Jason on 5/26/21.
//  Copyright © 2021 Jason Ruan. All rights reserved.
//

import Foundation

struct GenericAPIClient {
    
    static func fetchJSON<T: Decodable>(ofType type: T.Type,
                                        urlString: String,
                                        completionHandler: @escaping (Result<T, AppError>) -> Void ) {
        guard let url = URL(string: urlString) else { return completionHandler(.failure(.badURL)) }
        
        NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { result in
            switch result {
            case .success(let data):
                do {
                    let objectData = try JSONDecoder().decode(type, from: data)
                    completionHandler(.success(objectData))
                } catch {
                    completionHandler(.failure(.couldNotParseJSON))
                }
            case .failure(let error):
                completionHandler(.failure(error))
            }
        }
    }
    
}
