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
    
    fileprivate let titleLabel = UILabel()
    
    fileprivate let detailLabel = UILabel()
    
    fileprivate let valueLabel = UILabel()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        selectionStyle = .none
        
        titleLabel.font = DemoFonts.latoRegularFont(withSize: 16)
        titleLabel.textColor = UIColor.darkText
        titleLabel.numberOfLines = 0
        titleLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(titleLabel)
        
        detailLabel.font = DemoFonts.latoLightFont(withSize: 14)
        detailLabel.textColor = UIColor.gray
        detailLabel.numberOfLines = 0
        detailLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(detailLabel)
        
        valueLabel.font = DemoFonts.latoBoldFont(withSize: 16)
        valueLabel.textColor = UIColor.darkText
        valueLabel.textAlignment = .right
        contentView.addSubview(valueLabel)
    }
    
    // MARK:- AppSettings
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        if let appSettings = appSettings {
            titleLabel.textColor = appSettings.foregroundColor
            detailLabel.textColor = appSettings.foregroundColor2
            valueLabel.textColor = appSettings.foregroundColor
        }
    }
    
    // MARK:- Layout
    
    func labelFramesThatFit(_ size: CGSize) -> (CGRect, CGRect, CGRect) {
        var nameLabelFrame, dateLabelFrame, amountLabelFrame: CGRect
        nameLabelFrame = .zero
        dateLabelFrame = .zero
        amountLabelFrame = .zero
        
        let contentWidth = size.width - contentInset.left - contentInset.right
        let leftWidth = floor(contentWidth * 0.6)
        let leftRightMargin: CGFloat = 10
        let rightWidth = contentWidth - leftWidth - leftRightMargin
        
        let nameHeight = ceil(titleLabel.sizeThatFits(CGSize(width: leftWidth, height: 0)).height)
        nameLabelFrame = CGRect(x: contentInset.left, y: contentInset.top, width: leftWidth, height: nameHeight)
        
        let dateHeight = ceil(detailLabel.sizeThatFits(CGSize(width: leftWidth, height: 0)).height)
        dateLabelFrame = CGRect(x: contentInset.left, y: nameLabelFrame.maxY + titleDetailMargin, width: leftWidth, height: dateHeight)
        
        let amountLeft = size.width - contentInset.right - rightWidth
        let amountHeight = ceil(valueLabel.sizeThatFits(CGSize(width: rightWidth, height: 0)).height)
        amountLabelFrame = CGRect(x: amountLeft, y: contentInset.top, width: rightWidth, height: amountHeight)
        
        return (nameLabelFrame, dateLabelFrame, amountLabelFrame)
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
}

// MARK: Public Intance Methods

extension TitleDetailValueCell {
    
    func update(titleText: String?, detailText: String?, valueText: String?) {
        titleLabel.text = titleText
        detailLabel.text = detailText
        valueLabel.text = valueText
        
        setNeedsLayout()
    }
}
