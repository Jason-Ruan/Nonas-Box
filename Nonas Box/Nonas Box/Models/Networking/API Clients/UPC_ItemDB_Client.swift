//
//  UPC_ItemDB_Client.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/27/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

struct UPC_ItemDB_Client {
    
    static func getItem(barcode: String,
                        completionHandler: @escaping (Result<UPC_Item, AppError>) -> Void ) {
        
        // Find if item was already saved with PersistenceHelper
        do {
            let upcItems = try UPC_Item_PersistenceHelper.manager.getSavedItemsDictionary()
            if let item = upcItems[barcode] {
                completionHandler(.success(item))
                return
            }
        } catch {
            print("Item not found locally; Error: \(error)")
        }
        
        // If item is not saved locally, proceed to look up the item using UPC_ItemDB_Client
        guard let url = URL(string: "https://api.upcitemdb.com/prod/trial/lookup?upc=\(barcode)") else {
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
                    guard var upc_item = upc_item_results.items.first else {
                        completionHandler(.failure(.invalidJSONResponse))
                        return
                    }
                    
                    // Update all URLs for the upc_item to meet security protocol standards
                    upc_item.images = upc_item.images?.map { url in
                        if var urlComponents = URLComponents(url: url, resolvingAgainstBaseURL: false) {
                            urlComponents.scheme = "https"
                            return urlComponents.url ?? url
                        } else {
                            return url
                        }
                    }
                    
                    // Set dateAdded property for the upc_item to be current time
                    upc_item.dateAdded = Date()
                    
                    // Persist item locally on device
                    DispatchQueue.global(qos: .utility).async {
                        if let itemBarcode = upc_item.barcode {
                            try? UPC_Item_PersistenceHelper.manager.save(key: itemBarcode, item: upc_item)
                        }
                    }
                    
                    completionHandler(.success(upc_item))
                } catch {
                    completionHandler(.failure(.invalidJSONResponse))
                }
            }
        }
    }
    
}
