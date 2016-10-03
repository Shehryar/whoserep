//
//  ChatInfoMessageView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatInfoMessageView: UIView, ASAPPStyleable {
    
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
    
    fileprivate(set) var styles: ASAPPStyles = ASAPPStyles()
    
    // MARK: Private Properties
    
    fileprivate let titleLabel = UILabel()
    
    fileprivate let messageLabel = UILabel()
    
    fileprivate let titleMarginBottom: CGFloat = 10.0
        
    // MARK: Init
    
    func commonInit() {
        titleLabel.textAlignment = .center
        titleLabel.numberOfLines = 0
        addSubview(titleLabel)
        
        messageLabel.textAlignment = .center
        messageLabel.numberOfLines = 0
        addSubview(messageLabel)
        
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
    
    // MARK: Display
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        
        backgroundColor = styles.backgroundColor1
        
        titleLabel.textColor = styles.foregroundColor1
        titleLabel.font = styles.headlineFont
        
        messageLabel.textColor = styles.foregroundColor2
        messageLabel.font = styles.bodyFont
        
        setNeedsUpdateConstraints()
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
