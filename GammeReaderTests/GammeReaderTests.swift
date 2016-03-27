//
//  GammeReaderTests.swift
//  GammeReaderTests
//
//  Created by YehYungCheng on 2016/3/26.
//  Copyright © 2016年 YehYungCheng. All rights reserved.
//

import XCTest
@testable import GammeReader

class GammeReaderTests: XCTestCase {
    
    override func setUp() {
        super.setUp()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }
    
    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
        super.tearDown()
    }
    
    func testDownload() {
        let url = "https://m.gamme.com.tw/category/all"
        let expectation = expectationWithDescription("GET \(url)")
        let manager = DownloadManager(url: url) { (data) in
            expectation.fulfill()
            XCTAssertNotNil(data, "DownloadManager Success")
        }
        manager.fail = {
            XCTFail("DownloadManager fail")
        }
        manager.connect()
        
        waitForExpectationsWithTimeout(10, handler:nil)
    }
    
    func testParser() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        
        
        let url = "https://m.gamme.com.tw/category/all"
        let expectation = expectationWithDescription("GET \(url)")
        
        let vc = ViewController()
        vc.downloadHTML("https://m.gamme.com.tw/category/all") { (data) in
            expectation.fulfill()
            XCTAssertTrue(data.count > 0, "parser is working")
        }
        
        waitForExpectationsWithTimeout(10, handler:nil)
    }
    
    func testPerformanceExample() {
        // This is an example of a performance test case.
        self.measureBlock {
            // Put the code you want to measure the time of here.
        }
    }
    
}
