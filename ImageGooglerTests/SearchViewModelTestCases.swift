//
//  SearchViewModelTestCases.swift
//  imageGoogler
//
//  Created by Radha Phani Krishna Sunkara on 30/10/18.
//  Copyright © 2018 Radha Phani Krishna Sunkara. All rights reserved.
//

import XCTest
@testable import ImageGoogler

class SearchViewModelTestCases: XCTestCase {
    
    let searchVM = SearchViewModel()
    var asyncExpectation:XCTestExpectation?
    
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
        searchVM.delegate = self
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBasicSearch() {
        searchVM.searchImages(for: "apples")
        asyncExpectation = expectation(description: "Basic search")
        self.waitForExpectations(timeout: 50) { error in
            if error != nil  {
                XCTFail("Taking too much time to get response")
            } else {
                XCTAssert(true);
            }
        }
        
        if searchVM.imageViewModels.count > 0 &&  searchVM.messageString.contains(SearchViewModel.infoMessage) {
            XCTAssert(true)
        } else {
            XCTFail("Basic search for apples not working")
        }
    }
    
    func testFetchMoreImages(){
        let currentCount = searchVM.imageViewModels.count
        searchVM.fetchMoreImages(for: "apples")
        asyncExpectation = expectation(description: "Fetch more search")
        self.waitForExpectations(timeout: 50) { error in
            if error != nil {
                XCTFail("Taking too much time to get response")
            } else {
                XCTAssert(true);
            }
        }
        
        if searchVM.imageViewModels.count > currentCount &&  searchVM.messageString.contains(SearchViewModel.infoMessage) {
            XCTAssert(true)
        } else {
            XCTFail("Basic search for apples not working")
        }
    }
    
    func testClearSearch() {
        searchVM.clearImages()
        if searchVM.messageString == SearchViewModel.startMessage {
            XCTAssert(true);
        } else {
            XCTFail("Images not cleared");
        }
    }
    
    func testForZeroResultSearch() {
        searchVM.searchImages(for: "App0le$")
        asyncExpectation = expectation(description: "Basic search")
        self.waitForExpectations(timeout: 50) { error in
            if error != nil {
                XCTFail("Taking too much time to get response")
            } else {
                XCTAssert(true);
            }
        }
        
        if searchVM.imageViewModels.count == 0 &&  searchVM.messageString == SearchViewModel.noResultsMessage  {
            XCTAssert(true)
        } else {
            XCTFail("Basic search for apples not working")
        }
    }
    
    func testForFailResultSearch() {
        let mockResponse: [String: Any] = ["message":"Sorry, the Flickr search API is not currently available.", "stat" : "fail"]
        searchVM.formImageModels(from: mockResponse)
        asyncExpectation = expectation(description: "Error response")
        self.waitForExpectations(timeout: 10) { error in
            if error != nil {
                XCTFail("Taking too much time to parse response")
            } else {
                XCTAssert(true);
            }
        }
        
        if searchVM.messageString != mockResponse["message"] as! String {
            XCTFail("parser failed for fail response from flickr")
        }
    
        XCTAssert(true);
    }
    
    func testForEmptyResponseSearch() {
        let noMockResponse: [String: Any] = [String: Any]()
        searchVM.formImageModels(from: noMockResponse)
        asyncExpectation = expectation(description: "Error response")
        self.waitForExpectations(timeout: 10) { error in
            if error != nil {
                XCTFail("Taking too much time to parse response")
            } else {
                XCTAssert(true);
            }
        }
        if searchVM.messageString != SearchViewModel.genericError {
            XCTFail("parser failed for no response from flickr")
        }
        XCTAssert(true);
    }

}

extension SearchViewModelTestCases: SearchViewModelDelegate {
    func updatedContent() {
        asyncExpectation?.fulfill()
    }
}
