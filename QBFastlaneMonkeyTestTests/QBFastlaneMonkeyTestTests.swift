//
//  QBFastlaneMonkeyTestTests.swift
//  QBFastlaneMonkeyTestTests
//
//  Created by Jarvis on 2016/11/2.
//  Copyright © 2016年 Hangzhou Enter Electronic Technology Co., Ltd. All rights reserved.
//

import XCTest

@testable import QBFastlaneMonkeyTest

class QBFastlaneMonkeyTestTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testExample() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct
        
        XCTAssert(1 == (2-1))
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
}
