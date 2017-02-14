//
//  SRSLabelValueItemView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSLabelValueItemView: UIView, ASAPPStyleable {

    var labelValueItem: SRSLabelValueItem? {
        didSet {
            updateDisplay()
        }
    }

    // MARK: Subviews
    
    let labelLabel = UILabel()
    let valueLabel = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        labelLabel.numberOfLines = 0
        labelLabel.lineBreakMode = .byTruncatingTail
        addSubview(labelLabel)
        
        valueLabel.numberOfLines = 0
        valueLabel.lineBreakMode = .byTruncatingTail
        addSubview(valueLabel)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK:- ASAPPStyleable
    
    fileprivate(set) var styles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        
        updateDisplay()
    }
    
    // MARK: Display
    
    func updateDisplay() {
        // Label
        labelLabel.textAlignment = labelAlignment
        if let labelText = labelValueItem?.label?.text {
            labelLabel.attributedText = NSAttributedString(string: labelText, attributes: [
                NSFontAttributeName : labelFont,
                NSForegroundColorAttributeName : labelColor,
                NSKernAttributeName : labelKern
                ])
        } else {
            labelLabel.attributedText = nil
        }
        
        // Value
        valueLabel.textAlignment = valueAlignment
        if let valueText = labelValueItem?.value?.text {
            valueLabel.attributedText = NSAttributedString(string: valueText, attributes: [
                NSFontAttributeName : valueFont,
                NSForegroundColorAttributeName : valueColor,
                NSKernAttributeName : valueKern
                ])
        } else {
            valueLabel.attributedText = nil
        }
        
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (labelFrame, valueFrame) = getLabelValueFramesThatFit(bounds.size)
        labelLabel.frame = labelFrame
        valueLabel.frame = valueFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (labelFrame, valueFrame) = getLabelValueFramesThatFit(bounds.size)
        if labelFrame.height == 0 && valueFrame.height == 0 {
            return CGSize(width: size.width, height: 0)
        }
        
        let height = max(labelFrame.maxY, valueFrame.maxY) + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
    
    
    // MARK:- Subclasses should override the following, if desired
    // MARK:-
    
    
    // MARK: Properties
    
    var labelFont: UIFont {
        return styles.font(for: .srsInfoLabelV)
    }
    
    var labelColor: UIColor {
        return labelValueItem?.label?.color ?? styles.foregroundColor1
    }
    
    var labelKern: CGFloat {
        return 1.2
    }
    
    var labelAlignment: NSTextAlignment {
        return labelValueItem?.label?.alignment?.getNSTextAlignment() ?? .center
    }
    
    var valueFont: UIFont {
        return styles.font(for: .srsInfoValueV)
    }
    
    var valueColor: UIColor {
        return labelValueItem?.value?.color ?? styles.foregroundColor1
    }
    
    var valueKern: CGFloat {
        return 1.2
    }
    
    var valueAlignment: NSTextAlignment {
        return labelValueItem?.value?.alignment?.getNSTextAlignment() ?? .center
    }
    
    var contentInset: UIEdgeInsets {
        return .zero
    }
    
    var labelValueMargin: CGFloat {
        return 4.0
    }
    
    // MARK:- Layout
    
    /// Returns (label frame, value frame)
    func getLabelValueFramesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        return (.zero, .zero)
    }
}
