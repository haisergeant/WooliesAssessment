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
        guard let first = self.breeds.first else { return nil }
        let lifeSpan = first.lifeSpan
        guard let range = lifeSpan.range(of: "years") else { return nil }
        
        let temp = lifeSpan[..<range.lowerBound]
        let components = temp.components(separatedBy: "-")
        guard components.count == 2,
            let minLifeSpan = Int(components[0].trimmingCharacters(in: .whitespaces)),
            let maxLifeSpan = Int(components[1].trimmingCharacters(in: .whitespaces)) else { return nil }
        return (minLifeSpan, maxLifeSpan)
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
