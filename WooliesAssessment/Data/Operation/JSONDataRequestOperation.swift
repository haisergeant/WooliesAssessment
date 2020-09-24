//
//  JSONDataRequestOperation.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//

import Foundation

// MARK: - JSONDataRequestOperation
final class JSONDataRequestOperation<Element: Decodable>: BaseOperation<Element> {
        
    private let urlSession: URLSessionProtocol
    private let url: URL
    private let httpMethod: String
    private let body: Data?
    private var dataTask: URLSessionDataTaskProtocol?
    
    init(url: URL,
         httpMethod: String = "GET", body: Data? = nil,
         urlSession: URLSessionProtocol = URLSession.shared) {
        self.url = url
        self.body = body
        self.httpMethod = httpMethod
        self.urlSession = urlSession
    }
    
    override func main() {
        let urlRequest = NSMutableURLRequest(url: url)
        urlRequest.httpMethod = httpMethod
        urlRequest.httpBody = body
        dataTask = urlSession.dataTask(with: urlRequest as URLRequest) { [weak self] (data, response, error) in
            guard let self = self else { return }
            do {
                if let error = error {
                    self.complete(result: .failure(error))
                } else if let data = data {
                    let decoder = JSONDecoder()
                    let result = try decoder.decode(Element.self, from: data)
                    self.complete(result: .success(result))
                }
            } catch {
                self.complete(result: .failure(APIError.jsonFormatError))
            }
        }
        
        dataTask?.resume()
    }
    
    override func cancel() {
        dataTask?.cancel()
        super.cancel()
    }
}
