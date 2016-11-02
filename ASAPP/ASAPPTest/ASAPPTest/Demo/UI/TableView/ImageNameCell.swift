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
    
    let imageSize: CGFloat = 64
    
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
    
    // MARK:- App Settings
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        if let appSettings = appSettings {
            nameLabel.font = appSettings.blackFont.withSize(28)
            nameLabel.textColor = appSettings.foregroundColor
            
            detailLabel.font = appSettings.lightFont.withSize(14)
            detailLabel.textColor = appSettings.foregroundColor
            
            userImageView.backgroundColor = appSettings.backgroundColor2
            userImageView.layer.borderWidth = 1
            userImageView.layer.borderColor = appSettings.foregroundColor.cgColor
        }
        
        setNeedsLayout()
    }

    // MARK:- Layout
    
    func framesThatFit(size: CGSize) -> (CGRect, CGRect, CGRect) {

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
        
        return (imageViewFrame, nameLabelFrame, viewProfileLabelFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (imageViewFrame, nameLabelFrame, viewProfileLabelFrame) = framesThatFit(size: bounds.size)
        userImageView.frame = imageViewFrame
        userImageView.layer.cornerRadius = imageViewFrame.height / 2.0
    
        nameLabel.frame = nameLabelFrame
        detailLabel.frame = viewProfileLabelFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (imageViewFrame, nameLabelFrame, viewProfileLabelFrame) = framesThatFit(size: size)
        let height = max(nameLabelFrame.maxY, viewProfileLabelFrame.maxY, imageViewFrame.maxY) + contentInset.bottom
        
        return CGSize(width: size.width, height: height)
    }
}
