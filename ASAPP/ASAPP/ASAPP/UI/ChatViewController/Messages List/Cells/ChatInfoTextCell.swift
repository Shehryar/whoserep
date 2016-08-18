//
//  ChatInfoTextCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/3/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatInfoTextCell: UITableViewCell, ASAPPStyleable {

    var infoText: String? {
        didSet {
            infoTextLabel.text = infoText
            setNeedsLayout()
        }
    }
    
    // MARK: Properties
    
    private let contentInset = UIEdgeInsets(top: 8, left: 32, bottom: 8, right: 32)
    
    private let textInset = UIEdgeInsets(top: 16, left: 32, bottom: 16, right: 32)
    
    private let infoTextLabel = UILabel()
    
    private let textContainerView = UIView()
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .None
        opaque = true
        
        textContainerView.backgroundColor = Colors.lightGrayColor()
        contentView.addSubview(textContainerView)
        
        infoTextLabel.backgroundColor = textContainerView.backgroundColor
        infoTextLabel.textAlignment = .Center
        infoTextLabel.numberOfLines = 0
        infoTextLabel.lineBreakMode = .ByTruncatingTail
        infoTextLabel.textColor = Colors.mediumTextColor()
        infoTextLabel.font = Fonts.latoBoldFont(withSize: 14)
        textContainerView.addSubview(infoTextLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    // MARK: ASAPPStyleable
    
    private(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        backgroundColor = styles.backgroundColor1
        textContainerView.backgroundColor = styles.backgroundColor2
        infoTextLabel.backgroundColor = textContainerView.backgroundColor
        infoTextLabel.textColor = styles.foregroundColor2
        infoTextLabel.font = styles.detailFont
        
        setNeedsLayout()
    }
    
    // MARK: Layout
    
    func textSizeForSize(size: CGSize) -> CGSize {
        let maxTextWidth = size.width - contentInset.left - contentInset.right - textInset.left - textInset.right
        let textSize = infoTextLabel.sizeThatFits(CGSize(width: maxTextWidth, height: 0))
        return CGSize(width: ceil(textSize.width), height: ceil(textSize.height))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let textSize = textSizeForSize(bounds.size)
        let containerWidth = textSize.width + textInset.left + textInset.right
        let containerHeight = textSize.height + textInset.top + textInset.bottom
        let containerLeft = floor((CGRectGetWidth(bounds) - containerWidth) / 2.0)
        textContainerView.frame = CGRect(x: containerLeft, y: contentInset.top, width: containerWidth, height: containerHeight)
        infoTextLabel.frame = UIEdgeInsetsInsetRect(textContainerView.bounds, textInset)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let textSize = textSizeForSize(size)
        let height = textSize.height + textInset.top + textInset.bottom + contentInset.top + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
}
