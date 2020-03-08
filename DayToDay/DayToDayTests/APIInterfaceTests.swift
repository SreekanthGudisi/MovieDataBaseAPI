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
    
    override func setUp() {
        super.setUp()
        
    }

    override func tearDown() {
        apiInterface = nil
        super.tearDown()
    }

    func testBaseURL() {

        let expect = XCTestExpectation(description: "callback")

        if APIInterface.baseURL != "https://api.themoviedb.org/3/discover" {
            expect.fulfill()
            XCTAssert(false, "Base URL is not matching")
        } else {
            expect.fulfill()
            XCTAssert(true, "Base URL is matching")
        }
        wait(for: [expect], timeout: 30.0)
    }
    
    func testMethodURL() {

        let expect = XCTestExpectation(description: "callback")

        if GetMovieDataBaseAPI.methodName != "/movie?api_key=" {
            expect.fulfill()
            XCTAssert(false, "Method name is not matching")
        } else {
            expect.fulfill()
            XCTAssert(true, "Method name is matching")
        }
        wait(for: [expect], timeout: 30.0)
    }
    
    func testAPIKeyURL() {

        let expect = XCTestExpectation(description: "callback")

        if GlobalVariableInformation.instance().apiKeyString != "a37bdd7b84b703a56a33bbdf2e5ec716" {
            expect.fulfill()
            XCTAssert(false, "Method name is not matching")
        } else {
            expect.fulfill()
            XCTAssert(true, "Method name is matching")
        }
        wait(for: [expect], timeout: 30.0)
    }
}
