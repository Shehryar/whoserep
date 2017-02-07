//
//  ChatMessagesTimeHeaderView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesTimeHeaderView: UITableViewHeaderFooterView, ASAPPStyleable {
    
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 12, left: 16, bottom: 12, right: 16) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var timeStampInSeconds: Double = 0.0 {
        didSet { updateTimeLabel() }
    }
    
    fileprivate let timeLabel = UILabel()
    
    fileprivate let separatorLeft = HorizontalGradientView()
    
    fileprivate let separatorRight = HorizontalGradientView()
    
    fileprivate let dateFormatter = DateFormatter()
    
    // MARK:- Init
    
    func commonInit() {
        isOpaque = true
        
        timeLabel.textColor = Colors.mediumTextColor()
        timeLabel.textAlignment = .center
        timeLabel.backgroundColor = Colors.whiteColor()
        contentView.addSubview(timeLabel)
        
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
    
    // MARK:- Instance Methods
    
    func timeTextForDate(_ date: Date) -> String {
        dateFormatter.dateFormat = date.dateFormatForMostRecent()
        
        return dateFormatter.string(from: date)
    }
    
    func updateTimeLabel() {
        let timestamp = timeTextForDate(Date(timeIntervalSince1970: timeStampInSeconds))
        timeLabel.setAttributedText(timestamp,
                                    textStyle: .chatTimestamp,
                                    color: styles.foregroundColor2,
                                    styles: styles)
        setNeedsLayout()
    }
    
    // MARK:- Layout
    
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
        let separatorStroke: CGFloat = 1.0
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
    
    // MARK:- ASAPPStyleable
    
    fileprivate(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        
        contentView.backgroundColor = styles.backgroundColor1
        timeLabel.backgroundColor = styles.backgroundColor1
        timeLabel.updateFont(for: .chatTimestamp, styles: styles)
        timeLabel.textColor = styles.foregroundColor2
        
        let separatorColor = styles.separatorColor1
        separatorLeft.update(separatorColor.withAlphaComponent(0.0), rightColor: separatorColor)
        separatorRight.update(separatorColor, rightColor: separatorColor.withAlphaComponent(0.0))
        
        setNeedsLayout()
    }
}
