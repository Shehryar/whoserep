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
    
    /// *Note* event does not affect the UI -- it is to be used for reference by called only
    var event: Event?
    
    var messageText: String? {
        didSet {
            textMessageLabel.text = messageText
            setNeedsLayout()
        }
    }
    
    // MARK: Private Properties
    
    private let textInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    
    private var animating = false
    
    private var animationStartTime: Double = 0.0
    
    internal let textMessageLabel = UILabel()
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        textMessageLabel.numberOfLines = 0
        textMessageLabel.lineBreakMode = .ByTruncatingTail
        textMessageLabel.font = Fonts.latoRegularFont(withSize: 16)
        textMessageLabel.textColor = Colors.whiteColor()
        bubbleView.addSubview(textMessageLabel)
        
        updateFontsAndColors()
    }
    
    // MARK: Instance Methods
    
    override func updateFontsAndColors() {
        super.updateFontsAndColors()
        
        textMessageLabel.font = styles.messageFont
        if isReply {
            textMessageLabel.textColor = styles.replyMessageTextColor
        } else {
            textMessageLabel.textColor = styles.messageTextColor
        }
        textMessageLabel.backgroundColor = bubbleView.fillColor
    }
    
    // MARK: Layout
    
    func messageLabelSizeThatFitsBoundsSize(size: CGSize) -> CGSize {
        let maxBubbleWidth = maxBubbleWidthForBoundsSize(size)
        let maxMessageWidth = maxBubbleWidth - textInset.right - textInset.left
        let messageSize = textMessageLabel.sizeThatFits(CGSize(width: maxMessageWidth, height: 0))
        
        return messageSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        let messageSize = messageLabelSizeThatFitsBoundsSize(bounds.size)
        let bubbleSize = CGSize(width: ceil(messageSize.width + textInset.left + textInset.right),
                                height: ceil(messageSize.height + textInset.top + textInset.bottom))
        var bubbleLeft = contentInset.left
        if !isReply {
            bubbleLeft = CGRectGetWidth(bounds) - bubbleSize.width - contentInset.right
        }
        
        bubbleView.frame = CGRect(x: bubbleLeft, y: contentInset.top, width: bubbleSize.width, height: bubbleSize.height)
        textMessageLabel.frame = UIEdgeInsetsInsetRect(bubbleView.bounds, textInset)
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        let textHeight = messageLabelSizeThatFitsBoundsSize(size).height + textInset.top + textInset.bottom
        let contentHeight = textHeight + contentInset.top + contentInset.bottom
        return CGSize(width: size.width, height: contentHeight)
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
    
    // MARK: Highlighting
    
    override func setHighlighted(highlighted: Bool, animated: Bool) {
        let wasHighlighted = self.highlighted
        
        super.setHighlighted(highlighted, animated: animated)
        
        guard wasHighlighted != highlighted else { return }
        
        if highlighted {
            if let highlightColor = bubbleFillColor().highlightColor() {
                bubbleView.fillColor = highlightColor
                textMessageLabel.backgroundColor = highlightColor
            }
        } else {
            bubbleView.fillColor = bubbleFillColor()
            textMessageLabel.backgroundColor = bubbleView.fillColor
        }
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
                self.animating = false
                self.setNeedsLayout()
        })
    }
}
