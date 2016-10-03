//
//  SRSInfoItemView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSInfoItemView: UIView, ASAPPStyleable {

    var infoItem: SRSInfoItem? {
        didSet {
            orientation = infoItem?.orientation ?? .vertical
            updateAttributedStrings()
        }
    }
    
    var labelMargin: CGFloat = 4 {
        didSet {
            setNeedsLayout()
        }
    }
    
    fileprivate(set) var orientation: SRSInfoItemOrientation = .vertical {
        didSet {
            if oldValue != orientation {
                setNeedsLayout()
            }
        }
    }
    
    fileprivate let labelLabel = UILabel()
    fileprivate let valueLabel = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        labelLabel.numberOfLines = 0
        labelLabel.lineBreakMode = .byTruncatingTail
        labelLabel.textAlignment = .center
        addSubview(labelLabel)
        
        valueLabel.numberOfLines = 0
        valueLabel.lineBreakMode = .byTruncatingTail
        valueLabel.textAlignment = .center
        addSubview(valueLabel)
        
        applyStyles(styles)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: ASAPPStyleable
    
    fileprivate(set) var styles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        
        updateAttributedStrings()
        
        setNeedsLayout()
    }
    
    // Updating Labels
    
    func getLabelLabelFontAndTextColor() -> (UIFont, UIColor) {
        if orientation == .vertical {
            return (styles.detailFont, styles.foregroundColor2)
        } else {
            return (styles.bodyFont, styles.foregroundColor2)
        }
    }
    
    func getValueLabelFontAndTextColor() -> (UIFont, UIColor) {
        if orientation == .vertical {
            return (styles.headlineFont, styles.foregroundColor1)
        } else {
            return (styles.bodyBoldFont, styles.foregroundColor1)
        }
    }
    
    func updateAttributedStrings() {
        let (labelLabelFont, labelLabelTextColor) = getLabelLabelFontAndTextColor()
        let (valueLabelFont, valueLabelTextColor) = getValueLabelFontAndTextColor()
        
        if let labelText = infoItem?.label {
            labelLabel.attributedText = NSAttributedString(string: labelText, attributes: [
                NSFontAttributeName : labelLabelFont,
                NSForegroundColorAttributeName : labelLabelTextColor,
                NSKernAttributeName : 1.2
                ])
        } else {
            labelLabel.attributedText = nil
        }
        
        if let valueText = infoItem?.value {
            valueLabel.attributedText = NSAttributedString(string: valueText, attributes: [
                NSFontAttributeName : valueLabelFont,
                NSForegroundColorAttributeName : valueLabelTextColor,
                NSKernAttributeName : 1.2
                ])
        } else {
            valueLabel.text = nil
        }
    }
    
    // MARK: Layout
    
    func labelSizesForSize(_ size: CGSize) -> (/* label */ CGSize,  /* value */ CGSize) {
        if orientation == .vertical {
            let labelHeight = ceil(labelLabel.sizeThatFits(CGSize(width: size.width, height: 0)).height)
            let valueHeight = ceil(valueLabel.sizeThatFits(CGSize(width: size.width, height: 0)).height)
            
            return (CGSize(width: size.width, height: labelHeight),
                    CGSize(width: size.width, height: valueHeight))
        }
        
        let maxValueWidth = floor(size.width / 2.0)
        var valueSize = valueLabel.sizeThatFits(CGSize(width: maxValueWidth, height: 0))
        valueSize.width = ceil(valueSize.width)
        valueSize.height = ceil(valueSize.height)
        
        var maxLabelWidth = size.width
        if valueSize.width > 0 {
            maxLabelWidth = size.width - valueSize.width - labelMargin
        }
        var labelSize = labelLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: 0))
        labelSize.width = ceil(labelSize.width)
        labelSize.height = ceil(labelSize.height)
        
        return (labelSize, valueSize)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (labelSize, valueSize) = labelSizesForSize(bounds.size)
        
        if orientation == .vertical {
            var origin = CGPoint.zero
            valueLabel.frame = CGRect(origin: origin, size: valueSize)
            
            origin.y = valueLabel.frame.maxY
            if valueSize.height > 0 && labelSize.height > 0 {
                origin.y += labelMargin
            }
            labelLabel.frame = CGRect(origin: origin, size: labelSize)
            
        } else {
            labelLabel.frame = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
            let valueLeft = bounds.width - valueSize.width
            valueLabel.frame = CGRect(x: valueLeft, y: 0, width: valueSize.width, height: valueSize.height)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (labelSize, valueSize) = labelSizesForSize(bounds.size)
        
        if orientation == .vertical {
            var margin: CGFloat = 0
            if labelSize.height > 0 || valueSize.height > 0 {
                margin = labelMargin
            }
            return CGSize(width: size.width, height: labelSize.height + valueSize.height + margin)
        } else {
            let contentHeight = max(labelSize.height, valueSize.height)
            return CGSize(width: size.width, height: contentHeight)
        }
    }
}
