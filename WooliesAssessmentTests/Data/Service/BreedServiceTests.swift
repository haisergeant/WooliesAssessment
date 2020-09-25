//
//  BreedServiceTests.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//
	

import XCTest
@testable import WooliesAssessment

class BreedServiceTests: XCTestCase {
    private let queueManager = QueueManager.shared
    private let session = MockURLSession()
    
    override func setUp() {
        queueManager.cancelAllOperations()
        session.data = nil
        session.error = nil
    }
    
    func testRequestDataSuccess() {
        session.data = StubData.loadStubData(fileName: "validJSON", ext: "json")
        let service = BreedService(queueManager: QueueManager.shared, session: session)
        
        let expectation = self.expectation(description: "Receive valid JSON")
        service.requestBreed { result in
            switch result {
            case .success(let list):
                XCTAssertTrue(list.count == 1)
                expectation.fulfill()
            case .failure:
                XCTFail("Should receive valid response")
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testRequestDataFail() {
        session.data = StubData.loadStubData(fileName: "invalidJSON", ext: "json")
        let service = BreedService(queueManager: QueueManager.shared, session: session)
        
        let expectation = self.expectation(description: "Receive invalid JSON")
        service.requestBreed { result in
            switch result {
            case .success:
                XCTFail("Should receive invalid response")
            case .failure(let error):
                if case APIError.jsonFormatError = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail("Should return invalid JSON")
                }
                
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testRequestImageSuccess() {
        let bundle = Bundle(for: BreedServiceTests.self)
        let imageJPGData = UIImage(named: "tick", in: bundle, compatibleWith: nil)?.jpegData(compressionQuality: 1)
        
        session.data = imageJPGData
        let service = BreedService(queueManager: QueueManager.shared, session: session)
        
        let expectation = self.expectation(description: "Receive valid JSON")
        service.requestImage(for: Breed(id: "1", url: "tick.png", breeds: [])) { result in
            switch result {
            case .success(let image):
                XCTAssertTrue(image.jpegData(compressionQuality: 1) == imageJPGData)
                expectation.fulfill()
            case .failure:
                XCTFail("Should receive valid image")
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
    
    func testRequestImageFail() {
        session.error = APIError.invalidImageLink
        let service = BreedService(queueManager: QueueManager.shared, session: session)
        
        let expectation = self.expectation(description: "Receive valid JSON")
        service.requestImage(for: Breed(id: "1", url: "tick.xyz", breeds: [])) { result in
            switch result {
            case .success:
                XCTFail("Should receive error")
            case .failure(let error):
                if case APIError.invalidImageLink = error {
                    XCTAssertTrue(true)
                } else {
                    XCTFail("Should return image link error")
                }
                expectation.fulfill()
            }
        }
        wait(for: [expectation], timeout: 2.0)
    }
}

