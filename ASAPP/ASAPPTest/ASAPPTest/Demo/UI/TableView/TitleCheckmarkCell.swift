//
//  TitleCheckmarkCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class TitleCheckmarkCell: TableViewCell {

    var title: String? {
        didSet {
            titleLabel.text = title
            setNeedsLayout()
        }
    }
    
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
    
    override class var reuseId: String {
        return "TitleCheckmarkCellReuseId"
    }
    
    // MARK: Subviews
    
    let titleLabel = AttributedLabel()
    
    let checkmarkView = UIImageView()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        titleLabel.font = DemoFonts.latoRegularFont(withSize: 16)
        titleLabel.kerning = 1
        titleLabel.textColor = UIColor.darkText
        contentView.addSubview(titleLabel)
        
        checkmarkView.image = UIImage(named: "icon-checkmark")
        checkmarkView.contentMode = .scaleAspectFit
        checkmarkView.clipsToBounds = true
        contentView.addSubview(checkmarkView)
    }
    
    // MARK: Styling
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        if let appSettings = appSettings {
            titleLabel.font = appSettings.branding.fonts.regularFont.withSize(16)
            titleLabel.textColor = appSettings.branding.colors.foregroundColor
            
            checkmarkView.image = UIImage(named: "icon-checkmark")?.fillAlpha(appSettings.branding.colors.accentColor)
        }
        
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    func framesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        
        let checkmarkLeft = size.width - contentInset.right - checkmarkSize
        
        let labelWidth = checkmarkLeft - checkmarkMargin - contentInset.left
        let labelHeight = ceil(titleLabel.sizeThatFits(CGSize(width: labelWidth, height: 0)).height)
        let labelTop = contentInset.top + max(0, floor((checkmarkSize - labelHeight) / 2.0))
        let toggleTop = contentInset.top + max(0, floor((labelHeight - checkmarkSize) / 2.0))
        
        let labelFrame = CGRect(x: contentInset.left, y: labelTop, width: labelWidth, height: labelHeight)
        let toggleFrame = CGRect(x: checkmarkLeft, y: toggleTop, width: checkmarkSize, height: checkmarkSize)
        
        return (labelFrame, toggleFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (labelFrame, checkmarkFrame) = framesThatFit(bounds.size)
        titleLabel.frame = labelFrame
        checkmarkView.frame = checkmarkFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (labelFrame, checkmarkFrame) = framesThatFit(size)
        let height = max(labelFrame.maxY, checkmarkFrame.maxY) + contentInset.bottom
        
        return CGSize(width: size.width, height: height)
    }
}
