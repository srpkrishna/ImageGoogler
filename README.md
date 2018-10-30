# ImageGoogler
  Displays the images from flickr system for a given keyword.<br />
  Enter more than two characters and hit search to display the results.<br />
  Will keep on fetching new results for a given keyword as you scroll.<br />

# Architecture:
  MVVM<br />
    &nbsp;&nbsp;&nbsp;Model(M) - ImageModel.swift<br />
    &nbsp;&nbsp;&nbsp;Views(V) - SearchController.swift, ImageCollectionViewCell.swift<br />
    &nbsp;&nbsp;&nbsp;ViewModel(VM) - SearchViewModel.swift, ImageViewModel.swift<br />

# TODO:
  1. Improve test coverage from 65.5% to 100%. ViewModels unit test cases are almost covered. UITestCases are pending.
  2. Design image cache. Currently ImageViewModel has the image data and these objects are kept until the search query  changes. System may run out of memory due to this.
  3. Localisation of strings. Currently kept as constants.
