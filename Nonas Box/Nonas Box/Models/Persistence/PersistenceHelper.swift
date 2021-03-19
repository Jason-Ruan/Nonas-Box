//
//  PersistenceHelper.swift
//  Nonas Box
//
//  Created by Jason Ruan on 9/22/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

struct PersistenceHelper<T: Codable> {
    //MARK: - Persistence Methods
    func getObjects() throws -> [String : T] {
        guard let data = FileManager.default.contents(atPath: url.path) else {
            return [:]
        }
        return try PropertyListDecoder().decode([String : T].self, from: data)
    }
    
    func save(key: String, newElement: T) throws {
        var elements = try getObjects()
        elements[key] = newElement
        let serializedData = try PropertyListEncoder().encode(elements)
        try serializedData.write(to: url, options: Data.WritingOptions.atomic)
    }
    
    func delete(key: String) throws {
        var elements = try getObjects()
        guard !elements.isEmpty else { return }
        elements.removeValue(forKey: key)
        let serializedData = try PropertyListEncoder().encode(elements)
        try serializedData.write(to: url, options: Data.WritingOptions.atomic)
    }
    
    func deleteAll() throws {
        try FileManager.default.removeItem(at: url)
    }
    
    //MARK: - Initializer
    init(fileName: String){
        self.fileName = fileName
    }
    
    //MARK: - Private Properties
    private let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    
    private func filePathFromDocumentsDirectory(name: String) -> URL {
        return documentsDirectory.appendingPathComponent(name)
    }
    
    private let fileName: String
    
    private var url: URL {
        return filePathFromDocumentsDirectory(name: fileName)
    }
}
