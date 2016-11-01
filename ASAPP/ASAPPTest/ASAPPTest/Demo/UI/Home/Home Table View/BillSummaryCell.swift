//
//  BillSummaryCell.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class BillSummaryCell: TableViewCell {

    let currentBalanceLabel = UILabel()
    
    let currentBalanceMarginBottom: CGFloat = 4.0
    
    let dueDateLabel = UILabel()
    
    let amountMarginLeft: CGFloat = 16.0
    
    let amountLabel = UILabel()
    
    override func commonInit() {
        super.commonInit()
        
        contentView.addSubview(currentBalanceLabel)
        contentView.addSubview(dueDateLabel)
        contentView.addSubview(amountLabel)
        
        updateLabels()
    }

    // MARK:- App Settings
    
    override func applyAppSettings() {
        super.applyAppSettings()
     
        updateLabels()
        
        setNeedsLayout()
    }
    
    func updateLabels() {
        
        currentBalanceLabel.attributedText = NSAttributedString(string: "Current Balance", attributes: [
            NSForegroundColorAttributeName : appSettings?.foregroundColor ?? UIColor.darkText,
            NSFontAttributeName : DemoFonts.latoRegularFont(withSize: 20),
            NSKernAttributeName : 0.2
            ])
        
        let dueDate = Date(timeIntervalSinceNow: 60 * 60 * 24 * 14)
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "MMMM dd"
        dueDateLabel.attributedText = NSAttributedString(string: "Due on \(dateFormatter.string(from: dueDate))", attributes: [
            NSForegroundColorAttributeName : appSettings?.foregroundColor ?? UIColor.darkText,
            NSFontAttributeName : DemoFonts.latoLightFont(withSize: 14),
            NSKernAttributeName : 0.5
            ])
        
        amountLabel.attributedText = NSAttributedString(string: "$126.22", attributes: [
            NSForegroundColorAttributeName : appSettings?.foregroundColor ?? UIColor.darkText,
            NSFontAttributeName : DemoFonts.latoBoldFont(withSize: 22),
            NSKernAttributeName : 0.4
            ])
        
        setNeedsLayout()
    }
    
    
    // MARK:- Layout
    
    func framesThatFit(_ size: CGSize) -> (CGRect, CGRect, CGRect) {
        var amountSize = amountLabel.sizeThatFits(CGSize(width: size.width - contentInset.left - contentInset.right, height: 0))
        amountSize.width = ceil(amountSize.width)
        amountSize.height = ceil(amountSize.height)
        
        let labelWidth = size.width - contentInset.right - amountSize.width - amountMarginLeft - contentInset.left
        let labelSizer = CGSize(width: labelWidth, height: 0)
        let currentBalanceHeight = ceil(currentBalanceLabel.sizeThatFits(labelSizer).height)
        let dueDateHeight = ceil(dueDateLabel.sizeThatFits(labelSizer).height)
        let totalLabelHeight = currentBalanceHeight + dueDateHeight + currentBalanceMarginBottom
        
        let labelTop = contentInset.top + max(0, floor((amountSize.height - totalLabelHeight) / 2.0))
        let currentBalanceFrame = CGRect(x: contentInset.left, y: labelTop, width: labelWidth, height: currentBalanceHeight)
        
        let dueDateFrame = CGRect(x: contentInset.left, y: currentBalanceFrame.maxY + currentBalanceMarginBottom, width: labelWidth, height: dueDateHeight)
        
        let amountLeft = size.width - amountSize.width - contentInset.right
        let amountTop = contentInset.top + max(0, floor((totalLabelHeight - amountSize.height) / 2.0))
        let amountLabelFrame = CGRect(x: amountLeft, y: amountTop, width: amountSize.width, height: amountSize.height)
        
        return (currentBalanceFrame, dueDateFrame, amountLabelFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
     
        let (currentBalanceFrame, dueDateFrame, amountFrame) = framesThatFit(bounds.size)
        currentBalanceLabel.frame = currentBalanceFrame
        dueDateLabel.frame = dueDateFrame
        amountLabel.frame = amountFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (currentBalanceFrame, dueDateFrame, amountFrame) = framesThatFit(size)
        let height = max(currentBalanceFrame.maxY, dueDateFrame.maxY, amountFrame.maxY) + contentInset.bottom
        
        return CGSize(width: size.width, height: height)
    }
}
