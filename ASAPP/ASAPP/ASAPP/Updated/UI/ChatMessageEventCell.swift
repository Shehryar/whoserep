//
//  ChatMessageEventCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SnapKit

class ChatMessageEventCell: UITableViewCell {

    // MARK: Public Properties
    
    var messageEvent: Event? {
        didSet {
            messageView.message = (messageEvent?.payload as? EventPayload.TextMessage)?.text
            messageView.isReply = isReply
            setNeedsUpdateConstraints()
        }
    }
    
    var isReply: Bool {
        if let messageEvent = messageEvent {
            return !messageEvent.isCustomerEvent
        }
        return true
    }
    
    var contentInset = UIEdgeInsetsMake(4, 8, 4, 8) {
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
            make.left.equalTo(self.snp_left)
            make.top.equalTo(self.snp_top)
            make.width.equalTo(self.snp_width)
            make.height.greaterThanOrEqualTo(messageView.snp_height).offset(contentInset.top + contentInset.bottom)
        }
        super.updateConstraints()
    }
    
    // MARK: Instance Methods
    
    func animate() {
//        return
        
        if animating {
            return
        }
        animating = true
        
        messageView.alpha = 0
        
        delay(100) {  self.performAnimation() }
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
