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
    let title: String?
    let description: String?
    let brand: String?
    var images: [URL]?
    var dateAdded: Date?
    
    var barcode: String? {
        return upc ?? ean
    }
    
    private let ean: String?
    private let upc: String?
    
}
