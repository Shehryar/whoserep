//
//  HomeNameCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class HomeNameCell: TableViewCell {
    
    let nameLabel = UILabel()
    
    let nameLabelMarginBottom: CGFloat = 4
    
    let viewProfileLabel = UILabel()
    
    let imageSize: CGFloat = 64
    
    let imageMargin: CGFloat = 20
    
    let userImageView = UIImageView()
    
    override func commonInit() {
        super.commonInit()
    
        contentView.addSubview(nameLabel)
        contentView.addSubview(viewProfileLabel)
        
        userImageView.contentMode = .scaleAspectFill
        userImageView.clipsToBounds = true
        userImageView.image = UIImage(named: "user-image")
        contentView.addSubview(userImageView)
        
        updateLabels()
    }
    
    // MARK:- App Settings
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        if let appSettings = appSettings {
            
            updateLabels()
            
            userImageView.backgroundColor = appSettings.backgroundColor2
            userImageView.layer.borderWidth = 1
            userImageView.layer.borderColor = appSettings.foregroundColor.cgColor
        }
        
        setNeedsLayout()
    }
    
    func updateLabels() {
        nameLabel.attributedText = NSAttributedString(string: "Gustavo", attributes: [
            NSFontAttributeName : DemoFonts.latoBlackFont(withSize: 28),
            NSForegroundColorAttributeName : appSettings?.foregroundColor ?? UIColor.darkText,
            NSKernAttributeName : 0.4
            ])
        
        viewProfileLabel.attributedText = NSAttributedString(string: "View and edit profile", attributes: [
            NSFontAttributeName : DemoFonts.latoLightFont(withSize: 14),
            NSKernAttributeName : 0.5,
            NSForegroundColorAttributeName : appSettings?.foregroundColor ?? UIColor.darkText
            ])
    }
    
    // MARK:- Layout
    
    func framesThatFit(size: CGSize) -> (CGRect, CGRect, CGRect) {

        let labelLeft = contentInset.left + imageSize + imageMargin
        let labelWidth = size.width - labelLeft - contentInset.right
        let labelSizer = CGSize(width: labelWidth, height: 0)
        
        let nameHeight = ceil(nameLabel.sizeThatFits(labelSizer).height)
        let viewProfileHeight = ceil(viewProfileLabel.sizeThatFits(labelSizer).height)
        let totalLabelHeight = nameHeight + viewProfileHeight + nameLabelMarginBottom
        
        let labelTop = contentInset.top + max(0, floor((imageSize - totalLabelHeight) / 2.0))
        
        let nameLabelFrame = CGRect(x: labelLeft, y: labelTop, width: labelWidth, height: nameHeight)
        let viewProfileLabelFrame = CGRect(x: labelLeft, y: nameLabelFrame.maxY + nameLabelMarginBottom,
                                           width: labelWidth, height: viewProfileHeight)
        
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
        viewProfileLabel.frame = viewProfileLabelFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (imageViewFrame, nameLabelFrame, viewProfileLabelFrame) = framesThatFit(size: size)
        let height = max(nameLabelFrame.maxY, viewProfileLabelFrame.maxY, imageViewFrame.maxY) + contentInset.bottom
        
        return CGSize(width: size.width, height: height)
    }
}
