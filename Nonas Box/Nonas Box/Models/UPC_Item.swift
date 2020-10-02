//
//  UPC_Item.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/27/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

struct UPC_Item_Results: Codable {
    let items: [UPC_Item]
}

struct UPC_Item: Codable {
    let ean: String?
    let upc: String?
    let title: String?
    let description: String?
    let brand: String?
    let images: [URL]?
    
    var barcode: String? {
        return upc ?? ean
    }
    
}
