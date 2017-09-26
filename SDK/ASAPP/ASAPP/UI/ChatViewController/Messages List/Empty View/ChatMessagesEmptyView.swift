//
//  ChatMessagesEmptyView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesEmptyView: UIView {
    
    var title: String? {
        didSet {
            titleLabel.text = title
            setNeedsLayout()
        }
    }
    
    var message: String? {
        didSet {
            messageLabel.text =  message
            setNeedsLayout()
        }
    }
    
    // MARK: Private Properties
    
    private let titleLabel = UILabel()
    
    private let messageLabel = UILabel()
    
    private let titleMarginBottom: CGFloat = 10.0
        
    // MARK: Init
    
    func commonInit() {
        backgroundColor = ASAPP.styles.colors.messagesListBackground
        
        titleLabel.textColor = ASAPP.styles.colors.textPrimary
        titleLabel.updateFont(for: .header1)
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        
        messageLabel.textColor = ASAPP.styles.colors.textSecondary
        messageLabel.updateFont(for: .body)
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        addSubview(messageLabel)
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
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let width = floor(0.7 * bounds.width)
        let titleHeight = ceil(titleLabel.sizeThatFits(CGSize(width: width, height: 0)).height)
        let messageHeight = ceil(messageLabel.sizeThatFits(CGSize(width: width, height: 0)).height)
        let margin = (titleHeight > 0 || messageHeight > 0 ? titleMarginBottom : 0.0)
        let top = floor((bounds.height - titleHeight - messageHeight - margin) / 2.0)
        let left = floor((bounds.width - width) / 2.0)
        
        titleLabel.frame = CGRect(x: left, y: top, width: width, height: titleHeight)
        messageLabel.frame = CGRect(x: left, y: titleLabel.frame.maxY + margin, width: width, height: messageHeight)
    }
}
