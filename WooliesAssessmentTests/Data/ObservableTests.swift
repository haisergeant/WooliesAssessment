//
//  ObservableTests.swift
//
//  Created by Hai Le Thanh.
//  Copyright © 2020 Hai Le Thanh. All rights reserved.
//

import XCTest
@testable import WooliesAssessment

class ObservableTests: XCTestCase {
    /**
     Test observable Int value when the value change, it will call the closure.
     */
    func testObserveInt() {
        let observable = Observable<Int>(0)
        
        let expectation = self.expectation(description: "Changing value will trigger valueChanged closure")
        observable.valueChanged = { value in
            XCTAssertEqual(value, 5)
            expectation.fulfill()
        }
        
        observable.value = 5
        waitForExpectations(timeout: 2.0, handler: nil)
    }
    
    class ObservableClass {
        let observableProperty = Observable<Int>(0)
    }
    
    /**
     Test observable with property of custom class.
     */

    func testObservePropertyOfClass() {
        let instance = ObservableClass()
        let expectation = self.expectation(description: "Changing value of property will trigger valueChanged closure")
        instance.observableProperty.valueChanged = { value in
            XCTAssertEqual(value, 10)
            expectation.fulfill()
        }
        
        instance.observableProperty.value = 10
        waitForExpectations(timeout: 2.0, handler: nil)
    }
}
