//
//  ChatMessagesTimeHeaderView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesTimeHeaderView: UITableViewHeaderFooterView {
    
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var time: Date? {
        didSet { updateTimeLabel() }
    }
    
    private let timeLabel = UILabel()
    
    private let separatorLeft = HorizontalGradientView()
    
    private let separatorRight = HorizontalGradientView()
    
    private let dateFormatter = DateFormatter()
    
    // MARK: - Init
    
    func commonInit() {
        contentView.backgroundColor = ASAPP.styles.colors.messagesListBackground
        isOpaque = true
        
        timeLabel.backgroundColor = ASAPP.styles.colors.messagesListBackground
        timeLabel.textColor = ASAPP.styles.colors.textSecondary
        timeLabel.textAlignment = .center
        contentView.addSubview(timeLabel)
        
        let separatorColor = ASAPP.styles.colors.separatorPrimary
        separatorLeft.update(separatorColor.withAlphaComponent(0.0), rightColor: separatorColor)
        separatorRight.update(separatorColor, rightColor: separatorColor.withAlphaComponent(0.0))
        contentView.addSubview(separatorLeft)
        contentView.addSubview(separatorRight)
    }
    
    override init(reuseIdentifier: String?) {
        super.init(reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Instance Methods
    
    func timeTextForDate(_ date: Date) -> String {
        return dateFormatter.string(from: date)
    }
    
    func updateTimeLabel() {
        if let time = time {
            dateFormatter.dateFormat = time.dateFormatForMostRecent()
            let timestamp = dateFormatter.string(from: time)
            timeLabel.setAttributedText(timestamp, textType: .subheader)
        } else {
            timeLabel.attributedText = nil
        }
        setNeedsLayout()
    }
    
    // MARK: - Layout
    
    func textSizeForSize(_ size: CGSize) -> CGSize {
        let textWidth = size.width - contentInset.left - contentInset.right
        let textSize = timeLabel.sizeThatFits(CGSize(width: textWidth, height: 0))
        
        return CGSize(width: ceil(textSize.width), height: ceil(textSize.height))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let textSize = textSizeForSize(bounds.size)
        let textLeft = floor((bounds.width - textSize.width) / 2.0)
        timeLabel.frame = CGRect(x: textLeft, y: contentInset.top, width: textSize.width, height: textSize.height)
        
        let separatorMargin: CGFloat = 15.0
        let separatorStroke: CGFloat = ASAPP.styles.separatorStrokeWidth
        let separatorTop = ceil(timeLabel.center.y - separatorStroke / 2.0)
        let separatorLeftWidth = timeLabel.frame.minX - separatorMargin - contentInset.left
        separatorLeft.frame = CGRect(x: contentInset.left, y: separatorTop, width: separatorLeftWidth, height: separatorStroke)
        
        let separatorRightLeft = timeLabel.frame.maxX + separatorMargin
        let separatorRightWidth = bounds.width - contentInset.right - separatorRightLeft
        separatorRight.frame = CGRect(x: separatorRightLeft, y: separatorTop, width: separatorRightWidth, height: separatorStroke)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let textSize = textSizeForSize(size)
        return CGSize(width: size.width, height: textSize.height + contentInset.top + contentInset.bottom)
    }
}
