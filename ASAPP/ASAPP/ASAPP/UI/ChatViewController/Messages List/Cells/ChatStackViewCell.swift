//
//  ChatStackViewCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/17/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatStackViewCell: UITableViewCell {

    var contentInset = UIEdgeInsets(top: 2, left: 16, bottom: 2, right: 16) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var isReply: Bool = true {
        didSet {
            if oldValue != isReply {
                setNeedsLayout()
            }
        }
    }
    
    private let stackView = StackView()
    
    // MARK: Init
    
    func commonInit() {
        contentView.addSubview(stackView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
}

// MARK:- Layout

extension ChatStackViewCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let stackViewWidth = stackViewWidthForSize(bounds.size)
        var stackViewLeft = contentInset.left
        if !isReply {
            stackViewLeft = CGRectGetWidth(bounds) - contentInset.right - stackViewWidth
        }
        let stackViewHeight = CGRectGetHeight(bounds) - contentInset.top - contentInset.bottom
        
        stackView.frame = CGRect(x: stackViewLeft, y: stackViewLeft, width: stackViewWidth, height: stackViewHeight)
        stackView.updateArrangedSubviewFrames(updateFrameToFitContent: false)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let stackViewWidth = stackViewWidthForSize(size)
        let stackViewHeight = ceil(stackView.sizeThatFits(CGSize(width: stackViewWidth, height: 0)).height)
        
        return CGSize(width: size.width, height: stackViewHeight + contentInset.top + contentInset.bottom)
    }
    
    // MARK: Utility
    
    func stackViewWidthForSize(size: CGSize) -> CGFloat {
        let contentWidth = size.width - contentInset.left - contentInset.right
        return floor(0.67 * contentWidth)
    }
}
