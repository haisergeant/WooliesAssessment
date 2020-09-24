//
//  String+Extension.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import Foundation

extension String {
    func capitalizingFirstLetter() -> String {
        let first = prefix(1).capitalized
        let other = dropFirst()
        return first + other
    }

}
