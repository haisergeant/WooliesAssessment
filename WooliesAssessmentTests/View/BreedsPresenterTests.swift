//
//  BreedsPresenterTests.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import XCTest
@testable import WooliesAssessment

class MockBreedsViewController: BreedsPresenterToViewProtocol {
    var presenter: BreedsViewToPresenterProtocol!
    
    var displayDataCalled = false
    var displayErrorCalled = false
    
    func reset() {
        displayDataCalled = false
        displayErrorCalled = false
    }
    
    func displayData(_ viewModels: [BreedTableViewCellModel]) {
        displayDataCalled = true
    }
    
    func displayError(message: String) {
        displayErrorCalled = true
    }
}

class MockBreedsInteractor: BreedsPresenterToInteractorProtocol {
    var requestDataCalled = false
    var requestImageCalled = false
    var cancelRequestImageCalled = false
    
    weak var presenter: BreedsInteractorToPresenterProtocol?
    
    var breeds: [Breed]?
    var error: Error?
    
    var image: UIImage?
    var imageError: Error?
    
    func reset() {
        requestDataCalled = false
        requestImageCalled = false
        cancelRequestImageCalled = false
        
        breeds = nil
        error = nil
           
        image = nil
        imageError = nil
    }
        
    func requestData() {
        requestDataCalled = true
        if let breeds = breeds {
            presenter?.didFetchData(breeds)
        } else if let error = error {
            presenter?.handleError(error)
        }
    }
    
    func requestImage(for breed: Breed) {
        requestImageCalled = true       
        if let image = image {
            presenter?.didFetchImage(for: breed, image: image)
        } else if let error = imageError {
            presenter?.didFailFetchImage(for: breed, error: error)
        }
    }
        
    func cancelRequestImage(for breed: Breed) {
        cancelRequestImageCalled = true
    }
}

class BreedsPresenterTests: XCTestCase {
    let viewController = MockBreedsViewController()
    let interactor = MockBreedsInteractor()
    var presenter: BreedsPresenter?
    
    override func setUp() {
        viewController.reset()
        interactor.reset()
        presenter = BreedsPresenter(view: viewController,
                                    interactor: interactor)
        viewController.presenter = presenter
        interactor.presenter = presenter
    }
    
    func testFetchDataSuccess() {
        interactor.breeds = [
            Breed(id: "111", url: "tick.png", breeds: [BreedItem(id: 1, name: "Beggie", lifeSpan: "8 - 10 years")]),
            Breed(id: "112", url: "tick.png", breeds: [BreedItem(id: 2, name: "Chihuahua", lifeSpan: "8 - 10 years")])
        ]
        
        presenter?.fetchData()
        XCTAssertTrue(interactor.requestDataCalled)
        XCTAssertTrue(viewController.displayDataCalled)
    }
    
    func testFetchDataFail() {
        interactor.error = APIError.invalidAPIError
        presenter?.fetchData()
        
        XCTAssertTrue(interactor.requestDataCalled)
        XCTAssertTrue(viewController.displayErrorCalled)
    }
    
    func testRequestImageSuccess() {
        interactor.breeds = [
            Breed(id: "111", url: "tick.png", breeds: [BreedItem(id: 1, name: "Beggie", lifeSpan: "8 - 10 years")]),
            Breed(id: "112", url: "tick.png", breeds: [BreedItem(id: 2, name: "Chihuahua", lifeSpan: "8 - 10 years")])
        ]
        let bundle = Bundle(for: BreedsPresenterTests.self)
        interactor.image = UIImage(named: "tick", in: bundle, compatibleWith: nil)
        
        presenter?.fetchData()
        presenter?.requestDataForCellIfNeeded(at: 0)
        
        XCTAssertTrue(interactor.requestImageCalled)
        switch presenter?.viewModels[0].imageState.value {
        case .loadedImage:
            XCTAssertTrue(true)
        default:
            XCTFail("Image should be loaded")
        }
    }
    
    func testRequestImageFail() {
        interactor.breeds = [
            Breed(id: "111", url: "tick.png", breeds: [BreedItem(id: 1, name: "Beggie", lifeSpan: "8 - 10 years")]),
            Breed(id: "112", url: "tick.png", breeds: [BreedItem(id: 2, name: "Chihuahua", lifeSpan: "8 - 10 years")])
        ]
        
        interactor.imageError = APIError.invalidImageLink
        
        presenter?.fetchData()
        presenter?.requestDataForCellIfNeeded(at: 0)
        
        XCTAssertTrue(interactor.requestImageCalled)
        switch presenter?.viewModels[0].imageState.value {
        case .fail:
            XCTAssertTrue(true)
        default:
            XCTFail("Image cannot loaded")
        }
    }
    
    func testCancelRequestImage() {
        interactor.breeds = [
            Breed(id: "111", url: "tick.png", breeds: [BreedItem(id: 1, name: "Beggie", lifeSpan: "8 - 10 years")]),
            Breed(id: "112", url: "tick.png", breeds: [BreedItem(id: 2, name: "Chihuahua", lifeSpan: "8 - 10 years")])
        ]
        
        presenter?.fetchData()
        presenter?.stopRequestDataForCell(at: 0)
        
        XCTAssertTrue(interactor.cancelRequestImageCalled)
    }

}
