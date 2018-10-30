# ImageGoogler
  Displays the images from flickr system for a given keyword.
  Enter more than two characters and hit search to display the results.
  Will keep on fetching new results for a given keyword as you scroll.

# Architecture:
  MVVM
  Model(M) - ImageModel.swift
  Views(V) - SearchController.swift, ImageCollectionViewCell.swift
  ViewModel(VM) - SearchViewModel.swift, ImageViewModel.swift

# TODO:
  1. Improve test coverage from 57.39% to 100%. Only SearchViewModel unit test case were written.
  2. Design image cache. Currently ImageViewModel has the image data and these objects are kept    until the search query changes. System may run out of memory due to this.
  3. Localisation of strings. Currently kept as constants.
