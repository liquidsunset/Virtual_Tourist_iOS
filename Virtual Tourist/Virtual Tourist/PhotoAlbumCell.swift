//
//  PhotoAlbumCell.swift
//  Virtual Tourist
//
//  Created by Daniel Brand on 30.07.16.
//  Copyright © 2016 Daniel Brand. All rights reserved.
//

import Foundation
import UIKit

class PhotoAlbumCell: UICollectionViewCell {


    @IBOutlet weak var imageView: UIImageView!
    @IBOutlet weak var acitvityIndicator: UIActivityIndicatorView!

    var pic: Photo! = nil {
        didSet {

            if (imageView.image != nil) {
                imageView.image = nil
            }

            dispatch_async(dispatch_get_main_queue(), {
                self.acitvityIndicator.hidden = false
                self.acitvityIndicator.startAnimating()
            })

            pic.downloadImageFromFlickrUrl() {
                (image, errorMessage) in
                guard (errorMessage == nil) else {
                    return
                }
                dispatch_async(dispatch_get_main_queue(), {
                    self.acitvityIndicator.stopAnimating()
                    self.acitvityIndicator.hidden = true
                    self.imageView.image = image
                })

            }
        }
    }
}
