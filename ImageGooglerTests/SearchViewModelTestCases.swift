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
        
        if searchVM.imageViewModels.count > 0 &&  searchVM.searchState == .success {
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
        
        if searchVM.imageViewModels.count > currentCount &&  searchVM.searchState == .success  {
            XCTAssert(true)
        } else {
            XCTFail("Basic search for apples not working")
        }
    }
    
    func testClearSearch() {
        searchVM.clearImages()
        if searchVM.searchState != .initial {
            XCTFail("Images not cleared");
        }
        searchVM.searchState = .success
        searchVM.clearImages()
        if searchVM.searchState == .initial {
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
        
        if searchVM.imageViewModels.count == 0 &&  searchVM.searchState == .noResult  {
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
        if searchVM.searchState != .failed {
            XCTFail("parser failed for no response from flickr")
        }
        XCTAssert(true);
    }
    
    func testForPartialImageModels() {
        let mockString = "{\"photos\":{\"page\":1,\"pages\":798,\"perpage\":100,\"total\":\"79740\",\"photo\":[{\"id\":\"45636051211\",\"owner\":\"42437950@N00\",\"secret\":\"e11f7c7fcf\",\"server\":\"1975\",\"farm\":2,\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"30694321407\",\"owner\":\"76097431@N04\",\"secret\":\"70f61ff7dd\",\"server\":\"1939\",\"farm\":2,\"title\":\"Screenshot from the Affirm Your Life Affirmations app > http://bit.ly/AffirmYourLifeiPhoneApp #iPhone #app #affirmations\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"30694318327\",\"owner\":\"76097431@N04\",\"secret\":\"0808dd3686\",\"server\":\"1949\",\"farm\":2,\"title\":\"Screenshot from the Fit-Inspired Woman app > http://bit.ly/FitInspiredWomaniPhoneApp #iPhone #app #fitness\",\"isfriend\":0,\"isfamily\":0},{\"id\":\"31761976988\",\"owner\":\"148230778@N03\",\"secret\":\"e00eabe600\",\"server\":\"1917\",\"farm\":2,\"title\":\"Listen to Episode 72 of Clever: Cory Grosser\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"43816254820\",\"owner\":\"27889738@N07\",\"server\":\"1975\",\"farm\":2,\"title\":\"Taxi at West Entrance of the Low-ceilinged Tunnel at the North of Shinagawa 4\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"owner\":\"61084128@N08\",\"secret\":\"7b62fa2e5e\",\"server\":\"1951\",\"farm\":2,\"title\":\"プリプロ @ #mostdangerousstudio #madfisherrecordings\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"44720110535\",\"secret\":\"028cbdd739\",\"server\":\"1934\",\"farm\":2,\"title\":\"HyperDrive 3-in-1 Connection Kit for USB Type-C Smartphone, 2016 MacBook Pro & 12″ MacBook\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0},{\"id\":\"45633710771\",\"owner\":\"155896017@N08\",\"secret\":\"4d0a5e74de\",\"server\":\"1959\",\"title\":\"Holyoke Mall Food Court Hujicam\",\"ispublic\":1,\"isfriend\":0,\"isfamily\":0}]},\"stat\":\"ok\"}"
        
        if let data = mockString.data(using: .utf8) {
            do {
                if let mockResponse =  try JSONSerialization.jsonObject(with: data, options: []) as? [String: Any] {
                    searchVM.formImageModels(from: mockResponse)
                    asyncExpectation = expectation(description: "Error response")
                    self.waitForExpectations(timeout: 10) { error in
                        if error != nil {
                            XCTFail("Taking too much time to parse response")
                        } else {
                            XCTAssert(true)
                        }
                    }
                    if searchVM.imageViewModels.count != 2 {
                        XCTFail("parser failed for no fault data models from flickr")
                    }
                    XCTAssert(true)
                    
                } else {
                     XCTFail("wrong input")
                }
               
                
            } catch {
                print(error.localizedDescription)
                 XCTFail("wrong input")
            }
        }
        
    }

}

extension SearchViewModelTestCases: SearchViewModelDelegate {
    func updatedContent() {
        asyncExpectation?.fulfill()
    }
}
