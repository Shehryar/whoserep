//
//  SRSLabelItemView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SRSLabelItemView: UIView, ASAPPStyleable {

    var labelItem: SRSLabelItem? {
        didSet {
            updateDisplay()
        }
    }
    
    let contentInset: UIEdgeInsets = .zero
    
    private let label = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        label.numberOfLines = 0
        label.lineBreakMode = .byTruncatingTail
        addSubview(label)
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
    
    fileprivate(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        updateDisplay()
    }
    
    // MARK: Display
    
    func updateDisplay() {
        label.textAlignment = labelItem?.alignment?.getNSTextAlignment() ?? .center
        
        let textColor = labelItem?.color ?? styles.foregroundColor2
        label.setAttributedText(labelItem?.text,
                                textStyle: .srsLabel,
                                color: textColor,
                                styles: styles)
        
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    func getLabelFrameThatFits(_ size: CGSize) -> CGRect {
        let maxTextWidth = size.width - contentInset.left - contentInset.right
        let textHeight = ceil(label.sizeThatFits(CGSize(width: maxTextWidth, height: 0)).height)
        
        return CGRect(x: contentInset.left, y: contentInset.top, width: maxTextWidth, height: textHeight)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        label.frame = getLabelFrameThatFits(bounds.size)
        
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let labelFrame = getLabelFrameThatFits(size)
        let height: CGFloat
        if labelFrame.height > 0 {
            height = labelFrame.maxY + contentInset.bottom
        } else {
            height = 0
        }
        return CGSize(width: size.width, height: height)
    }

}
