//
//  SearchViewModel.swift
//  imageGoogler
//
//  Created by Radha Phani Krishna Sunkara on 26/10/18.
//  Copyright © 2018 Radha Phani Krishna Sunkara. All rights reserved.
//

import Foundation

protocol SearchViewModelDelegate: class {
    func updatedContent()
}

enum SearchState {
    case initial
    case success
    case failed
    case loading
    case noResult
    case noNewResult
}

///   1. SearchViewModel is responsibile for searching flickr with the given search text and creating               ImageViewModel's from ImageModel's
///   2. Requires three charatcers minmum to search
///   3. Search status will be updated in messageString
///   4. Uses delegate pattern to update changes in self to listener thorugh variable delegate:SearchViewModelDelegate.
///   5. Except the parsing code everything should run in main thread.
class SearchViewModel {
    static let flickrURL = "https://api.flickr.com/services/rest?"
    static let queryParams = "method=flickr.photos.search&api_key=3e7cc266ae2b0e0d78e279ce8e361736& format=json&nojsoncallback=1&safe_search=1&text="
    
    //TODO:- should localize following strings
    static let genericError = "Unknown error"
    static let infoMessage = " image(s) found"
    static let startMessage = "Enter more than 2 characters and hit search"
    static let loadingMessage = "Loading ..."
    static let noResultsMessage = "No images found."
    static let noNewResultsMessage = "No new images found. Total images "
    
    private var imageModels:[ImageModel] = [ImageModel]()
    var imageViewModels:[ImageViewModel] = [ImageViewModel]()
    var messageString: String = startMessage
    weak var delegate: SearchViewModelDelegate?
    var resultsPageToFetch = 1
    var searchState = SearchState.initial
    
    /// Use this method to search the flickr database
    ///
    /// - Parameter queryString: search string used to search flickr database
    func searchImages(for queryString: String) {
        resultsPageToFetch = 1
        getImageModels(for: queryString)
        searchState = .loading
        messageString = SearchViewModel.loadingMessage
        self.delegate?.updatedContent()
    }
    
    func fetchMoreImages(for queryString: String) {
        if searchState == .loading {
            return
        }
        resultsPageToFetch = resultsPageToFetch + 1
        getImageModels(for: queryString)
        searchState = .loading
        messageString = SearchViewModel.loadingMessage
        self.delegate?.updatedContent()
    }
    
    /// Clears models and view models. Sets the intial state
    func clearImages() {
        if searchState == .initial {
            return
        }
        searchState = .initial
        messageString = SearchViewModel.startMessage
        imageModels.removeAll()
        imageViewModels.removeAll()
        self.delegate?.updatedContent()
        
    }
    
    /// Creates ImageViewModels from ImageModels
    private func createImageViewModels(with models: [ImageModel]) {
        for imageModel in models {
            if let imageViewModel = ImageViewModel(with: imageModel) {
                imageViewModels.append(imageViewModel)
                imageModels.append(imageModel)
            }
        }
    }
    
    /// Creates ImageModels from json dictionary
    /// Forms ImageViewModels and Notifies the listener about update in main thread
    ///
    /// - Parameter json: from which ImageModels are formed
    func formImageModels(from jsonResponse: [String: Any]) {
        guard let stat = jsonResponse["stat"] as? String else {
            self.apiError(with: SearchViewModel.genericError)
            return
        }
        
        if stat == "fail" {
            if let message = jsonResponse["message"] as? String {
                self.apiError(with: message)
                return
            }
        }
        
        if stat != "ok" {
            self.apiError(with: SearchViewModel.genericError)
            return
        }
        
        guard let photosArray = jsonResponse["photos"] as? [String: Any], let photos = photosArray["photo"] as? [[String: Any]] else {
            self.apiError(with: SearchViewModel.genericError)
            return
        }
        
        var models = [ImageModel]()
        for jsonObject in photos {
            if let imageModel = ImageModel(with: jsonObject) {
                models.append(imageModel)
            }
        }

        DispatchQueue.main.async {
            let previousCount = self.imageModels.count
            self.createImageViewModels(with: models)
            if self.imageModels.count > 0 {
                if previousCount == self.imageModels.count {
                    self.searchState = .noNewResult
                    self.messageString =  SearchViewModel.noNewResultsMessage + String(self.imageModels.count)
                } else {
                    self.searchState = .success
                    self.messageString = String(self.imageModels.count) + SearchViewModel.infoMessage
                }
            } else {
                self.searchState = .noResult
                self.messageString = SearchViewModel.noResultsMessage
            }
            self.delegate?.updatedContent()
        }
    }
    
    /// Update the status with error
    /// Notifies the listener about update in main thread
    ///
    /// - Parameter message: error message to be notified
    func apiError(with message: String) {
        DispatchQueue.main.async {
            self.searchState = .failed
            self.messageString = message
            self.delegate?.updatedContent()
        }
    }
}

extension SearchViewModel {
    
    /// Network call which searches the results for given queryString from flickr
    ///
    /// - Parameter queryString: flickr uses this string to give relevant images.
    func getImageModels(for queryString: String) {
        let queryString = SearchViewModel.queryParams + queryString + "&page=" + String(resultsPageToFetch)
        guard let escapedString = queryString.addingPercentEncoding(withAllowedCharacters: .urlHostAllowed) else { return }
        let urlString = SearchViewModel.flickrURL + escapedString
        guard let url = URL(string: urlString)  else { return }
        let task = URLSession.shared.dataTask(with: url) { (data, response, error) in
            guard let dataResponse = data, error == nil else {
                self.apiError(with: SearchViewModel.genericError)
                    return
            }
            do{
                //here dataResponse received from a network request
                guard let jsonResponse = try JSONSerialization.jsonObject(with:
                    dataResponse, options: []) as? [String: Any] else {
                        self.apiError(with: SearchViewModel.genericError)
                        return
                }
                self.formImageModels(from: jsonResponse)
            } catch let parsingError {
                print("Error", parsingError)
            }
        }
        task.resume()
    }
}
