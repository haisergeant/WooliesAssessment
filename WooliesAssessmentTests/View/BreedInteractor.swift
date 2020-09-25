//
//  BreedInteractor.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import XCTest
@testable import WooliesAssessment

class MockBreedService: BreedServiceProtocol {
    var breeds: [Breed]?
    var error: Error?
    
    var image: UIImage?
    var imageError: Error?
    
    func reset() {
        breeds = nil
        error = nil
        
        image = nil
        imageError = nil
    }
    
    func requestBreed(completionHandler: @escaping ((Result<[Breed], Error>) -> Void)) {
        if let breeds = breeds {
            completionHandler(.success(breeds))
        } else if let error = error {
            completionHandler(.failure(error))
        }
    }
    
    func requestImage(for breed: Breed, completionHandler: @escaping ((Result<UIImage, Error>) -> Void)) {
        if let image = image {
            completionHandler(.success(image))
        } else if let error = imageError {
            completionHandler(.failure(error))
        }
    }
    
    func cancelRequestImage(for breed: Breed) {
        
    }
}

class MockBreedsPresenter: BreedsInteractorToPresenterProtocol {
    var didFetchDataCalled = false
    var didFetchDataFailError = false
    var didFetchImage = false
    var didFetchImageFail = false
    
    func reset() {
        didFetchDataCalled = false
        didFetchDataFailError = false
        didFetchImage = false
        didFetchImageFail = false
    }
    
    func didFetchData(_ breeds: [Breed]) {
        didFetchDataCalled = true
    }
    
    func handleError(_ error: Error) {
        didFetchDataFailError = true
    }
    
    func didFetchImage(for breed: Breed, image: UIImage) {
        didFetchImage = true
    }
    
    func didFailFetchImage(for breed: Breed, error: Error) {
        didFetchImageFail = true
    }
}

class BreedsInteractorTests: XCTestCase {
    let presenter = MockBreedsPresenter()
    let service = MockBreedService()
    override func setUp() {
        presenter.reset()
        service.reset()
    }
    
    func testRequestDataSuccess() {
        service.breeds = [Breed(id: "111", url: "tick.png", breeds: [BreedItem(id: 1, name: "Beggie", lifeSpan: "8 - 10 years")])]
        
        let interactor = BreedsInteractor(service: service)
        interactor.presenter = presenter
        interactor.requestData()
        
        XCTAssertTrue(presenter.didFetchDataCalled)
        XCTAssertFalse(presenter.didFetchDataFailError)
    }
    
    func testRequestDataFail() {
        service.error = APIError.invalidAPIError
        
        let interactor = BreedsInteractor(service: service)
        interactor.presenter = presenter
        interactor.requestData()
        
        XCTAssertFalse(presenter.didFetchDataCalled)
        XCTAssertTrue(presenter.didFetchDataFailError)
    }
    
    func testRequestImageSuccess() {
        let bundle = Bundle(for: BreedsInteractorTests.self)
        let imageData = UIImage(named: "tick", in: bundle, compatibleWith: nil)        
        service.image = imageData
        let breed = Breed(id: "111",
                          url: "tick.png",
                          breeds: [BreedItem(id: 1,
                                             name: "Beggie",
                                             lifeSpan: "8 - 10 years")])
        
        let interactor = BreedsInteractor(service: service)
        interactor.presenter = presenter
        interactor.requestImage(for: breed)
        
        XCTAssertTrue(presenter.didFetchImage)
        XCTAssertFalse(presenter.didFetchImageFail)
    }
    
    func testRequestImageFail() {
        service.imageError = APIError.invalidImageLink
        let breed = Breed(id: "111",
                          url: "tick.png",
                          breeds: [BreedItem(id: 1,
                                             name: "Beggie",
                                             lifeSpan: "8 - 10 years")])
        
        let interactor = BreedsInteractor(service: service)
        interactor.presenter = presenter
        interactor.requestImage(for: breed)
        
        XCTAssertFalse(presenter.didFetchImage)
        XCTAssertTrue(presenter.didFetchImageFail)
    }
}
