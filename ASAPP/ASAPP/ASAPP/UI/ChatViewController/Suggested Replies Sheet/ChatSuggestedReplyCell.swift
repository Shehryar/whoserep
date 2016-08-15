//
//  ChatSuggestedReplyCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatSuggestedReplyCell: UITableViewCell {

    var contentInset = UIEdgeInsets(top: 16, left: 16, bottom: 16, right: 16)
    
    var separatorBottomColor: UIColor? {
        didSet {
            separatorBottomView.backgroundColor = separatorBottomColor
        }
    }
    
    var selectedBackgroundColor: UIColor? {
        didSet {
            if let selectedBackgroundColor = selectedBackgroundColor {
                customSelectedBackgroundView.backgroundColor = selectedBackgroundColor
                selectedBackgroundView = customSelectedBackgroundView
            } else {
                selectedBackgroundView = nil
            }
        }
    }
    
    private let separatorBottomView = UIView()
    
    private let customSelectedBackgroundView = UIView()
    
    // MARK: Init
    
    func commonInit() {
        contentView.addSubview(separatorBottomView)
        
        textLabel?.textAlignment = .Center
        textLabel?.numberOfLines = 0
        textLabel?.lineBreakMode = .ByTruncatingTail
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: .Default, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        textLabel?.frame = UIEdgeInsetsInsetRect(bounds, contentInset)
        
        let separatorStroke: CGFloat = 1.0
        let separatorTop: CGFloat = CGRectGetHeight(bounds) - separatorStroke
        separatorBottomView.frame = CGRect(x: 0.0, y: separatorTop, width: CGRectGetWidth(bounds), height: separatorStroke)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var maxContentWidth = (size.width > 0 ? size.width : CGFloat.max) - contentInset.left - contentInset.right
        var maxContentHeight = (size.height > 0 ? size.height : CGFloat.max) - contentInset.top - contentInset.bottom
        
        var contentHeight: CGFloat = 0
        if let textLabel = textLabel {
            contentHeight = ceil(textLabel.sizeThatFits(CGSize(width: maxContentWidth, height: maxContentHeight)).height)
        }
        
        var fittedHeight = contentHeight
        if fittedHeight > 0 {
            fittedHeight += contentInset.top + contentInset.bottom
        }
        
        return CGSize(width: size.width, height: fittedHeight)
    }
    
    // MARK: Selected / Highlighted
    
    override func setSelected(selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        
        separatorBottomView.backgroundColor = separatorBottomColor
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        
        separatorBottomView.backgroundColor = separatorBottomColor
    }
}
