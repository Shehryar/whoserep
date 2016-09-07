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
            orientation = infoItem?.orientation ?? .Vertical
            labelLabel.text = infoItem?.label
            valueLabel.text = infoItem?.value
            applyStyles(styles)
            setNeedsLayout()
        }
    }
    
    var labelMargin: CGFloat = 4 {
        didSet {
            setNeedsLayout()
        }
    }
    
    private(set) var orientation: SRSInfoItemOrientation = .Vertical {
        didSet {
            if oldValue != orientation {
                setNeedsLayout()
            }
        }
    }
    
    private let labelLabel = UILabel()
    private let valueLabel = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        labelLabel.numberOfLines = 0
        labelLabel.lineBreakMode = .ByTruncatingTail
        labelLabel.textAlignment = .Center
        addSubview(labelLabel)
        
        valueLabel.numberOfLines = 0
        valueLabel.lineBreakMode = .ByTruncatingTail
        valueLabel.textAlignment = .Center
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
    
    private(set) var styles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        if orientation == .Vertical {
            labelLabel.font = styles.detailFont
            labelLabel.textColor = styles.foregroundColor1
            
            valueLabel.font = styles.headlineFont
            valueLabel.textColor = styles.foregroundColor1
        } else {
            labelLabel.font = styles.bodyFont
            labelLabel.textColor = styles.foregroundColor2
            
            valueLabel.font = styles.bodyBoldFont
            valueLabel.textColor = styles.foregroundColor1
        }
        
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    func labelSizesForSize(size: CGSize) -> (/* label */ CGSize,  /* value */ CGSize) {
        if orientation == .Vertical {
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
        
        if orientation == .Vertical {
            var origin = CGPointZero
            labelLabel.frame = CGRect(origin: origin, size: labelSize)
            
            origin.y = CGRectGetMaxY(labelLabel.frame)
            if origin.y > 0 {
                origin.y += labelMargin
            }
            valueLabel.frame = CGRect(origin: origin, size: valueSize)
        } else {
            labelLabel.frame = CGRect(x: 0, y: 0, width: labelSize.width, height: labelSize.height)
            let valueLeft = CGRectGetWidth(bounds) - valueSize.width
            valueLabel.frame = CGRect(x: valueLeft, y: 0, width: valueSize.width, height: valueSize.height)
        }
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let (labelSize, valueSize) = labelSizesForSize(bounds.size)
        
        if orientation == .Vertical {
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
