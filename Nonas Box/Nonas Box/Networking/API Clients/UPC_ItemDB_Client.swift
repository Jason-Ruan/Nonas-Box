//
//  UPC_ItemDB_Client.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/27/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

class UPC_ItemDB_Client {
    
    func getItem(upc: String, completionHandler: @escaping (Result<UPC_Item, AppError>) -> () ) {
        guard let url = URL(string: "https://api.upcitemdb.com/prod/trial/lookup?upc=\(upc)") else {
            completionHandler(.failure(.badURL))
            return
        }
        
        NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { (result) in
            switch result {
                case .failure:
                    print("Could not retrieve corresponding item from API database")
                    completionHandler(.failure(.noDataReceived))
                case .success(let data):
                    do {
                        let upc_item_results = try JSONDecoder().decode(UPC_Item_Results.self, from: data)
                        guard let upc_item = upc_item_results.items.first else {
                            completionHandler(.failure(.invalidJSONResponse))
                            return
                        }
                        completionHandler(.success(upc_item))
                    } catch {
                        completionHandler(.failure(.invalidJSONResponse))
                    }
            }
        }
    }
    
    
    private init() {}
    static let manager = UPC_ItemDB_Client()
}
