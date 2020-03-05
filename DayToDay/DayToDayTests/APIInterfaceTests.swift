//
//  APIInterfaceTests.swift
//  DayToDayTests
//
//  Created by Matrix 1 MBP on 04/03/20.
//  Copyright © 2020 Matrix 1 MBP. All rights reserved.
//

import XCTest
@testable import DayToDay

class APIInterfaceTests: XCTestCase {
    
    var apiInterface: APIInterface?
    var helperClass: HelperClass?
    
    override func setUp() {
        super.setUp()
        
    }

    override func tearDown() {
        apiInterface = nil
        super.tearDown()
    }

    func testBaseURL() {

//        // When fetch popular photo
        let expect = XCTestExpectation(description: "callback")

        let error = APIError.notProperBaseURL
        
        if APIInterface.baseURL != "https://api.themoviedb.org/3/discove" {
            expect.fulfill()
            XCTAssertNotEqual(helperClass?.alertMessage, error.rawValue)
        } else {
            
     //       print("the base URL is correct")
        }
        wait(for: [expect], timeout: 20.0)
    }
}
