//
//  APIConstants.swift
//
//  Created by Hai Le.
//  Copyright © 2020 Hai Le. All rights reserved.
//

import Foundation

struct APIConstants {
    static let REQUEST_API = "https://api.thedogapi.com/v1/images/search?limit=50"
}

enum APIError: Error, Equatable {
    case invalidAPIError
    case invalidImageLink
    case jsonFormatError
    
    var localizedDescription: String {
        switch self {
        case .invalidAPIError:
            return "Invalid API"
        case .invalidImageLink:
            return "Invalid image link"
        case .jsonFormatError:
            return "JSON format error"
        }
    }
}
