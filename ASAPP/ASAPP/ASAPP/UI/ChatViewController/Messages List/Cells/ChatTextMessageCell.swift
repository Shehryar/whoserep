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
    
    fileprivate let textInset = UIEdgeInsets(top: 10, left: 15, bottom: 10, right: 15)
    
    fileprivate var isLongPressing: Bool = false {
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
        textMessageLabel.lineBreakMode = .byTruncatingTail
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
    
    func updateFillColor(_ isLongPressing: Bool) {
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
    
    func messageLabelSizeThatFits(_ size: CGSize) -> CGSize {
        let maxBubbleWidth = maxBubbleWidthForBoundsSize(size)
        let maxMessageWidth = maxBubbleWidth - textInset.right - textInset.left
        var messageSize = textMessageLabel.sizeThatFits(CGSize(width: maxMessageWidth, height: 0))
        messageSize.width = ceil(messageSize.width)
        messageSize.height = ceil(messageSize.height)
        
        return messageSize
    }
    
    override func bubbleSizeForSize(_ size: CGSize) -> CGSize {
        let messageSize = messageLabelSizeThatFits(size)
        if messageSize.width > 0 && messageSize.height > 0 {
            let bubbleSize = CGSize(width: ceil(messageSize.width + textInset.left + textInset.right),
                                    height: ceil(messageSize.height + textInset.top + textInset.bottom))
            return bubbleSize
        }
        
        return .zero
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
        bubbleView.transform = CGAffineTransform.identity
    }
}

// MARK:- Copying Action

extension ChatTextMessageCell {
    
    func longPressGestureAction(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            isLongPressing = true
            showCopyMenu()
        } else if gesture.state != .changed {
            isLongPressing = false
        }
    }
    
    func showCopyMenu() {
        guard let textToCopy = textMessageLabel.text else { return }
        
        if !textToCopy.isEmpty {
            becomeFirstResponder()
            
            let menu = UIMenuController.shared
            menu.setTargetRect(bubbleView.frame, in: self)
            menu.setMenuVisible(true, animated: true)
        }
    }
    
    override var canBecomeFirstResponder : Bool {
        return true
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = textMessageLabel.text
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(ChatMessagesView.copy(_:))
    }
}
