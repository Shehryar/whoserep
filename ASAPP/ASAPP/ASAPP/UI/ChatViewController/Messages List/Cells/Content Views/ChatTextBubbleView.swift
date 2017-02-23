//
//  ChatTextBubbleView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatTextBubbleView: UIView {

    // MARK: Properties: Content
    
    var event: Event? {
        didSet {
            label.text = event?.messageText
        
            setNeedsLayout()
        }
    }
    
    var messagePosition: MessageListPosition = .none {
        didSet {
            updateBubbleCorners()
        }
    }
    
    var isReply: Bool = false {
        didSet {
            if isReply {
                label.textColor = ASAPP.styles.replyMessageTextColor
                bubbleView.strokeColor = ASAPP.styles.replyMessageStrokeColor
                bubbleView.fillColor = ASAPP.styles.replyMessageFillColor
            } else {
                label.textColor = ASAPP.styles.messageTextColor
                bubbleView.strokeColor = ASAPP.styles.messageStrokeColor
                bubbleView.fillColor = ASAPP.styles.messageFillColor
            }
            updateBubbleCorners()
            
            setNeedsLayout()
        }
    }
    
    var isEmpty: Bool {
        return (label.text ?? "").isEmpty
    }
    
    // MARK: Properties: Layout
    
    var isLongPressing: Bool = false
    
    let maxBubbleWidthPercentage: CGFloat = 0.8
    
    let contentInset = UIEdgeInsets.zero
    
    let textInset = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
    
    // MARK: Properties: UI
    
    let bubbleView = BubbleView()
    
    let label = UILabel()
    
    // MARK: Initialization
    
    func commonInit() {
        bubbleView.clipsToBounds = true
        addSubview(bubbleView)
        
        label.numberOfLines = 0
        label.lineBreakMode = .byWordWrapping
        label.font = ASAPP.styles.font(for: .chatMessageText)
        bubbleView.addSubview(label)
        
        let longPressGesture = UILongPressGestureRecognizer(target: self, action: #selector(ChatTextBubbleView.longPressGestureAction(_:)))
        addGestureRecognizer(longPressGesture)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
}

// MARK:- Display

extension ChatTextBubbleView {
    
    func updateFonts() {
        label.font = ASAPP.styles.font(for: .chatMessageText)
        setNeedsLayout()
    }
    
    func updateBubbleCorners() {
        var roundedCorners: UIRectCorner
        if isReply {
            switch messagePosition {
            case .none:
                roundedCorners = [.topLeft, .topRight, .bottomRight]
                break
                
            case .firstOfMany:
                roundedCorners =  .allCorners
                break
                
            case .middleOfMany:
                roundedCorners =  .allCorners
                break
                
            case .lastOfMany:
                roundedCorners = [.topLeft, .topRight, .bottomRight]
                break
            }
        } else {
            switch messagePosition {
            case .none:
                roundedCorners = [.topRight, .topLeft, .bottomLeft]
                break
                
            case .firstOfMany:
                roundedCorners = .allCorners
                break
                
            case .middleOfMany:
                roundedCorners = .allCorners
                break
                
            case .lastOfMany:
                roundedCorners =  [.topRight, .topLeft, .bottomLeft]
                break
            }
        }
        bubbleView.roundedCorners = roundedCorners
    }
}

// MARK:- Layout + Sizing

extension ChatTextBubbleView {
    
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        let maxBubbleWidth = floor((size.width - contentInset.left - contentInset.right) * maxBubbleWidthPercentage)
        let maxTextWidth = maxBubbleWidth - textInset.left - textInset.right
        let textSize = label.sizeThatFits(CGSize(width: maxTextWidth, height: 0))
        guard textSize.height > 0 else {
            return (.zero, .zero)
        }
        
        let bubbleSize = CGSize(width: ceil(textSize.width + textInset.left + textInset.right),
                                height: ceil(textSize.height + textInset.top + textInset.bottom))
        
        var bubbleLeft = contentInset.left
        if !isReply {
            bubbleLeft = size.width - bubbleSize.width - contentInset.right
        }
        let bubbleFrame = CGRect(x: bubbleLeft, y: contentInset.top, width: bubbleSize.width, height: bubbleSize.height)
        let labelFrame = CGRect(x: textInset.left, y: textInset.top, width: ceil(textSize.width), height: ceil(textSize.height))
        
        return (bubbleFrame, labelFrame)
    }
    
    func updateFrames() {
        let (bubbleFrame, labelFrame) = getFramesThatFit(bounds.size)
        bubbleView.frame = bubbleFrame
        label.frame = labelFrame
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (bubbleFrame, _) = getFramesThatFit(size)
        var height: CGFloat = 0.0
        if bubbleFrame.height > 0 {
            height = bubbleFrame.maxY + contentInset.bottom
        }
        return CGSize(width: size.width, height: height)
    }
}

// MARK:- Long Press Gesture + Copy Menu

extension ChatTextBubbleView {
    
    func longPressGestureAction(_ gesture: UILongPressGestureRecognizer) {
        if gesture.state == .began {
            isLongPressing = true
            showCopyMenu()
        } else if gesture.state != .changed {
            isLongPressing = false
        }
    }
    
    func showCopyMenu() {
        guard let textToCopy = label.text else { return }
        
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
        UIPasteboard.general.string = label.text
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(ChatMessagesView.copy(_:))
    }
}
