//
//  BreedsInteractor.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import Foundation
import UIKit

protocol BreedsPresenterToInteractorProtocol {
    func requestData()
    func requestImage(for breed: Breed)
    func cancelRequestImage(for breed: Breed)
}

protocol BreedsInteractorToPresenterProtocol: class {
    func didFetchData(_ breeds: [Breed])
    func handleError(_ error: Error)
    
    func didFetchImage(for breed: Breed, image: UIImage)
    func didFailFetchImage(for breed: Breed, error: Error)
}

class BreedsInteractor: BreedsPresenterToInteractorProtocol {
    private let service: BreedServiceProtocol
    weak var presenter: BreedsInteractorToPresenterProtocol?
    
    init(service: BreedServiceProtocol) {
        self.service = service
    }
    
    func requestData() {
        service.requestBreed { [weak self] result in
            switch result {
            case .success(let breeds):
                self?.presenter?.didFetchData(breeds)
            case .failure(let error):
                self?.presenter?.handleError(error)
            }
        }
    }
    
    func requestImage(for breed: Breed) {
        service.requestImage(for: breed) { result in
            switch result {
            case .success(let image):
                self.presenter?.didFetchImage(for: breed, image: image)
            case .failure(let error):
                self.presenter?.didFailFetchImage(for: breed, error: error)
            }
        }        
    }
    
    func cancelRequestImage(for breed: Breed) {
        service.cancelRequestImage(for: breed)
    }
}
