//
//  CacheImageOperationTests.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//

import XCTest

@testable import WooliesAssessment

class CacheImageOperationTests: XCTestCase {
    
    let queue = OperationQueue()
    
    override func setUp() {
        queue.cancelAllOperations()
        
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                 .userDomainMask,
                                                                 true).first!
        let downloadFolder = cacheDirectory + "/" + "Download"
        try? FileManager.default.removeItem(atPath: downloadFolder)
    }

    func testImageDownloadSuccess() {
        let session = MockURLSession()
        let bundle = Bundle(for: CacheImageOperationTests.self)
        let imageData = UIImage(named: "tick", in: bundle, compatibleWith: nil)?.pngData()
        let imageJPGData = UIImage(named: "tick", in: bundle, compatibleWith: nil)?.jpegData(compressionQuality: 1)
        session.data = imageData
        
        let fileManager = MockFileManager(fileExist: false)
        let url = URL(string: "www.google.com")!
        
        let expectation = self.expectation(description: "Calling API which returns image")
        let operation = CacheImageOperation(url: url,
                                            urlSession: session,
                                            fileManager: fileManager)
        operation.completionHandler = { result in
            XCTAssertTrue(operation.isFinished, "Operation must be finished")
            XCTAssert(session.lastURLRequest?.url?.absoluteString == "www.google.com", "URL should be www.google.com")
            XCTAssert(session.nextDataTask.resumeWasCalled, "Data task should be called")
            
            if case .success(let image) = result {
                XCTAssert(image.size == UIImage(data: imageJPGData!)!.size, "The loaded image should be `tick` image")
                expectation.fulfill()
            } else if case .failure = result {
                XCTAssertFalse(true, "API should be success")
            }
        }
        
        queue.addOperation(operation)
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testImageDownloadFail() {
        let session = MockURLSession()
        session.error = APIError.invalidImageLink
        
        let fileManager = MockFileManager(fileExist: false)
        let url = URL(string: "www.google.com")!
        
        let expectation = self.expectation(description: "Calling API returns error")
        let operation = CacheImageOperation(url: url, urlSession: session, fileManager: fileManager)
        operation.completionHandler = { result in
            XCTAssertTrue(operation.isFinished, "Operation must be finished")
            XCTAssert(session.lastURLRequest?.url?.absoluteString == "www.google.com", "URL should be www.google.com")
            XCTAssert(session.nextDataTask.resumeWasCalled, "Data task should be called")
            
            if case .success = result {
                XCTAssertFalse(true, "API should be fail")
            } else if case .failure(let error) = result {
                XCTAssertEqual(error as? APIError, APIError.invalidImageLink)
                expectation.fulfill()
            }
        }
        
        queue.addOperation(operation)
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testImageGetFromFileSystemFail() {
        let session = MockURLSession()
        
        let fileManager = MockFileManager(fileExist: true)
        let url = URL(string: "www.google.com")!
        
        let expectation = self.expectation(description: "Get image from file system but fail")
        let operation = CacheImageOperation(url: url, urlSession: session, fileManager: fileManager)
        operation.completionHandler = { result in
            XCTAssertTrue(operation.isFinished, "Operation must be finished")
            XCTAssert(session.lastURLRequest == nil, "Get file from file system, should not call URL")
            XCTAssert(!session.nextDataTask.resumeWasCalled, "Data task should not be called")
            
            if case .success = result {
                XCTAssertFalse(true, "API should be fail")
            } else if case .failure(let error) = result {
                XCTAssertEqual(error as? APIError, APIError.invalidImageLink)
                expectation.fulfill()
            }
        }
        
        queue.addOperation(operation)
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
    
    func testImageGetFromFileSystemSuccess() {
        // create the image file in file system
        let bundle = Bundle(for: CacheImageOperationTests.self)
        let imageData = UIImage(named: "tick", in: bundle, compatibleWith: nil)!.pngData()!
        
        let cacheDirectory = NSSearchPathForDirectoriesInDomains(.cachesDirectory,
                                                                 .userDomainMask,
                                                                 true).first!
        let downloadFolder = cacheDirectory + "/" + "Download"
        
        let filePath = downloadFolder + "/" + "tick.png"
        do {
            try FileManager.default.createDirectory(atPath: downloadFolder,
                                                    withIntermediateDirectories: true,
                                                    attributes: nil)
            let url = URL(fileURLWithPath: filePath)
            try imageData.write(to: url)
        } catch {
            print("cannot write the image to file")
        }
        
        // begin the test
        let session = MockURLSession()
        
        let fileManager = MockFileManager(fileExist: true)
        let url = URL(string: "www.google.com/tick.png")!
        
        let expectation = self.expectation(description: "Get image from file system")
        let operation = CacheImageOperation(url: url, urlSession: session, fileManager: fileManager)
        operation.completionHandler = { result in
            XCTAssertTrue(operation.isFinished, "Operation must be finished")
            XCTAssert(session.lastURLRequest == nil, "Get file from file system, should not call URL")
            XCTAssert(!session.nextDataTask.resumeWasCalled, "Data task should not be called")
            
            if case .success(let image) = result {
                XCTAssertEqual(image.pngData(), imageData)
                expectation.fulfill()
            } else if case .failure = result {
                XCTAssertFalse(true, "API should be success")
            }
        }
        
        queue.addOperation(operation)
        
        waitForExpectations(timeout: 10.0, handler: nil)
    }
}
