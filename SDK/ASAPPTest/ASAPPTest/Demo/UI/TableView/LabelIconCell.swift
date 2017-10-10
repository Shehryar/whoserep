//
//  LabelIconCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class LabelIconCell: TableViewCell {

    var title: String? {
        didSet {
            updateLabel()
            setNeedsLayout()
        }
    }
    
    var iconImage: UIImage? {
        didSet {
            updateImage()
            setNeedsLayout()
        }
    }
    
    override class var reuseId: String {
        return "LabelIconCellReuseId"
    }
  
    // MARK: Private Properties
    
    let titleLabel = UILabel()
    let iconImageView = UIImageView()
    
    let iconImageMargin: CGFloat = 16.0
    let iconImageSize: CGFloat = 24
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        titleLabel.textColor = UIColor.darkText
        titleLabel.font = DemoFonts.asapp.regular.withSize(20)
        contentView.addSubview(titleLabel)
        
        iconImageView.contentMode = .scaleAspectFit
        iconImageView.clipsToBounds = true
        contentView.addSubview(iconImageView)
    }

    // MARK: App Settings
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        updateLabel()
        updateImage()
    }

    func updateLabel() {
        if let title = title {
            titleLabel.attributedText = NSAttributedString(string: title, attributes: [
                NSFontAttributeName: appSettings?.branding.fontFamily.regular.withSize(16) ?? DemoFonts.asapp.regular.withSize(16),
                NSKernAttributeName: 1,
                NSForegroundColorAttributeName: appSettings?.branding.colors.foregroundColor ?? UIColor.darkText
            ])
        } else {
            titleLabel.attributedText = nil
        }
        setNeedsLayout()
    }
    
    func updateImage() {
        if let image = iconImage,
            let tintColor = appSettings?.branding.colors.foregroundColor {
            iconImageView.image = image.fillAlpha(tintColor)
        }
    }
    
    // MARK:- Layout
    
    func framesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        let iconImageLeft = size.width - contentInset.right - iconImageSize
        
        let labelLeft = contentInset.left
        let labelWidth = iconImageLeft - labelLeft
        let labelHeight = ceil(titleLabel.sizeThatFits(CGSize(width: labelWidth, height: 0)).height)
        let labelTop = contentInset.top + max(0, floor((iconImageSize - labelHeight) / 2.0))
        let labelFrame = CGRect(x: labelLeft, y: labelTop, width: labelWidth, height: labelHeight)
        
        let iconImageTop = contentInset.top + max(0, floor((labelHeight - iconImageSize) / 2.0))
        let iconImageFrame = CGRect(x: iconImageLeft, y: iconImageTop, width: iconImageSize, height: iconImageSize)
        
        return (labelFrame, iconImageFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (labelFrame, iconImageFrame) = framesThatFit(bounds.size)
        titleLabel.frame = labelFrame
        iconImageView.frame = iconImageFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (labelFrame, iconImageFrame) = framesThatFit(size)
        let height = max(labelFrame.maxY, iconImageFrame.maxY) + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
}
