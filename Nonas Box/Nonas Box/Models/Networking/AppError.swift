//
//  AppError.swift
//  Nonas Box
//
//  Created by Jason Ruan on 7/6/20.
//  Copyright © 2020 Jason Ruan. All rights reserved.
//

import Foundation

enum AppError: String, Error {
    case unauthenticated
    case invalidJSONResponse
    case couldNotParseJSON
    case noInternetConnection
    case badURL
    case badStatusCode
    case noDataReceived
    case notAnImage
    case other
}
