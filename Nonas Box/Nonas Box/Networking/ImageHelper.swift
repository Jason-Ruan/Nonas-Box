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
    
    let imageCache = NSCache<NSString, UIImage>()
    
    // MARK: - Instance Methods
    
    func getImage(url: URL, completionHandler: @escaping (Result<UIImage, AppError>) -> ()) {
        
        //Checks cache to see if image was previously stored, before making network call
        if let cachedImage = imageCache.object(forKey: url.absoluteString as NSString) {
            completionHandler(.success(cachedImage))
        } else {
            
            //Makes network call to attempt to return image via url if available
            NetworkHelper.manager.performDataTask(withUrl: url, andMethod: .get) { (result) in
                DispatchQueue.main.async {
                    switch result {
                        case .failure(let error):
                            completionHandler(.failure(error))
                        case .success(let imageData):
                            guard let image = UIImage(data: imageData) else {
                                completionHandler(.failure(.notAnImage))
                                return
                            }
                            //Cache image for future use and return it
                            DispatchQueue.global().async {
                                self.imageCache.setObject(image, forKey: url.absoluteString as NSString)
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
