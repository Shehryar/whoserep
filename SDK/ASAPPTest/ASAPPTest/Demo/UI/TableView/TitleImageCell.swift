//
//  TitleImageCell.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 12/4/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TitleImageCell: TableViewCell {
    override class var reuseId: String {
        return "TitleImageCell"
    }
    
    var title: String? {
        didSet {
            updateLabel()
            setNeedsLayout()
        }
    }
    
    var customImage: UIImage? {
        didSet {
            updateImage()
            setNeedsLayout()
        }
    }
    
    let titleLabel = AttributedLabel()
    let customImageView = UIImageView()
    
    fileprivate let customImageMaxHeight: CGFloat = 34
    
    override func commonInit() {
        super.commonInit()
        
        titleLabel.textColor = UIColor.darkText
        titleLabel.font = DemoFonts.asapp.regular.withSize(16)
        titleLabel.kerning = 1
        contentView.addSubview(titleLabel)
        
        customImageView.contentMode = .scaleAspectFit
        customImageView.clipsToBounds = true
        contentView.addSubview(customImageView)
    }
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        updateLabel()
        updateImage()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = framesThatFit(bounds.size)
        titleLabel.frame = layout.titleLabelFrame
        customImageView.frame = layout.customImageViewFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = framesThatFit(size)
        let height = max(layout.titleLabelFrame.maxY, layout.customImageViewFrame.maxY) + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
}

extension TitleImageCell {
    func updateLabel() {
        if let title = title {
            let color = (backgroundColor?.isDark() ?? false) ? .white : (appSettings?.branding.colors.foregroundColor ?? UIColor.darkText)
            titleLabel.attributedText = NSAttributedString(string: title, attributes: [
                NSFontAttributeName: appSettings?.branding.fontFamily.regular.withSize(16) ?? DemoFonts.asapp.regular.withSize(16),
                NSKernAttributeName: 1,
                NSForegroundColorAttributeName: color
            ])
        } else {
            titleLabel.attributedText = nil
        }
        setNeedsLayout()
    }
    
    func updateImage() {
        if let image = customImage {
            customImageView.image = image
        }
    }
    
    fileprivate struct CalculatedLayout {
        let titleLabelFrame: CGRect
        let customImageViewFrame: CGRect
    }
    
    fileprivate func framesThatFit(_ size: CGSize) -> CalculatedLayout {
        let spacing: CGFloat = 20
        let titleLabelSize = titleLabel.sizeThatFits(CGSize(width: size.width, height: .greatestFiniteMagnitude))
        let titleLabelHeight = ceil(titleLabelSize.height)
        var titleLabelFrame = CGRect(x: contentInset.left, y: 0, width: titleLabelSize.width, height: titleLabelHeight)
        
        let imageMaxWidth = size.width - titleLabelFrame.maxX - contentInset.right - spacing
        let imageViewSize = imageSizeThatFits(CGSize(width: imageMaxWidth, height: customImageMaxHeight))
        
        titleLabelFrame.origin.y = contentInset.top + max(0, floor((imageViewSize.height - titleLabelHeight) / 2))
        
        let imageViewLeft = max(titleLabelFrame.maxX + spacing, size.width - contentInset.right - imageViewSize.width)
        let imageViewTop = contentInset.top + max(0, floor((titleLabelHeight - imageViewSize.height) / 2))
        let customImageViewFrame = CGRect(x: imageViewLeft, y: imageViewTop, width: imageViewSize.width, height: imageViewSize.height)
        
        return CalculatedLayout(titleLabelFrame: titleLabelFrame, customImageViewFrame: customImageViewFrame)
    }
    
    func imageSizeThatFits(_ size: CGSize) -> CGSize {
        let originalSize = customImage?.size ?? CGSize(width: 1, height: 1)
        let widthRatio = size.width / originalSize.width
        let heightRatio = size.height / originalSize.height
        let sizeRatio = min(widthRatio, heightRatio)
        return CGSize(width: originalSize.width * sizeRatio, height: originalSize.height * sizeRatio)
    }
}
