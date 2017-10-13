//
//  ImageViewerImage.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ImageViewerImage: NSObject {
    var image: UIImage?
    var imageURL: URL?
    var caption: String?
    
    init(image: UIImage? = nil, imageURL: URL? = nil, caption: String? = nil) {
        self.image = image
        self.imageURL = imageURL
        self.caption = caption
        super.init()
    }
}

// MARK: - Creation Utilities

extension ImageViewerImage {
    class func imagesWithImages(_ images: [UIImage]) -> [ImageViewerImage] {
        var imageViewerImages = [ImageViewerImage]()
        for image in images {
            imageViewerImages.append(ImageViewerImage(image: image))
        }
        return imageViewerImages
    }
    
    class func imagesWithImageURLs(_ imageURLs: [URL]) -> [ImageViewerImage] {
        var imageViewerImages = [ImageViewerImage]()
        for imageURL in imageURLs {
            imageViewerImages.append(ImageViewerImage(imageURL: imageURL))
        }
        return imageViewerImages
    }
}
