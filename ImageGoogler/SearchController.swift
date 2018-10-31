//
//  SearchController
//  imageGoogler
//  Created by Radha Phani Krishna Sunkara on 25/10/18.
//  Copyright © 2018 Radha Phani Krishna Sunkara. All rights reserved.
//

import UIKit

///   1.UIClass responsbile for showing images which are searched using UISearchController.
///   2.infoLabel:UILabel is used to show the status of search and results.
///   3.imagesCollectionView:UICollectionView is used to show the results of search.
class SearchController: UIViewController {
    private static let mainTitle = "Search flickr images"
    private static let noOfSections: Int = 1
    private static let noOfItemsPerRow: Int = 3
    private static let spaceBetweenCells: CGFloat = 8.0
    private static let reuseIdentifier = "ImageCollectionViewCellIdentifier"
    private let searchViewModel =  SearchViewModel()
    
    @IBOutlet weak var imagesCollectionView: UICollectionView!
    @IBOutlet weak var infoLabel: UILabel!
    weak var searchController: UISearchController?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        let searchController = UISearchController(searchResultsController: nil)
        searchController.obscuresBackgroundDuringPresentation = false
        searchController.searchBar.placeholder = SearchController.mainTitle
        if #available(iOS 11.0, *) {
            navigationItem.searchController = searchController
        } else {
            // Fallback on earlier versions
            navigationItem.titleView = searchController.searchBar
        }
        definesPresentationContext = false
        if #available(iOS 11.0, *) {
            navigationItem.hidesSearchBarWhenScrolling = false
        }
        imagesCollectionView.dataSource = self
        imagesCollectionView.delegate = self
        imagesCollectionView.prefetchDataSource = self
        searchController.searchBar.delegate = self
        searchViewModel.delegate = self
        self.infoLabel.text = searchViewModel.messageString
        self.searchController = searchController
    }
    
    override func viewDidAppear(_ animated: Bool) {
        self.searchController?.searchBar.becomeFirstResponder()
        super.viewDidAppear(animated)
    }
}

extension SearchController: UISearchBarDelegate {
    public func searchBarSearchButtonClicked(_ searchBar: UISearchBar) {
        searchBar.resignFirstResponder()
        if let queryString = searchBar.text, queryString.count > 2 {
            searchViewModel.searchImages(for: queryString)
        }
    }
    public func searchBar(_ searchBar: UISearchBar, textDidChange searchText: String) {
        searchViewModel.clearImages()
    }
    public func searchBarCancelButtonClicked(_ searchBar: UISearchBar) {
        searchViewModel.clearImages()
    }
}

extension SearchController: UICollectionViewDataSource {
    func collectionView(_ collectionView: UICollectionView,
                        numberOfItemsInSection section: Int) -> Int {
        return searchViewModel.imageViewModels.count
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: SearchController.reuseIdentifier, for: indexPath) as! ImageCollectionViewCell
        let imageViewModel = searchViewModel.imageViewModels[indexPath.row]
        imageViewModel.delegate = self
        cell.setViewModel(model: searchViewModel.imageViewModels[indexPath.row], for: indexPath.row)
        return cell
    }
}

extension SearchController: UICollectionViewDataSourcePrefetching {
    func collectionView(_ collectionView: UICollectionView, prefetchItemsAt indexPaths: [IndexPath]) {
        if let lastRow = indexPaths.last?.row {
            if lastRow == searchViewModel.imageViewModels.count - 1, let searchText = searchController?.searchBar.text {
                searchViewModel.fetchMoreImages(for: searchText)
            }
        }
        for indexPath in indexPaths {
            let imageViewModel = searchViewModel.imageViewModels[indexPath.row]
            if imageViewModel.imageDownloadState == .notStarted {
                imageViewModel.downloadImage(for: indexPath.row)
            }
        }
    }
}

extension SearchController: UICollectionViewDelegateFlowLayout {
    func collectionView(_ collectionView: UICollectionView,
                               layout collectionViewLayout: UICollectionViewLayout,
                               sizeForItemAt indexPath: IndexPath) -> CGSize {
        let paddingSpace = CGFloat(SearchController.noOfItemsPerRow) * SearchController.spaceBetweenCells
        let availableWidth = collectionView.frame.size.width - paddingSpace
        let itemDimension = availableWidth / CGFloat(SearchController.noOfItemsPerRow)
        return CGSize(width: itemDimension, height: itemDimension)
    }
    
    func collectionView(_ collectionView: UICollectionView,
                        layout collectionViewLayout: UICollectionViewLayout,
                        minimumLineSpacingForSectionAt section: Int) -> CGFloat {
        return SearchController.spaceBetweenCells
    }
    
    func collectionView(_ collectionView: UICollectionView, layout collectionViewLayout: UICollectionViewLayout, minimumInteritemSpacingForSectionAt section: Int) -> CGFloat {
        return SearchController.spaceBetweenCells
    }
}


// MARK: - SearchViewModelDelegate. Notifies the changes in content of SearchViewModel.
// Changes happen 1. Results are fecthed from flickr
//                2. Searchbar text changed

extension SearchController: SearchViewModelDelegate {
    func updatedContent() {
        self.infoLabel.text = searchViewModel.messageString
        if searchViewModel.searchState != .loading {
             self.imagesCollectionView.reloadData()
        }
    }
}

// MARK: - ImageViewModelDelegate. Notifies the update of downlaoded image for UICollectionViewCell
extension SearchController: ImageViewModelDelegate {
    func updateImage(for index: Int, imageModel: ImageViewModel) {
        if searchViewModel.imageViewModels.count > 0 && searchViewModel.imageViewModels.count > index {
            let imageViewModel = searchViewModel.imageViewModels[index]
            if imageViewModel.id == imageModel.id {
                self.imagesCollectionView.reloadItems(at: [IndexPath.init(row: index, section: 0)])
            }
        }
    }
}
