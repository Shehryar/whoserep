//
//  ChatMessagesTimeHeaderView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesTimeHeaderView: UITableViewHeaderFooterView, ASAPPStyleable {
    
    var contentInset: UIEdgeInsets = UIEdgeInsets(top: 12, left: 22, bottom: 12, right: 22) {
        didSet {
            setNeedsLayout()
        }
    }
    
    var timeStampInSeconds: Double = 0.0 {
        didSet { updateTimeLabel() }
    }
    
    private let timeLabel = UILabel()
    
    private let separatorLeft = HorizontalGradientView()
    
    private let separatorRight = HorizontalGradientView()
    
    private let dateFormatter = NSDateFormatter()
    
    // MARK:- Init
    
    func commonInit() {
        opaque = true
        
        timeLabel.font = Fonts.latoBoldFont(withSize: 12)
        timeLabel.textColor = Colors.mediumTextColor()
        timeLabel.textAlignment = .Center
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
    
    func timeTextForDate(date: NSDate) -> String {
        var dateFormat: String
        if date.isToday() {
            dateFormat = "h:mma"
        } else if date.isYesterday() {
            dateFormat = "'Yesterday at' h:mma"
        } else if date.isThisYear() {
            dateFormat = "MMMM d 'at' h:mma"
        } else {
            dateFormat = "MMMM d, yyyy 'at' h:mma"
        }
        dateFormatter.dateFormat = dateFormat
        
        return dateFormatter.stringFromDate(date)
    }
    
    func updateTimeLabel() {
        timeLabel.text = timeTextForDate(NSDate(timeIntervalSince1970: timeStampInSeconds ))
        setNeedsLayout()
    }
    
    // MARK:- Layout
    
    func textSizeForSize(size: CGSize) -> CGSize {
        let textWidth = size.width - contentInset.left - contentInset.right
        let textSize = timeLabel.sizeThatFits(CGSize(width: textWidth, height: 0))
        
        return CGSize(width: ceil(textSize.width), height: ceil(textSize.height))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let textSize = textSizeForSize(bounds.size)
        let textLeft = floor((CGRectGetWidth(bounds) - textSize.width) / 2.0)
        timeLabel.frame = CGRect(x: textLeft, y: contentInset.top, width: textSize.width, height: textSize.height)
        
        let separatorMargin: CGFloat = 15.0
        let separatorStroke: CGFloat = 1.0
        let separatorTop = ceil(timeLabel.center.y - separatorStroke)
        let separatorLeftWidth = CGRectGetMinX(timeLabel.frame) - separatorMargin - contentInset.left
        separatorLeft.frame = CGRect(x: contentInset.left, y: separatorTop, width: separatorLeftWidth, height: separatorStroke)
        
        let separatorRightLeft = CGRectGetMaxX(timeLabel.frame) + separatorMargin
        let separatorRightWidth = CGRectGetWidth(bounds) - contentInset.right - separatorRightLeft
        separatorRight.frame = CGRect(x: separatorRightLeft, y: separatorTop, width: separatorRightWidth, height: separatorStroke)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let textSize = textSizeForSize(size)
        return CGSize(width: size.width, height: textSize.height + contentInset.top + contentInset.bottom)
    }
    
    // MARK:- ASAPPStyleable
    
    private(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        contentView.backgroundColor = styles.backgroundColor1
        timeLabel.backgroundColor = styles.backgroundColor1
        timeLabel.font = styles.captionFont
        timeLabel.textColor = styles.foregroundColor2
        
        let separatorColor = styles.separatorColor1
        separatorLeft.update(separatorColor.colorWithAlphaComponent(0.0), rightColor: separatorColor)
        separatorRight.update(separatorColor, rightColor: separatorColor.colorWithAlphaComponent(0.0))
        
        setNeedsLayout()
    }
}
