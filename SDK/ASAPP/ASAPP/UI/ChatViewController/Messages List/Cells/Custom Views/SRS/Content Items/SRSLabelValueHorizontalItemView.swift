//
//  SRSLabelValueHorizontalItemView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSLabelValueHorizontalItemView: SRSLabelValueItemView {

    // MARK:- Properties
    
    override var labelFont: UIFont {
        return ASAPP.styles.font(for: .srsInfoLabelH)
    }
    
    override var labelColor: UIColor {
        return labelValueItem?.label?.color ?? ASAPP.styles.primaryTextColor
    }
    
    override var labelKern: CGFloat {
        return 0.5
    }
    
    override var labelAlignment: NSTextAlignment {
        return labelValueItem?.label?.alignment?.getNSTextAlignment() ?? .left
    }
    
    override var valueFont: UIFont {
        return ASAPP.styles.font(for: .srsInfoValueH)
    }
    
    override var valueColor: UIColor {
        return labelValueItem?.value?.color ?? ASAPP.styles.primaryTextColor
    }
    
    override var valueKern: CGFloat {
        return 1
    }
    
    override var valueAlignment: NSTextAlignment {
        return labelValueItem?.value?.alignment?.getNSTextAlignment() ?? .right
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
        let maxTextWidth = size.width - contentInset.left - contentInset.right
        
        // Get Value Size
        let maxValueWidth = floor(maxTextWidth / 2.0)
        var valueSize = valueLabel.sizeThatFits(CGSize(width: maxValueWidth, height: 0))
        valueSize.width = ceil(valueSize.width)
        valueSize.height = ceil(valueSize.height)
        
        // Get Label Size
        var maxLabelWidth = maxTextWidth
        if valueSize.width > 0 {
            maxLabelWidth = maxTextWidth - valueSize.width - labelValueMargin
        }
        var labelSize = labelLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 0))
        labelSize.width = ceil(labelSize.width)
        labelSize.height = ceil(labelSize.height)
    
        let valueLeft = size.width - contentInset.right - valueSize.width
        let valueFrame = CGRect(x: valueLeft, y: contentInset.top,
                                width: valueSize.width, height: valueSize.height)
        let labelFrame = CGRect(x: contentInset.left, y: contentInset.top,
                                width: labelSize.width, height: labelSize.height)
        
        return (labelFrame, valueFrame)
    }
}
