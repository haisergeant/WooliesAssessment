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
