//
//  TwoColumnLabelView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/18/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class TwoColumnLabelView: UIView {

    var contentInset = UIEdgeInsetsZero {
        didSet {
            setNeedsLayout()
        }
    }
    
    var leftColumnPercentageWidth: CGFloat = 0.7
    
    var labelSpacing: CGFloat = 8.0
    
    let leftLabel = UILabel()
    
    let rightLabel = UILabel()
    
    // MARK:- Init
    
    func commonInit() {
        leftLabel.numberOfLines = 0
        leftLabel.lineBreakMode = .ByTruncatingTail
        leftLabel.font = Fonts.latoRegularFont(withSize: 12)
        addSubview(leftLabel)
        
        rightLabel.numberOfLines = 0
        rightLabel.lineBreakMode = .ByTruncatingTail
        rightLabel.font = Fonts.latoBoldFont(withSize: 12)
        addSubview(rightLabel)
    }
    
    convenience init(leftText: String?, rightText: String?) {
        self.init()
        leftLabel.text = leftText
        rightLabel.text = rightText
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // Layout 
    
    func labelSizesThatFit(size: CGSize) -> (CGSize, CGSize) {
        let contentWidth = size.width - contentInset.left - contentInset.right
        
        let leftLabelWidth = floor(contentWidth * leftColumnPercentageWidth) - ceil(labelSpacing / 2.0)
        let leftLabelHeight = ceil(leftLabel.sizeThatFits(CGSize(width: leftLabelWidth, height: 0)).height)
        
        let rightLabelWidth = max(0, contentWidth - leftLabelWidth - ceil(labelSpacing / 2.0))
        var rightLabelHeight: CGFloat = 0.0
        if rightLabelWidth > 0 {
            rightLabelHeight = ceil(rightLabel.sizeThatFits(CGSize(width: rightLabelWidth, height: 0)).height)
        }
        
        let leftLabelSize = CGSize(width: leftLabelWidth, height: leftLabelHeight)
        let rightLabelSize = CGSize(width: rightLabelWidth, height: rightLabelHeight)
        
        return (leftLabelSize, rightLabelSize)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let (leftLabelSize, rightLabelSize) = labelSizesThatFit(bounds.size)
        
        leftLabel.frame = CGRect(x: contentInset.left, y: contentInset.top, width: leftLabelSize.width, height: leftLabelSize.height)
        
        let rightLabelLeft = CGRectGetMaxX(leftLabel.frame) + labelSpacing
        rightLabel.frame = CGRect(x: rightLabelLeft, y: contentInset.top, width: rightLabelSize.width, height: rightLabelSize.height)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let (leftLabelSize, rightLabelSize) = labelSizesThatFit(size)
        let height = max(leftLabelSize.height, rightLabelSize.height) + contentInset.top + contentInset.bottom
        
        return CGSize(width: size.width, height: height)
    }
}
