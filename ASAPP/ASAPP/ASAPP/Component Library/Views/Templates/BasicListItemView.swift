//
//  BasicListItemView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/17/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BasicListItemView: UIView, ComponentView {
 
    // MARK: Properties
    
    let titleLabel = UILabel()
    
    let detailLabel = UILabel()
    
    let valueLabel = UILabel()
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            
        }
    }
    
    // MARK: Init
    
    func commonInit() {
        titleLabel.font = ASAPP.styles.font(with: .regular, size: 14)
        titleLabel.textColor = ASAPP.styles.foregroundColor1
        addSubview(titleLabel)
        
        detailLabel.font = ASAPP.styles.font(with: .bold, size: 12)
        detailLabel.textColor = ASAPP.styles.foregroundColor2
        addSubview(detailLabel)
        
        valueLabel.font = ASAPP.styles.font(with: .black, size: 18)
        valueLabel.textColor = ASAPP.styles.foregroundColor1
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
    
    // MARK: Layout
    
    /*
    
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect, CGRect) {
        let contentWidth = size.width - contentInset.left - contentInset.right
        let col2MaxWidth = (size.width - columnSpacing) / 2.0
        
        var valueSize = valueLabel.sizeThatFits(CGSize(width: col2MaxWidth, height: 0))
        valueSize.width = ceil(valueSize.width)
        valueSize.height = ceil(valueSize.height)
        let col2Left = size.width - contentInset.right - valueSize.width
        
        let col1MaxWidth = col2Left - columnSpacing - contentInset.left
        let titleHeight = ceil(titleLabel.sizeThatFits(CGSize(width: col1MaxWidth, height: 0)).height)
        let detailHeight = ceil(detailLabel.sizeThatFits(CGSize(width: col1MaxWidth, height: 0)).height)
        
        let col1Left = contentInset.left
        var col1Height = titleHeight + detailHeight
        if titleHeight > 0 && detailHeight > 0 {
            col1Height += titleMarginBottom
        }
        
        let contentHeight = max(col1Height, valueSize.height) + contentInset.top + contentInset.bottom
        var col1Top = floor((contentHeight - col1Height) / 2.0)
        let titleFrame = CGRect(x: col1Left, y: col1Top, width: col1MaxWidth, height: titleHeight)
        if titleHeight > 0 {
            col1Top = titleFrame.maxY + titleMarginBottom
        }
        let detailFrame = CGRect(x: col1Left, y: col1Top, width: col1MaxWidth, height: detailHeight)
        
        let col2Top = floor((contentHeight - valueSize.height) / 2.0)
        let valueFrame = CGRect(x: col2Left, y: col2Top, width: valueSize.width, height: valueSize.height)
        
        return (titleFrame, detailFrame, valueFrame)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (titleFrame, detailFrame, valueFrame) = getFramesThatFit(bounds.size)
        titleLabel.frame = titleFrame
        detailLabel.frame = detailFrame
        valueLabel.frame = valueFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (titleFrame, detailFrame, valueFrame) = getFramesThatFit(size)
        var height: CGFloat = 0
        if titleFrame.height > 0 || detailFrame.height > 0 || valueFrame.height > 0 {
            let maxY = max(titleFrame.maxY, detailFrame.maxY, valueFrame.maxY)
            height = maxY + contentInset.bottom
        }
        return CGSize(width: size.width, height: height)
    }
 */
}
