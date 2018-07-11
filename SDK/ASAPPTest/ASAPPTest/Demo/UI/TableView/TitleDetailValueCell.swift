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
        
        titleLabel.font = DemoFonts.asapp.regular.changingOnlySize(16)
        titleLabel.textColor = UIColor.darkText
        titleLabel.kerning = 1
        contentView.addSubview(titleLabel)
        
        detailLabel.font = DemoFonts.asapp.light
        detailLabel.textColor = UIColor.gray
        detailLabel.numberOfLines = 0
        detailLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(detailLabel)
        
        valueLabel.font = DemoFonts.asapp.light.changingOnlySize(16)
        valueLabel.textColor = UIColor.darkText
        valueLabel.textAlignment = .right
        valueLabel.numberOfLines = 0
        valueLabel.lineBreakMode = .byTruncatingTail
        contentView.addSubview(valueLabel)
    }
    
    // MARK: - AppSettings
    
    override func applyAppSettings() {
        super.applyAppSettings()
        
        if let appSettings = appSettings {
            titleLabel.font = appSettings.branding.fontFamily.regular.changingOnlySize(16)
            detailLabel.font = appSettings.branding.fontFamily.light.changingOnlySize(14)
            valueLabel.font = appSettings.branding.fontFamily.light.changingOnlySize(16)
            
            titleLabel.textColor = appSettings.branding.colors.foregroundColor
            detailLabel.textColor = appSettings.branding.colors.secondaryTextColor
            valueLabel.textColor = appSettings.branding.colors.foregroundColor
        }
    }
    
    // MARK: - Layout
    
    private struct CalculatedLayout {
        let titleLabelFrame: CGRect
        let detailLabelFrame: CGRect
        let valueLabelFrame: CGRect
    }
    
    private func labelFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        let contentWidth = size.width - contentInset.left - contentInset.right
        let columnSpacing: CGFloat = 10
        
        func ceilSize(_ sizeToCeil: CGSize) -> CGSize {
            return CGSize(width: ceil(sizeToCeil.width), height: ceil(sizeToCeil.height))
        }
        
        var titleSize = ceilSize(titleLabel.sizeThatFits(.zero))
        var detailSize = ceilSize(detailLabel.sizeThatFits(.zero))
        var valueSize = ceilSize(valueLabel.sizeThatFits(.zero))
        
        if max(titleSize.width, detailSize.width) >= contentWidth - valueSize.width - columnSpacing {
            let leftRelativeSize: CGFloat = max(titleSize.width, detailSize.width) > valueSize.width ? 0.55 : 0.45
            let leftWidth = floor(contentWidth * leftRelativeSize)
            let rightWidth = contentWidth - leftWidth - columnSpacing
            let titleHeight = ceil(titleLabel.sizeThatFits(CGSize(width: leftWidth, height: 0)).height)
            let detailHeight = ceil(detailLabel.sizeThatFits(CGSize(width: leftWidth, height: 0)).height)
            let valueHeight = ceil(valueLabel.sizeThatFits(CGSize(width: rightWidth, height: 0)).height)
            
            titleSize = CGSize(width: leftWidth, height: titleHeight)
            detailSize = CGSize(width: leftWidth, height: detailHeight)
            valueSize = CGSize(width: rightWidth, height: valueHeight)
        }
        
        var leftColumnHeight = ceil(titleSize.height) + ceil(detailSize.height)
        if titleSize.height > 0 && detailSize.height > 0 {
            leftColumnHeight += self.titleDetailMargin
        }
        let contentHeight = max(leftColumnHeight, valueSize.height)
        
        // Left Column
        let leftColumnTop = self.contentInset.top + floor((contentHeight - leftColumnHeight) / 2.0)
        let titleLabelFrame = CGRect(x: self.contentInset.left, y: leftColumnTop,
                                     width: ceil(titleSize.width), height: ceil(titleSize.height))
        
        let detailTop = titleLabelFrame.maxY + (titleSize.height > 0 ? self.titleDetailMargin : 0.0)
        let detailLabelFrame = CGRect(x: self.contentInset.left, y: detailTop,
                                      width: ceil(detailSize.width), height: ceil(detailSize.height))
        
        // Right Column
        let rightColumnLeft = size.width - self.contentInset.right - ceil(valueSize.width)
        let rightColumnTop = self.contentInset.top + floor((contentHeight - valueSize.height) / 2.0)
        let valueLabelFrame = CGRect(x: rightColumnLeft, y: rightColumnTop,
                                     width: ceil(valueSize.width), height: ceil(valueSize.height))
        
        return CalculatedLayout(titleLabelFrame: titleLabelFrame, detailLabelFrame: detailLabelFrame, valueLabelFrame: valueLabelFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let layout = labelFramesThatFit(bounds.size)
        titleLabel.frame = layout.titleLabelFrame
        detailLabel.frame = layout.detailLabelFrame
        valueLabel.frame = layout.valueLabelFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = labelFramesThatFit(size)
        var height = max(layout.titleLabelFrame.maxY, layout.valueLabelFrame.maxY)
        if !layout.detailLabelFrame.isEmpty {
            height = max(height, layout.detailLabelFrame.maxY)
        }
        height += contentInset.bottom
        
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
