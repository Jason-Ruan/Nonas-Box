//
//  ImageHelper.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/8/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import UIKit

class ImageHelper {
    
    // MARK: - Static Properties
    
    static let shared = ImageHelper()
    
    
    //MARK: - Caching Properties
    
    private let imageCache = NSCache<NSString, UIImage>()
    
    // MARK: - Instance Methods
    
    func getImage(cacheKey: String? = nil, urls: [URL], completionHandler: @escaping (Result<UIImage, AppError>) -> ()) {
        
        guard let url = urls.first else {
            return completionHandler(.failure(.badURL))
        }
        
        //Checks cache to see if image was previously stored, before making network call
        if let cachedImage = imageCache.object(forKey: (cacheKey ?? url.absoluteString) as NSString) {
            completionHandler(.success(cachedImage))
        } else {
            
            //Makes network call to attempt to return image via url if available
            NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { [weak self] (result) in
                DispatchQueue.main.async {
                    switch result {
                        case .failure(let error):
                            let remainingURLs: [URL] = Array(urls.dropFirst())
                            if !remainingURLs.isEmpty {
                                self?.getImage(cacheKey: cacheKey, urls: remainingURLs, completionHandler: completionHandler)
                            } else {
                                completionHandler(.failure(error))
                            }
                            
                        case .success(let imageData):
                            guard let image = UIImage(data: imageData) else {
                                completionHandler(.failure(.notAnImage))
                                return
                            }
                            //Cache image for future use and return it
                            DispatchQueue.global().async { [weak self] in
                                self?.imageCache.setObject(image, forKey: (cacheKey ?? url.absoluteString) as NSString)
                            }
                            completionHandler(.success(image))
                    }
                }
            }
            
            
        }
    }
    
    // MARK: - Private Properties and Initializers
    
    private init() {}
}
