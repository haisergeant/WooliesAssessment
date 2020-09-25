//
//  QueueManagerTests.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//

import XCTest
@testable import WooliesAssessment

class LongOperation: BaseOperation<Int> {
    let id: Int
    let duration: Double
    var executingBlock: (() -> Void)?
    
    init(id: Int, duration: Double, executingBlock: (() -> Void)? = nil) {
        self.id = id
        self.duration = duration
        self.executingBlock = executingBlock
    }
    
    override func main() {
        print("start id: \(id)")
        executingBlock?()
        DispatchQueue.main.asyncAfter(deadline: .now() + duration) {
            print("complete id: \(self.id)")
            self.complete(result: .success(self.id))
        }
    }
}

class QueueManagerTests: XCTestCase {

    /**
     Test Manager with max concurrent operation is 1. The second operation only executes when the first operation finish
     */
    func testManagerWithOneCurrentOperation() {
        let expectation1 = self.expectation(description: "First operation finished")
        let expectation2 = self.expectation(description: "Second operation finished")
        
        let manager = QueueManager(maxConcurrentOperationCount: 1)
        
        let firstOperation = LongOperation(id: 1, duration: 1)
        let secondOperation = LongOperation(id: 2, duration: 1)
        
        firstOperation.executingBlock = {
            XCTAssertFalse(secondOperation.isExecuting, "Second operation should wait for first operation finish")
        }
        firstOperation.completionHandler = { _ in
            expectation1.fulfill()
        }
        
        secondOperation.executingBlock = {
            XCTAssertTrue(firstOperation.isFinished, "First operation should be finished")
        }
        secondOperation.completionHandler = { _ in
            expectation2.fulfill()
        }
        manager.queue(firstOperation)
        manager.queue(secondOperation)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
    
    /**
     Test Manager with 2 concurrent operations. Maximum 2 operations can be executed at the same time. The third operation should wait either first 2 operations finished before executing.
     */
    func testManagerWithTwoCurrentOperation() {
        let manager = QueueManager(maxConcurrentOperationCount: 2)
        
        let expectation1 = self.expectation(description: "First operation finished")
        let expectation2 = self.expectation(description: "Second operation finished")
        let expectation3 = self.expectation(description: "Third operation finished")
        let firstOperation = LongOperation(id: 1, duration: 1)
        let secondOperation = LongOperation(id: 2, duration: 1)
        let thirdOperation = LongOperation(id: 3, duration: 1)
        firstOperation.executingBlock = {
            XCTAssertTrue(secondOperation.isExecuting, "Second operation should execuate same time with first operation")
            XCTAssertFalse(thirdOperation.isExecuting, "Third operation should not start yet")
        }
        firstOperation.completionHandler = { _ in
            expectation1.fulfill()
        }
        
        secondOperation.executingBlock = {
            XCTAssertTrue(firstOperation.isExecuting, "First operation should execuate same time with second operation")
            XCTAssertFalse(thirdOperation.isExecuting, "Third operation should not start yet")
        }
        secondOperation.completionHandler = { _ in
            expectation2.fulfill()
        }
        
        thirdOperation.executingBlock = {
            XCTAssertTrue(firstOperation.isFinished || secondOperation.isFinished, "First or second operations should finish before third operation")            
        }
        thirdOperation.completionHandler = { _ in
            expectation3.fulfill()
        }
        
        manager.queue(firstOperation)
        manager.queue(secondOperation)
        manager.queue(thirdOperation)
        
        waitForExpectations(timeout: 10, handler: nil)
    }
}

