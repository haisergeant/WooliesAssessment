//
//  JSONDataRequestOperationTests.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//

import XCTest
@testable import WooliesAssessment

struct StubData {
    static func loadStubData(fileName: String, ext: String) -> Data {
        let bundle = Bundle(for: JSONDataRequestOperationTests.self)
        let url = bundle.url(forResource: fileName, withExtension: ext)
        return try! Data(contentsOf: url!)
    }
}

class JSONDataRequestOperationTests: XCTestCase {
    let queue = OperationQueue()
    
    override func setUp() {
        queue.cancelAllOperations()
    }
    
    func testAPIRequestSuccess() {
        let session = MockURLSession()
        session.data = StubData.loadStubData(fileName: "validJSON", ext: "json")
        
        let url = URL(string: "www.google.com")!
        
        let expectation = self.expectation(description: "Calling API which returns correct format")
        let operation = JSONDataRequestOperation<[Breed]>(url: url, urlSession: session)
        operation.completionHandler = { result in
            XCTAssertTrue(operation.isFinished, "Operation must be finished")

            XCTAssert(session.lastURLRequest?.url?.absoluteString == "www.google.com", "URL should be www.google.com")
            XCTAssert(session.nextDataTask.resumeWasCalled, "Data task should be called")
            
            if case .success(let data) = result {
                XCTAssertEqual(data.count, 1)
                expectation.fulfill()
            } else if case .failure = result {
                XCTAssertFalse(true, "API should be success")
            }
            
        }
        
        queue.addOperation(operation)
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testAPIRequestReturnError() {
        let session = MockURLSession()
        session.error = APIError.invalidAPIError
        
        let url = URL(string: "www.google.com")!
        
        let expectation = self.expectation(description: "Calling API which returns error")
        let operation = JSONDataRequestOperation<[Breed]>(url: url, urlSession: session)
        operation.completionHandler = { result in
            XCTAssertTrue(operation.isFinished, "Operation must be finished")
            XCTAssert(session.lastURLRequest?.url?.absoluteString == "www.google.com", "URL should be www.google.com")
            XCTAssert(session.nextDataTask.resumeWasCalled, "Data task should be called")
            
            if case .success = result {
                XCTAssertFalse(true, "API should be fail")
                
            } else if case .failure(let error) = result {
                XCTAssertEqual(error as? APIError, APIError.invalidAPIError)
                expectation.fulfill()
            }
            
        }
        
        queue.addOperation(operation)
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testAPIRequestReturnInvalidFormat() {
        let session = MockURLSession()
        session.data = StubData.loadStubData(fileName: "invalidJSON", ext: "json")
        
        let url = URL(string: "www.google.com")!
        
        let expectation = self.expectation(description: "Calling API which returns invalid format")
        let operation = JSONDataRequestOperation<[Breed]>(url: url, urlSession: session)
        operation.completionHandler = { result in
            XCTAssertTrue(operation.isFinished, "Operation must be finished")
            XCTAssert(session.lastURLRequest?.url?.absoluteString == "www.google.com", "URL should be www.google.com")
            XCTAssert(session.nextDataTask.resumeWasCalled, "Data task should be called")
            
            if case .success = result {
                XCTAssertFalse(true, "API should be fail")
            } else if case .failure(let error) = result {
                XCTAssertEqual(error as? APIError, APIError.jsonFormatError)
                expectation.fulfill()
            }
            
        }
        
        queue.addOperation(operation)
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testAPIRequestIntArray() {
        let session = MockURLSession()
        session.data = "[1,2,3,4,5]".data(using: .ascii)
        
        let url = URL(string: "www.google.com")!
        
        let expectation = self.expectation(description: "Calling API which returns Int array")
        let operation = JSONDataRequestOperation<[Int]>(url: url, urlSession: session)
        operation.completionHandler = { result in
            XCTAssertTrue(operation.isFinished, "Operation must be finished")
            if case .success(let values) = result {
                XCTAssertTrue(values.count == 5)
                expectation.fulfill()
            } else if case .failure = result {
                XCTAssertFalse(true, "API should be fail")
            }
        }
        
        queue.addOperation(operation)
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
}
