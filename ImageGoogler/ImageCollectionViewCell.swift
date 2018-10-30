//
//  ImageCollectionViewCell.swift
//  imageGoogler
//
//  Created by Radha Phani Krishna Sunkara on 29/10/18.
//  Copyright © 2018 Radha Phani Krishna Sunkara. All rights reserved.
//

import UIKit

/// UIClass responsbile for showing image and image download status
class ImageCollectionViewCell: UICollectionViewCell {
    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var errorImageView: UIImageView!
    @IBOutlet weak var loaderImageView: UIActivityIndicatorView!
    
    func setViewModel(model: ImageViewModel, for index: Int) {
        switch model.imageDownloadState {
            case .notStarted:
                model.downloadImage(for: index)
                imageView.isHidden = true
                errorImageView.isHidden = true
                loaderImageView.isHidden = false
            case .inProgress:
                imageView.isHidden = true
                errorImageView.isHidden = true
                loaderImageView.isHidden = false
            case .completed:
                if let data = model.imageData, let image = UIImage(data: data) {
                    imageView.isHidden = false
                    imageView.image = image
                }
                errorImageView.isHidden = true
                loaderImageView.isHidden = true
            case .failed:
                imageView.isHidden = true
                errorImageView.isHidden = false
                loaderImageView.isHidden = true
        }
    }
}
