//
//  ImageViewModelTestCase.swift
//  ImageGooglerTests
//
//  Created by Radha Phani Krishna Sunkara on 30/10/18.
//  Copyright © 2018 Radha Phani Krishna Sunkara. All rights reserved.
//

import XCTest
@testable import ImageGoogler

class ImageViewModelTestCase: XCTestCase {
    var asyncExpectation:XCTestExpectation?
    override func setUp() {
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDown() {
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

    func testBasicImageDownload() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let dict:[String: Any] = [
            "id": "30694321407",
            "owner": "76097431@N04",
            "secret": "70f61ff7dd",
            "server": "1939",
            "farm": 2,
            "title": "Screenshot from the Affirm Your Life Affirmations app",
            "ispublic": true]
        
        if let imageModel = ImageModel(with: dict), let imageViewModel = ImageViewModel(with: imageModel) {
            imageViewModel.delegate = self
            imageViewModel.downloadImage(for: 0)
            asyncExpectation = expectation(description: "Download image")
            self.waitForExpectations(timeout: 50) { error in
                if error != nil {
                    XCTFail("Taking too much time to download")
                } else {
                    XCTAssert(true)
                }
            }
            
            if imageViewModel.imageDownloadState == .completed {
                XCTAssert(true)
            } else {
                XCTFail("image not downloaded")
            }
        } else {
            XCTFail("input wrong")
        }
    }
    
    func testImageDownloadFail() {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
        let dict:[String: Any] = [
            "id": "30694321407",
            "owner": "76097431@N04",
            "secret": "70f61ff7dd",
            "server": "1939",
            "farm": 21,
            "title": "Screenshot from the Affirm Your Life Affirmations app",
            "ispublic": true]
        
        if let imageModel = ImageModel(with: dict), let imageViewModel = ImageViewModel(with: imageModel) {
            imageViewModel.delegate = self
            imageViewModel.downloadImage(for: 0)
            asyncExpectation = expectation(description: "Download image for wromng farm value")
            self.waitForExpectations(timeout: 50) { error in
                if error != nil {
                    XCTFail("Taking too much time to download")
                } else {
                    XCTAssert(true)
                }
            }
            
            if imageViewModel.imageDownloadState == .failed {
                XCTAssert(true)
            } else {
                XCTFail("Image download shouldn't succeed")
            }
        } else {
            XCTFail("input wrong")
        }
    }
}

extension ImageViewModelTestCase: ImageViewModelDelegate {
    func updateImage(for index:Int, imageModel: ImageViewModel) {
        asyncExpectation?.fulfill()
    }
}
