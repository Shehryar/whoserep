//
//  ChatBillSummaryCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/17/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatBillSummaryCell: UITableViewCell, ASAPPStyleable {

    var contentInset = UIEdgeInsets(top: 5, left: 22, bottom: 5, right: 22) {
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
    
    private let stackView = SummaryDetailsView()
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .None
        
        stackView.applyStyles(styles)
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
    
    // MARK:- ASAPPStyleable
    
    private(set) var styles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        backgroundColor = styles.backgroundColor1
        stackView.applyStyles(styles)
    }
}

// MARK:- Layout

extension ChatBillSummaryCell {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let stackViewWidth = stackViewWidthForSize(bounds.size)
        var stackViewLeft = contentInset.left
        if !isReply {
            stackViewLeft = CGRectGetWidth(bounds) - contentInset.right - stackViewWidth
        }
        let stackViewHeight = CGRectGetHeight(bounds) - contentInset.top - contentInset.bottom
        
        stackView.frame = CGRect(x: stackViewLeft, y: contentInset.top, width: stackViewWidth, height: stackViewHeight)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let stackViewWidth = stackViewWidthForSize(size)
        let stackViewHeight = ceil(stackView.sizeThatFits(CGSize(width: stackViewWidth, height: 0)).height)
        
        return CGSize(width: size.width, height: stackViewHeight + contentInset.top + contentInset.bottom)
    }
    
    // MARK: Utility
    
    func stackViewWidthForSize(size: CGSize) -> CGFloat {
        let contentWidth = size.width - contentInset.left - contentInset.right
        return floor(0.95 * contentWidth)
    }
}
