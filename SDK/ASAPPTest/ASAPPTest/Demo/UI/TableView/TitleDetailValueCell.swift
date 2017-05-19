//
//  TitleDetailValueCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class TitleDetailValueCell: TableViewCell {

    var titleDetailMargin: CGFloat = 3.0 {
        didSet {
            if titleDetailMargin != oldValue {
                setNeedsLayout()
            }
        }
    }
    
    override class var reuseId: String {
        return "TitleDetailValueCellReuseId"
    }
    
    let titleLabel = AttributedLabel()
    
    let detailLabel = UILabel()
    
    let valueLabel = UILabel()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        selectionStyle = .none
        
        titleLabel.font = DemoFonts.latoRegularFont(withSize: 16)
        titleLabel.textColor = UIColor.darkText
        titleLabel.kerning = 1
        contentView.addSubview(titleLabel)
        
        detailLabel.font = DemoFonts.latoLightFont(withSize: 14)
        detailLabel.textColor = UIColor.gray
        detailLabel.numberOfLines = 0
        detailLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(detailLabel)
        
        valueLabel.font = DemoFonts.latoLightFont(withSize: 16)
        valueLabel.textColor = UIColor.darkText
        valueLabel.textAlignment = .right
        valueLabel.adjustsFontSizeToFitWidth = true
        valueLabel.minimumScaleFactor = 0.4
        contentView.addSubview(valueLabel)
    }
    
    // MARK:- AppSettings
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        if let appSettings = appSettings {
            titleLabel.font = appSettings.branding.fonts.regularFont.withSize(16)
            detailLabel.font = appSettings.branding.fonts.lightFont.withSize(14)
            valueLabel.font = appSettings.branding.fonts.lightFont.withSize(16)
            
            titleLabel.textColor = appSettings.branding.colors.foregroundColor
            detailLabel.textColor = appSettings.branding.colors.secondaryTextColor
            valueLabel.textColor = appSettings.branding.colors.foregroundColor
        }
    }
    
    // MARK:- Layout
    
    func labelFramesThatFit(_ size: CGSize) -> (CGRect, CGRect, CGRect) {
        let contentWidth = size.width - contentInset.left - contentInset.right
        let leftWidth = floor(contentWidth * 0.6)
        let leftRightMargin: CGFloat = 10
        let rightWidth = contentWidth - leftWidth - leftRightMargin
        
        let nameHeight = ceil(titleLabel.sizeThatFits(CGSize(width: leftWidth, height: 0)).height)
        let nameLabelFrame = CGRect(x: contentInset.left, y: contentInset.top, width: leftWidth, height: nameHeight)
        
        let detailHeight = ceil(detailLabel.sizeThatFits(CGSize(width: leftWidth, height: 0)).height)
        let detailLabelFrame: CGRect
        if detailHeight > 0 {
            detailLabelFrame = CGRect(x: contentInset.left, y: nameLabelFrame.maxY + titleDetailMargin, width: leftWidth, height: detailHeight)
        } else {
            detailLabelFrame = .zero
        }
        
        let valueLeft = size.width - contentInset.right - rightWidth
        let valueHeight = ceil(valueLabel.sizeThatFits(CGSize(width: rightWidth, height: 0)).height)
        let valueLabelFrame = CGRect(x: valueLeft, y: contentInset.top, width: rightWidth, height: valueHeight)
        
        return (nameLabelFrame, detailLabelFrame, valueLabelFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (titleLabelFrame, detailLabelFrame, valueLabelFrame) = labelFramesThatFit(bounds.size)
        titleLabel.frame = titleLabelFrame
        detailLabel.frame = detailLabelFrame
        valueLabel.frame = valueLabelFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (titleLabelFrame, detailLabelFrame, valueLabelFrame) = labelFramesThatFit(size)
        let height = max(titleLabelFrame.maxY, detailLabelFrame.maxY, valueLabelFrame.maxY) + contentInset.bottom
        
        return CGSize(width: size.width, height: height)
    }

    // MARK: Public Intance Methods
    
    func update(titleText: String?, detailText: String?, valueText: String?) {
        titleLabel.text = titleText
        detailLabel.text = detailText
        valueLabel.text = valueText
        
        setNeedsLayout()
    }
}
