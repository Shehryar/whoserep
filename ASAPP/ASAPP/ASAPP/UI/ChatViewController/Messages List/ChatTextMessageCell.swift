//
//  ChatTextMessageCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatTextMessageCell: ChatBubbleCell {
    
    // MARK: Public Properties
    
    var event: Event? {
        didSet {
            textMessageLabel.text = event?.textMessage?.text
        }
    }
    
    // MARK: Private Properties
    
    private let textInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    
    private var animating = false
    
    private var animationStartTime: Double = 0.0
    
    private let textMessageLabel = UILabel()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        textMessageLabel.translatesAutoresizingMaskIntoConstraints = false
        textMessageLabel.numberOfLines = 0
        textMessageLabel.font = Fonts.latoRegularFont(withSize: 16)
        textMessageLabel.textColor = Colors.whiteColor()
        bubbleView.addSubview(textMessageLabel)
        
        updateForIsReplyValue()
        setNeedsUpdateConstraints()
    }
    
    // MARK: Instance Methods
    
    override func updateForIsReplyValue() {
        super.updateForIsReplyValue()
        if isReply {
            textMessageLabel.textColor = Colors.whiteColor()
        } else {
            textMessageLabel.textColor = Colors.darkTextColor()
        }
    }
    
    // MARK: Layout
    
    override func updateConstraints() {
        bubbleView.snp_updateConstraints { (make) in
            make.height.equalTo(textMessageLabel.snp_height).offset(textInset.top + textInset.bottom)
            make.width.equalTo(textMessageLabel.snp_width).offset(textInset.left + textInset.right)
        }
        
        textMessageLabel.snp_updateConstraints { (make) in
            make.left.equalTo(bubbleView.snp_left).offset(textInset.left)
            make.top.equalTo(bubbleView.snp_top).offset(textInset.top)
            make.width.lessThanOrEqualTo(bubbleView.snp_width).offset(-(textInset.left + textInset.right))
        }
        
        super.updateConstraints()
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.removeAllAnimations()
        bubbleView.alpha = 1
        bubbleView.transform = CGAffineTransformIdentity
        animationStartTime = 0
        animating = false
    }
}

// MARK:- Animations

extension ChatTextMessageCell {
    
    override func animate() {
        if animating {
            return
        }
        animating = true
        animationStartTime = NSDate().timeIntervalSince1970
        let blockStartTime = animationStartTime
        
        bubbleView.alpha = 0
        
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
        if bubbleView.bounds.isEmpty {
            let messageSize = bubbleView.sizeThatFits(bounds.size)
            animationEndCenter.y = CGRectGetHeight(bounds) - contentInset.bottom - messageSize.height / 2.0
            if isReply {
                animationEndCenter.x = contentInset.left + messageSize.width / 2.0
            } else {
                animationEndCenter.x = CGRectGetWidth(bounds) - contentInset.right - messageSize.width / 2.0
            }
        } else {
            animationEndCenter = bubbleView.center
        }
        
        bubbleView.alpha = 0
        bubbleView.transform = CGAffineTransformMakeScale(0.01, 0.01)
        bubbleView.center = animationBeginCenter
        
        UIView.animateKeyframesWithDuration(0.2, delay: 0, options: .BeginFromCurrentState, animations: {
            self.bubbleView.alpha = 1
            self.bubbleView.transform = CGAffineTransformIdentity
            self.bubbleView.center = animationEndCenter
            }, completion: { (completed) in
                self.setNeedsLayout()
                self.animating = false
        })
    }
}
