//
//  BreedService.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//

import Foundation
import UIKit

protocol BreedServiceProtocol {
    func requestBreed(completionHandler: @escaping ((Result<[Breed], Error>) -> Void))
    func requestImage(for breed: Breed,
                      completionHandler: @escaping ((Result<UIImage, Error>) -> Void))
    func cancelRequestImage(for breed: Breed)
}

class BreedService: BreedServiceProtocol {
    private let queueManager: QueueManager
    private let session: URLSessionProtocol
    private var currentOperation: Operation?
    private var loadImageOperations: [String: Operation] = [:]

    init(queueManager: QueueManager = .shared,
         session: URLSessionProtocol = URLSession.shared) {
        self.queueManager = queueManager
        self.session = session
    }
    
    func requestBreed(completionHandler: @escaping ((Result<[Breed], Error>) -> Void)) {
        guard let url = URL(string: APIConstants.REQUEST_API) else {
            completionHandler(.failure(APIError.invalidAPIError))
            return
        }
        currentOperation?.cancel()
        currentOperation = nil
        let operation = JSONDataRequestOperation<[Breed]>(url: url,
                                                          urlSession: session)
        operation.completionHandler = { result in
            DispatchQueue.main.async {
                completionHandler(result)
            }
        }
        queueManager.queue(operation)
        currentOperation = operation
    }
    
    func requestImage(for breed: Breed,
                      completionHandler: @escaping ((Result<UIImage, Error>) -> Void)) {
        guard let url = URL(string: breed.url) else {
            completionHandler(.failure(APIError.invalidImageLink))
            return
        }
        let operation = CacheImageOperation(url: url, urlSession: session)
        operation.completionHandler = { [weak self] result in
            guard let self = self else { return }
            DispatchQueue.main.async {
                completionHandler(result)
                self.loadImageOperations.removeValue(forKey: breed.id)
            }
        }
        queueManager.queue(operation)
        loadImageOperations[breed.id] = operation
    }
    
    func cancelRequestImage(for breed: Breed) {
        guard let operation = loadImageOperations[breed.id] else { return }
        operation.cancel()
        loadImageOperations.removeValue(forKey: breed.id)
    }
}
