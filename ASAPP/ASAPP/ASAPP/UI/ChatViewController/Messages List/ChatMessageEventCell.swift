//
//  ChatMessageEventCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SnapKit

enum MessageBubbleStyling {
    case Default
    case FirstOfMany
    case MiddleOfMany
    case LastOfMany
}

class ChatMessageEventCell: UITableViewCell {
    
    // MARK: Public Properties
    
    var messageEvent: Event? {
        didSet {
            if let messageEvent = messageEvent {
                messageView.message = (messageEvent.payload as? EventPayload.TextMessage)?.text
            } else {
                messageView.message = nil
            }
        }
    }
    
    var isReply: Bool = false {
        didSet {
            if oldValue != isReply {
                updateForIsReplyValue()
            }
        }
    }
    
    var bubbleStyling: MessageBubbleStyling = .Default {
        didSet {
            if oldValue != bubbleStyling {
                updateBubbleCorners()
            }
        }
    }
    
    var contentInset = UIEdgeInsetsMake(2, 16, 2, 16) {
        didSet {
            if oldValue != contentInset {
                setNeedsUpdateConstraints()
            }
        }
    }
    
    // MARK: Properties
    
    private let messageView = BubbleMessageView()
    
    private var leftConstraint: Constraint?
    
    private var rightConstraint: Constraint?
    
    private var animating = false
    
    private var animationStartTime: Double = 0.0
    
    // MARK: Init
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    func commonInit() {
        selectionStyle = .None
        
        messageView.translatesAutoresizingMaskIntoConstraints = false
        contentView.addSubview(messageView)
        
        updateForIsReplyValue()
    }
    
    // MARK: Styling
    
    func updateForIsReplyValue() {
        if isReply {
            messageView.bubbleFillColor = UIColor(red:0.226,  green:0.605,  blue:0.852, alpha:1)//Colors.lighterGrayColor()
            messageView.bubbleStrokeColor = nil
            messageView.textColor = UIColor.whiteColor() //Colors.darkTextColor()
        } else {
            messageView.bubbleFillColor = Colors.whiteColor()
            messageView.bubbleStrokeColor = Colors.lightGrayColor()
            messageView.textColor = Colors.darkTextColor()
        }
        updateBubbleCorners()
        
        setNeedsUpdateConstraints()
    }
    
    func updateBubbleCorners() {
        var roundedCorners: UIRectCorner
        if isReply {
            switch bubbleStyling {
            case .Default:
                roundedCorners = [.TopLeft, .TopRight, .BottomRight]
                break
                
            case .FirstOfMany:
                roundedCorners =  .AllCorners//[.TopLeft, .TopRight, .BottomRight] // FB-style
                break
                
            case .MiddleOfMany:
                roundedCorners =  .AllCorners//[.TopRight, .BottomRight]
                break
                
            case .LastOfMany:
                roundedCorners = [.TopLeft, .TopRight, .BottomRight]//[.TopRight, .BottomRight, .BottomLeft]
                break
            }
        } else {
            switch bubbleStyling {
            case .Default:
                roundedCorners = [.TopRight, .TopLeft, .BottomLeft]
                break
                
            case .FirstOfMany:
                roundedCorners = .AllCorners//[.TopRight, .TopLeft, .BottomLeft]
                break
                
            case .MiddleOfMany:
                roundedCorners = .AllCorners// [.TopLeft, .BottomLeft]
                break
                
            case .LastOfMany:
                roundedCorners =  [.TopRight, .TopLeft, .BottomLeft] //[.TopLeft, .BottomLeft, .BottomRight]
                break
            }
        }
        messageView.bubbleViewRoundedCorners = roundedCorners
    }
    
    // MARK: Layout
    
    override func updateConstraints() {
        leftConstraint?.uninstall()
        rightConstraint?.uninstall()
        
        let maxMessageWidth = floor(0.8 * (CGRectGetWidth(bounds) - contentInset.left - contentInset.right))
        
        messageView.snp_updateConstraints { (make) in
            if isReply {
                self.leftConstraint = make.left.equalTo(contentView.snp_left).offset(contentInset.left).constraint
            } else {
                self.rightConstraint = make.right.equalTo(contentView.snp_right).offset(-contentInset.right).constraint
            }
            make.top.equalTo(contentView.snp_top).offset(contentInset.top)
            make.width.lessThanOrEqualTo(maxMessageWidth)
        }
        
        contentView.snp_updateConstraints { (make) in
            make.edges.equalTo(self)
            make.height.greaterThanOrEqualTo(messageView.snp_height).offset(contentInset.top + contentInset.bottom)
        }
        super.updateConstraints()
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.removeAllAnimations()
        messageView.alpha = 1
        messageView.transform = CGAffineTransformIdentity
        animationStartTime = 0
        animating = false
    }
    
    // MARK: Instance Methods
    
    func animate() {
        if animating {
            return
        }
        animating = true
        animationStartTime = NSDate().timeIntervalSince1970
        let blockStartTime = animationStartTime
        
        messageView.alpha = 0

        Dispatcher.delay(100) {
            if self.animating && self.animationStartTime == blockStartTime {
                self.performAnimation()
            }
        }
    }
    
    private func performAnimation() {
        var animationBeginCenter = CGPoint(x: 0, y: CGRectGetHeight(bounds) - contentInset.bottom)
        if isReply {
            animationBeginCenter.x = contentInset.left
        } else {
            animationBeginCenter.x = CGRectGetWidth(bounds) - contentInset.right
        }
        
        var animationEndCenter = CGPoint()
        if messageView.bounds.isEmpty {
            let messageSize = messageView.sizeThatFits(bounds.size)
            animationEndCenter.y = CGRectGetHeight(bounds) - contentInset.bottom - messageSize.height / 2.0
            if isReply {
                animationEndCenter.x = contentInset.left + messageSize.width / 2.0
            } else {
                animationEndCenter.x = CGRectGetWidth(bounds) - contentInset.right - messageSize.width / 2.0
            }
        } else {
            animationEndCenter = messageView.center
        }
        
        messageView.alpha = 0
        messageView.transform = CGAffineTransformMakeScale(0.01, 0.01)
        messageView.center = animationBeginCenter
        
        UIView.animateKeyframesWithDuration(0.2, delay: 0, options: .BeginFromCurrentState, animations: {
            self.messageView.alpha = 1
            self.messageView.transform = CGAffineTransformIdentity
            self.messageView.center = animationEndCenter
            }, completion: { (completed) in
                self.setNeedsLayout()
                self.animating = false
        })
    }
    
    // MARK: Overriding Selected/Highlighted
    
    override func setSelected(selected: Bool, animated: Bool) {
        // No-op
    }
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        // No-op
    }
}
