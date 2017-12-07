//
//  ImageCheckmarkCell.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 12/5/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ImageCheckmarkCell: TableViewCell {
    override class var reuseId: String {
        return "ImageCheckmarkCell"
    }
    
    var customImage: UIImage? {
        didSet {
            updateImage()
            setNeedsLayout()
        }
    }
    
    fileprivate let customImageMaxHeight: CGFloat = 34
    
    var isChecked: Bool = false {
        didSet {
            checkmarkView.isHidden = !isChecked
        }
    }
    
    var checkmarkSize: CGFloat = 20 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var checkmarkMargin: CGFloat = 10 {
        didSet {
            setNeedsLayout()
        }
    }
    
    override var backgroundColor: UIColor? {
        didSet {
            updateCheckmark()
        }
    }
    
    let customImageView = UIImageView()
    let checkmarkView = UIImageView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        customImageView.contentMode = .scaleAspectFit
        customImageView.clipsToBounds = true
        contentView.addSubview(customImageView)
        
        checkmarkView.image = UIImage(named: "icon-checkmark")
        checkmarkView.contentMode = .scaleAspectFit
        checkmarkView.clipsToBounds = true
        contentView.addSubview(checkmarkView)
    }
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        updateCheckmark()
        updateImage()
        setNeedsLayout()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = framesThatFit(bounds.size)
        customImageView.frame = layout.customImageViewFrame
        checkmarkView.frame = layout.checkmarkFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = framesThatFit(size)
        let height = max(layout.customImageViewFrame.maxY, layout.checkmarkFrame.maxY) + contentInset.bottom
        
        return CGSize(width: size.width, height: height)
    }
}

extension ImageCheckmarkCell {
    func updateImage() {
        if let image = customImage {
            customImageView.image = image
        }
    }
    
    func updateCheckmark() {
        if let appSettings = appSettings {
            let color = (backgroundColor?.isDark() ?? false) ? .white : appSettings.branding.colors.accentColor
            checkmarkView.image = #imageLiteral(resourceName: "icon-checkmark").fillAlpha(color)
        }
    }
    
    fileprivate struct CalculatedLayout {
        let customImageViewFrame: CGRect
        let checkmarkFrame: CGRect
    }
    
    fileprivate func framesThatFit(_ size: CGSize) -> CalculatedLayout {
        let imageMaxWidth = size.width - contentInset.right - contentInset.left
        let imageViewSize = imageSizeThatFits(CGSize(width: imageMaxWidth, height: customImageMaxHeight))
        
        let imageViewLeft = contentInset.left + floor((imageMaxWidth - imageViewSize.width) / 2)
        let customImageViewFrame = CGRect(x: imageViewLeft, y: contentInset.top, width: imageViewSize.width, height: imageViewSize.height)
        
        let checkmarkLeft = size.width - contentInset.right - checkmarkSize
        let checkmarkTop = contentInset.top + floor((customImageViewFrame.size.height - checkmarkSize) / 2)
        let checkmarkFrame = CGRect(x: checkmarkLeft, y: checkmarkTop, width: checkmarkSize, height: checkmarkSize)
        
        return CalculatedLayout(customImageViewFrame: customImageViewFrame, checkmarkFrame: checkmarkFrame)
    }
    
    func imageSizeThatFits(_ size: CGSize) -> CGSize {
        let originalSize = customImage?.size ?? CGSize(width: 1, height: 1)
        let widthRatio = size.width / originalSize.width
        let heightRatio = size.height / originalSize.height
        let sizeRatio = min(widthRatio, heightRatio)
        return CGSize(width: originalSize.width * sizeRatio, height: originalSize.height * sizeRatio)
    }
}
