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
    
    var messageText: String? {
        didSet {
            textMessageLabel.text = messageText
            setNeedsLayout()
        }
    }
    
    // MARK: Private Properties
    
    private let textInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    
    private var isLongPressing: Bool = false {
        didSet {
            if isLongPressing != oldValue {
                updateFillColor(isLongPressing)
            }
        }
    }
    
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
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ChatTextMessageCell.longPressGestureAction(_:)))
        addGestureRecognizer(longPressGesture)
    }
    
    // MARK: Instance Methods
    
    override func updateFontsAndColors() {
        super.updateFontsAndColors()
        
        textMessageLabel.font = styles.bodyFont
        if isReply {
            textMessageLabel.textColor = styles.replyMessageTextColor
        } else {
            textMessageLabel.textColor = styles.messageTextColor
        }
        textMessageLabel.backgroundColor = bubbleView.fillColor
    }
    
    func updateFillColor(isLongPressing: Bool) {
        if isLongPressing {
            if let highlightColor = bubbleFillColor().highlightColor() {
                bubbleView.fillColor = highlightColor
                textMessageLabel.backgroundColor = highlightColor
            }
        } else {
            bubbleView.fillColor = bubbleFillColor()
            textMessageLabel.backgroundColor = bubbleView.fillColor
        }
    }
    
    // MARK: Layout
    
    func messageLabelSizeThatFits(size: CGSize) -> CGSize {
        let maxBubbleWidth = maxBubbleWidthForBoundsSize(size)
        let maxMessageWidth = maxBubbleWidth - textInset.right - textInset.left
        var messageSize = textMessageLabel.sizeThatFits(CGSize(width: maxMessageWidth, height: 0))
        messageSize.width = ceil(messageSize.width)
        messageSize.height = ceil(messageSize.height)
        
        return messageSize
    }
    
    override func bubbleSizeForSize(size: CGSize) -> CGSize {
        let messageSize = messageLabelSizeThatFits(size)
        let bubbleSize = CGSize(width: ceil(messageSize.width + textInset.left + textInset.right),
                                height: ceil(messageSize.height + textInset.top + textInset.bottom))
        
        return bubbleSize
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()

        textMessageLabel.frame = UIEdgeInsetsInsetRect(bubbleView.bounds, textInset)
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        isLongPressing = false
        bubbleView.alpha = 1
        bubbleView.transform = CGAffineTransformIdentity
    }
}

// MARK:- Copying Action

extension ChatTextMessageCell {
    
    func longPressGestureAction(gesture: UILongPressGestureRecognizer) {
        if gesture.state == .Began {
            isLongPressing = true
            showCopyMenu()
        } else {
            isLongPressing = false
        }
    }
    
    func showCopyMenu() {
        guard let textToCopy = textMessageLabel.text else { return }
        
        if !textToCopy.isEmpty {
            becomeFirstResponder()
            
            let menu = UIMenuController.sharedMenuController()
            menu.setTargetRect(bubbleView.frame, inView: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    override func canBecomeFirstResponder() -> Bool {
        return true
    }
    
    override func copy(sender: AnyObject?) {
        UIPasteboard.generalPasteboard().string = textMessageLabel.text
    }
    
    override func canPerformAction(action: Selector, withSender sender: AnyObject?) -> Bool {
        return action == #selector(ChatMessagesView.copy(_:))
    }
}
