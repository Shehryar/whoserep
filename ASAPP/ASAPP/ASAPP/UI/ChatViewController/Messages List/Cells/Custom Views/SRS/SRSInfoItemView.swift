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
            labelLabel.text = infoItem?.label
            valueLabel.text = infoItem?.value
            setNeedsLayout()
        }
    }
    
    var labelMargin: CGFloat = 4 {
        didSet {
            setNeedsLayout()
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
        
        labelLabel.font = styles.detailFont
        labelLabel.textColor = styles.foregroundColor1
        
        valueLabel.font = styles.bodyFont
        valueLabel.textColor = styles.foregroundColor1
        
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = CGRectGetWidth(bounds)
        let labelHeight = ceil(labelLabel.sizeThatFits(CGSize(width: width, height: 0)).height)
        labelLabel.frame = CGRect(x: 0, y: 0, width: width, height: labelHeight)
        
        let valueHeight = ceil(valueLabel.sizeThatFits(CGSize(width: width, height: 0)).height)
        var valueTop = labelHeight
        if valueTop > 0 {
            valueTop += labelMargin
        }
        valueLabel.frame = CGRect(x: 0, y: valueTop, width: width, height: valueHeight)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let labelHeight = ceil(labelLabel.sizeThatFits(CGSize(width: size.width, height: 0)).height)
        let valueHeight = ceil(valueLabel.sizeThatFits(CGSize(width: size.width, height: 0)).height)
        var margin: CGFloat = 0
        if labelHeight > 0 && valueHeight > 0 {
            margin = labelMargin
        }
        
        return CGSize(width: size.width, height: labelHeight + valueHeight + margin)
    }
}
