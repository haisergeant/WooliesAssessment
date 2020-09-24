//
//  FileManagerProtocol.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//

import Foundation

// MARK: - FileManagerProtocol
protocol FileManagerProtocol {
    func fileExists(atPath path: String) -> Bool
    func createDirectory(atPath path: String, withIntermediateDirectories createIntermediates: Bool, attributes: [FileAttributeKey : Any]?) throws
}

// MARK: - FileManager
extension FileManager: FileManagerProtocol {

}
