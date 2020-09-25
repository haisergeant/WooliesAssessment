//
//  Breed.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//

import Foundation


struct Breed: Decodable {
    let id: String
    let url: String
    let breeds: [BreedItem]
    
    var name: String {
        breeds.first?.name ?? ""
    }
    
    var lifeSpan: String {
        breeds.first?.lifeSpan ?? ""
    }
    
    lazy var minMaxLifeSpan: (min: Int, max: Int)? = {
        guard let first = self.breeds.first else {
            return nil
        }
        let lifeSpan = first.lifeSpan
        guard let range = lifeSpan.range(of: "years") else {
            return nil
        }
        
        let temp = lifeSpan[..<range.lowerBound].trimmingCharacters(in: .whitespaces)
        let components = temp.components(separatedBy: " ").compactMap { Int($0) }
        if components.count == 2 {
            return (components[0], components[1])
        } else if let year = Int(temp.trimmingCharacters(in: .whitespaces)) {
            return (year, year)
        } else {
            return nil
        }
    }()
}


struct BreedItem: Decodable {
    let id: Int
    let name: String
    let lifeSpan: String
    
    private enum CodingKeys: String, CodingKey {
        case id, name
        case lifeSpan = "life_span"
    }
}
