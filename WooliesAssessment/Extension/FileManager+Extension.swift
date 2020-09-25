//
//  FileManager+Extension.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import Foundation

extension FileManager {
    func deleteCachesSubfolder(folderName: String) {
        if let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let downloadDirectory = cacheDirectory + "/" + folderName
            if FileManager.default.fileExists(atPath: downloadDirectory) {
                try? FileManager.default.removeItem(atPath: downloadDirectory)
            }
        }
    }
}
