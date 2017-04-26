//
//  SRSLabelValueVerticalItemView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSLabelValueVerticalItemView: SRSLabelValueItemView {
    
    // MARK:- Properties
    
    override var labelFont: UIFont {
        return ASAPP.styles.textStyles.body.font
    }
    
    override var labelColor: UIColor {
        return labelValueItem?.label?.color ?? ASAPP.styles.colors.textSecondary
    }
    
    override var labelKern: CGFloat {
        return 1.2
    }
    
    override var labelAlignment: NSTextAlignment {
        return labelValueItem?.label?.alignment?.getNSTextAlignment() ?? .center
    }
    
    override var valueFont: UIFont {
        return ASAPP.styles.textStyles.header1.font
    }
    
    override var valueColor: UIColor {
        return labelValueItem?.value?.color ?? ASAPP.styles.colors.textPrimary
    }
    
    override var valueKern: CGFloat {
        return 1.2
    }
    
    override var valueAlignment: NSTextAlignment {
        return labelValueItem?.value?.alignment?.getNSTextAlignment() ?? .center
    }
    
    override var contentInset: UIEdgeInsets {
        return .zero
    }
    
    override var labelValueMargin: CGFloat {
        return 4.0
    }
    
    // MARK:- Layout
    
    /// Returns (label frame, value frame)
    override func getLabelValueFramesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        let maxWidth = size.width - contentInset.left - contentInset.right
        
        let valueHeight = ceil(valueLabel.sizeThatFits(CGSize(width: maxWidth, height: 0)).height)
        let valueFrame = CGRect(x: contentInset.left, y: contentInset.top, width: maxWidth, height: valueHeight)
        
        let labelHeight = ceil(labelLabel.sizeThatFits(CGSize(width: maxWidth, height: 0)).height)
        var labelTop: CGFloat = valueFrame.maxY + labelValueMargin
        if valueFrame.height == 0 {
            labelTop = contentInset.top
        }
        let labelFrame = CGRect(x: contentInset.left, y: labelTop, width: maxWidth, height: labelHeight)
        
        return (labelFrame, valueFrame)
    }
}
