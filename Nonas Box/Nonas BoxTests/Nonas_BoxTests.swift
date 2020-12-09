//
//  Nonas_BoxTests.swift
//  Nonas BoxTests
//
//  Created by Jason Ruan on 11/20/19.
//  Copyright © 2019 Jason Ruan. All rights reserved.
//

import XCTest
@testable import Nonas_Box

class Nonas_BoxTests: XCTestCase {

    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testRecipeFetchingService() {
        let expectation = self.expectation(description: "The SpoonacularAPIClient should complete asynchronous call and successfully return recipes")
        SpoonacularAPIClient.manager.getRecipes(query: "chicken") { (result) in
            switch result {
                case .failure(let error):
                    XCTFail("Asynchronous call to Spoonacular endpoint failed to complete, with error: \(error)")
                case .success(let spoonacularResults):
                    guard let fetchedRecipes = spoonacularResults.results else {
                        return XCTFail("Asynchronous call to Spoonacular endpoint completed successfully but did not return recipes for query")
                    }
                    XCTAssert(!fetchedRecipes.isEmpty, "Spoonacular call should return at least 1 recipe for provided query")
            }
            expectation.fulfill()
        }
        
        waitForExpectations(timeout: 5) { (error) in
            if let error = error {
                XCTFail("Test for Spoonacular recipe fetch timed out with error: \(error)")
            }
        }
        
    }

}
