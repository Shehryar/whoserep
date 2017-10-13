//
//  ImageNameCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ImageNameCell: TableViewCell {
    
    var name: String? {
        didSet {
            nameLabel.text = name
            setNeedsLayout()
        }
    }
    
    var detailText: String? {
        didSet {
            detailLabel.text = detailText
            setNeedsLayout()
        }
    }
    
    var imageName: String? {
        didSet {
            if let imageName = imageName {
                userImageView.image = UIImage(named: imageName)
            } else {
                userImageView.image = nil
            }
            setNeedsLayout()
        }
    }
    
    let userImageView = UIImageView()
    
    let nameLabel = AttributedLabel()
    
    let detailLabel = AttributedLabel()
    
    let nameLabelMarginBottom: CGFloat = 4
    
    var imageSize: CGFloat = 64 {
        didSet {
            setNeedsLayout()
        }
    }
    
    let imageMargin: CGFloat = 20
    
    override class var reuseId: String {
        return "HomeNameCellReuseId"
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()

        nameLabel.text = "Gustavo"
        nameLabel.textColor = UIColor.darkText
        nameLabel.kerning = 0.4
        contentView.addSubview(nameLabel)
        
        detailLabel.text = "View and edit profile"
        detailLabel.textColor = UIColor.darkText
        detailLabel.kerning = 0.5
        contentView.addSubview(detailLabel)
        
        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true
        userImageView.image = UIImage(named: "user-image")
        contentView.addSubview(userImageView)
    }
    
    // MARK: - App Settings
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        if let appSettings = appSettings {
            nameLabel.font = appSettings.branding.fontFamily.light.withSize(34)
            nameLabel.textColor = appSettings.branding.colors.foregroundColor
            
            detailLabel.font = appSettings.branding.fontFamily.light.withSize(14)
            detailLabel.textColor = appSettings.branding.colors.foregroundColor
            
            userImageView.backgroundColor = appSettings.branding.colors.secondaryBackgroundColor
            userImageView.layer.borderWidth = 1
            userImageView.layer.borderColor = appSettings.branding.colors.foregroundColor.cgColor
        }
        
        setNeedsLayout()
    }

    // MARK: - Layout
    
    private struct CalculatedLayout {
        let imageViewFrame: CGRect
        let nameLabelFrame: CGRect
        let viewProfileLabelFrame: CGRect
    }
    
    private func framesThatFit(size: CGSize) -> CalculatedLayout {

        let labelLeft = contentInset.left + imageSize + imageMargin
        let labelWidth = size.width - labelLeft - contentInset.right
        let labelSizer = CGSize(width: labelWidth, height: 0)
        
        let nameHeight = ceil(nameLabel.sizeThatFits(labelSizer).height)
        let detailHeight = ceil(detailLabel.sizeThatFits(labelSizer).height)
        var totalLabelHeight = nameHeight + detailHeight
        if nameHeight > 0 && detailHeight > 0 {
            totalLabelHeight += nameLabelMarginBottom
        }
        
        let labelTop = contentInset.top + max(0, floor((imageSize - totalLabelHeight) / 2.0))
        
        let nameLabelFrame = CGRect(x: labelLeft, y: labelTop, width: labelWidth, height: nameHeight)
        let viewProfileLabelFrame = CGRect(x: labelLeft, y: nameLabelFrame.maxY + nameLabelMarginBottom,
                                           width: labelWidth, height: detailHeight)
        
        let imageTop = contentInset.top + max(0, floor((totalLabelHeight - imageSize) / 2.0))
        let imageViewFrame = CGRect(x: contentInset.left, y: imageTop, width: imageSize, height: imageSize)
        
        return CalculatedLayout(imageViewFrame: imageViewFrame, nameLabelFrame: nameLabelFrame, viewProfileLabelFrame: viewProfileLabelFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = framesThatFit(size: bounds.size)
        userImageView.frame = layout.imageViewFrame
        userImageView.layer.cornerRadius = layout.imageViewFrame.height / 2.0
    
        nameLabel.frame = layout.nameLabelFrame
        detailLabel.frame = layout.viewProfileLabelFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = framesThatFit(size: size)
        let height = max(layout.nameLabelFrame.maxY, layout.viewProfileLabelFrame.maxY, layout.imageViewFrame.maxY) + contentInset.bottom
        
        return CGSize(width: size.width, height: height)
    }
}
