//
//  ImageCell.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 12/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ImageCell: TableViewCell {
    override class var reuseId: String {
        return "ImageCell"
    }
    
    var customImage: UIImage? {
        didSet {
            updateImage()
            setNeedsLayout()
        }
    }
    
    let customImageView = UIImageView()
    
    fileprivate let customImageMaxHeight: CGFloat = 34
    
    override func commonInit() {
        super.commonInit()
        
        customImageView.contentMode = .scaleAspectFit
        customImageView.clipsToBounds = true
        contentView.addSubview(customImageView)
    }
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        updateImage()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = framesThatFit(bounds.size)
        customImageView.frame = layout.customImageViewFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = framesThatFit(size)
        let height = layout.customImageViewFrame.maxY + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
}

extension ImageCell {
    func updateImage() {
        if let image = customImage {
            customImageView.image = image
        }
    }
    
    fileprivate struct CalculatedLayout {
        let customImageViewFrame: CGRect
    }
    
    fileprivate func framesThatFit(_ size: CGSize) -> CalculatedLayout {
        let imageMaxWidth = size.width - contentInset.right - contentInset.left
        let imageViewSize = imageSizeThatFits(CGSize(width: imageMaxWidth, height: customImageMaxHeight))
        
        let imageViewLeft = contentInset.left + floor((imageMaxWidth - imageViewSize.width) / 2)
        let customImageViewFrame = CGRect(x: imageViewLeft, y: contentInset.top, width: imageViewSize.width, height: imageViewSize.height)
        
        return CalculatedLayout(customImageViewFrame: customImageViewFrame)
    }
    
    func imageSizeThatFits(_ size: CGSize) -> CGSize {
        let originalSize = customImage?.size ?? CGSize(width: 1, height: 1)
        let widthRatio = size.width / originalSize.width
        let heightRatio = size.height / originalSize.height
        let sizeRatio = min(widthRatio, heightRatio)
        return CGSize(width: originalSize.width * sizeRatio, height: originalSize.height * sizeRatio)
    }
}
