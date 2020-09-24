//
//  CacheImageOperation.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//

import UIKit

// MARK: - CacheImageOperation
final class CacheImageOperation: BaseOperation<UIImage> {
    
    private let urlSession: URLSessionProtocol
    private let fileManager: FileManagerProtocol
    private let url: URL
    private var dataTask: URLSessionDataTaskProtocol?
    
    init(url: URL, urlSession: URLSessionProtocol = URLSession.shared, fileManager: FileManagerProtocol = FileManager.default) {
        self.url = url
        self.urlSession = urlSession
        self.fileManager = fileManager
    }
    
    override func main() {
        if let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory, .userDomainMask, true).first {
            let fileName = self.url.lastPathComponent
            
            let downloadDirectory = cacheDirectory + "/" + "Download"
            if !fileManager.fileExists(atPath: downloadDirectory) {
                try? fileManager.createDirectory(atPath: downloadDirectory,
                                                 withIntermediateDirectories: true,
                                                 attributes: nil)
            }
            
            let fullFileName = downloadDirectory + "/" + fileName
            
            // Retrieve the image in file system if it exists
            if fileManager.fileExists(atPath: fullFileName) {
                guard let image = UIImage(contentsOfFile: fullFileName) else {
                    complete(result: .failure(APIError.invalidImageLink))
                    return
                }
                self.complete(result: .success(image))
            } else {
                let urlRequest = URLRequest(url: url)
                dataTask = urlSession.dataTask(with: urlRequest) { [weak self] (data, response, error) in                    
                    guard let self = self else { return }
                    guard let data = data,
                        let image = UIImage(data: data),
                        let newData = image.jpegData(compressionQuality: 1),
                        let newImage = UIImage(data: newData) else {
                        self.complete(result: .failure(APIError.invalidImageLink))
                        return
                    }
                    // Store image in file system for later use
                    try? newData.write(to: URL(fileURLWithPath: fullFileName))
                    self.complete(result: .success(newImage))
                }
                dataTask?.resume()
            }
        } else {
            complete(result: .failure(APIError.invalidImageLink))
        }
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}
