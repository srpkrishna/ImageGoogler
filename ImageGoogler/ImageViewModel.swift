//
//  ImageViewModel.swift
//  imageGoogler
//
//  Created by Radha Phani Krishna Sunkara on 26/10/18.
//  Copyright © 2018 Radha Phani Krishna Sunkara. All rights reserved.
//

import Foundation

enum ImageDownloadState {
    case notStarted
    case inProgress
    case failed
    case completed
}

protocol ImageViewModelDelegate: class {
    func updateImage(for index:Int, imageModel: ImageViewModel)
}

///   1. ImageViewModel is responsibile for downloading the image and maintaining the download state
///   2. Uses delegate pattern to update changes in self to listener thorugh variable delegate:ImageViewModelDelegate.
///   3. All the code should run in main thread.
class ImageViewModel {
    let id: String
    let title: String //Currently not used.
    let imageUrl: URL
    var imageDownloadState: ImageDownloadState
    var imageData: Data?
    private var dataTask: URLSessionDataTask?
    weak var delegate: ImageViewModelDelegate?
    
    init?(with imageModel: ImageModel) {
        self.id = imageModel.id
        self.title = imageModel.title
        let urlString = "https://farm" + imageModel.farm.stringValue + ".static.flickr.com/" + imageModel.server + "/" + imageModel.id + "_" + imageModel.secret + ".jpg"
        guard let url = URL(string: urlString) else { return nil }
        self.imageUrl = url
        self.imageDownloadState = .notStarted
    }
}

extension ImageViewModel {
    
    /// Downloads the image.
    ///
    /// - Parameter index: tag passed back to idenitify the listener when download completes
    func downloadImage(for index: Int) {
        let request = URLRequest(url: imageUrl)
        let config = URLSessionConfiguration.default
        let session = URLSession(configuration: config)
        dataTask = session.dataTask(with: request, completionHandler: {[weak self](data, response, error) in
            DispatchQueue.main.async {
                self?.downloadTaskComplete(with: data, error: error, for: index)
            }
        });
        dataTask?.resume()
        imageDownloadState = .inProgress
    }
    
    /// Parses the result and updates the result to listener
    ///
    /// - Parameters:
    ///   - data: image data downloaded. In case of error this will be nil
    ///   - error: error if any while downloading image
    ///   - index: tag passed to downloadImage:ImageViewModel
    func downloadTaskComplete(with data: Data?, error: Error?, for index: Int) {
        if error != nil {
            self.imageDownloadState = .failed
        } else {
            self.imageDownloadState = .completed
            self.imageData = data
        }
        delegate?.updateImage(for: index, imageModel: self)
    }
}
