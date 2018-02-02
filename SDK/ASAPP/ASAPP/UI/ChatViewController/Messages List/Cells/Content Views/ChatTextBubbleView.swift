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
    
    var message: ChatMessage? {
        didSet {
            guard let message = message else {
                label.text = nil
                setNeedsLayout()
                return
            }
            
            //
            // Update Text
            //
            label.text = message.text
            if textHasDataDetectorLink(label.text) {
                label.isUserInteractionEnabled = true
                label.isSelectable = true
            } else {
                label.isUserInteractionEnabled = false
                label.isSelectable = false
            }
            
            //
            // Update Bubble
            //
            if message.metadata.isReply {
                let fillColor = ASAPP.styles.colors.replyMessageBackground
                label.updateFont(for: .bodyBold)
                label.textColor = ASAPP.styles.colors.replyMessageText
                label.linkTextAttributes = [
                    NSAttributedStringKey.foregroundColor.rawValue: ASAPP.styles.colors.replyMessageText,
                    NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
                ]
                bubbleView.strokeColor = ASAPP.styles.colors.replyMessageBorder
                bubbleView.strokeLineWidth = 0.5
                bubbleView.fillColor = fillColor
            } else {
                let fillColor = ASAPP.styles.colors.messageBackground
                label.updateFont(for: .body)
                label.textColor = ASAPP.styles.colors.messageText
                label.backgroundColor = UIColor.clear
                label.linkTextAttributes = [
                    NSAttributedStringKey.foregroundColor.rawValue: ASAPP.styles.colors.messageText,
                    NSAttributedStringKey.underlineStyle.rawValue: NSUnderlineStyle.styleSingle.rawValue
                ]
                
                bubbleView.strokeColor = ASAPP.styles.colors.messageBorder
                bubbleView.strokeLineWidth = 0.5
                bubbleView.fillColor = fillColor
            }
            bubbleView.strokeLineWidth = ASAPP.styles.separatorStrokeWidth
            updateBubbleCorners()
            
            setNeedsLayout()
        }
    }
    
    var messagePosition: MessageListPosition = .none {
        didSet {
            updateBubbleCorners()
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
    
    // MARK: Data Detectors
    
    let textCheckingTypes: NSTextCheckingResult.CheckingType = [.link, .phoneNumber]
    let dataDetectorTypes: UIDataDetectorTypes = [.link, .phoneNumber]
    
    var dataDetector: NSDataDetector?
    
    // MARK: Properties: UI
    
    let bubbleView = BubbleView()
    
    let label = UITextView()
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = ASAPP.styles.colors.messagesListBackground
        
        bubbleView.backgroundColor = ASAPP.styles.colors.messagesListBackground
        bubbleView.clipsToBounds = false
        bubbleView.cornerRadius = 14
        addSubview(bubbleView)
        
        label.isEditable = false
        label.isSelectable = true
        label.isScrollEnabled = false
        label.scrollsToTop = false
        label.clipsToBounds = false
        label.updateFont(for: .body)
        label.textContainerInset = textInset
        label.textContainer.lineFragmentPadding = 0.0
        label.backgroundColor = UIColor.clear
        label.dataDetectorTypes = dataDetectorTypes
        label.isAccessibilityElement = false
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

// MARK: - Display

extension ChatTextBubbleView {
    
    func updateFonts() {
        label.updateFont(for: .body)
        setNeedsLayout()
    }
    
    func updateBubbleCorners() {
        guard let message = message else {
            return
        }
        
        var roundedCorners: UIRectCorner
        if message.metadata.isReply {
            switch messagePosition {
            case .none:
                roundedCorners = [.topLeft, .topRight, .bottomRight]
                
            case .firstOfMany:
                roundedCorners =  .allCorners
                
            case .middleOfMany:
                roundedCorners =  .allCorners
                
            case .lastOfMany:
                roundedCorners = [.topLeft, .topRight, .bottomRight]
            }
        } else {
            switch messagePosition {
            case .none:
                roundedCorners = [.topRight, .topLeft, .bottomLeft]
                
            case .firstOfMany:
                roundedCorners = .allCorners
                
            case .middleOfMany:
                roundedCorners = .allCorners
                
            case .lastOfMany:
                roundedCorners =  [.topRight, .topLeft, .bottomLeft]
            }
        }
        bubbleView.roundedCorners = roundedCorners
    }
}

// MARK: - Layout + Sizing

extension ChatTextBubbleView {
    
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        guard !isEmpty else {
            return (.zero, .zero)
        }
        
        let maxBubbleWidth = floor((size.width - contentInset.left - contentInset.right) * maxBubbleWidthPercentage)
        let maxTextWidth = maxBubbleWidth
        let textSize = label.sizeThatFits(CGSize(width: maxTextWidth, height: 0))
        guard textSize.height > 0 else {
            return (.zero, .zero)
        }
        
        let bubbleSize = CGSize(width: ceil(textSize.width),
                                height: ceil(textSize.height))
        
        var bubbleLeft = contentInset.left
        if let message = message, !message.metadata.isReply {
            bubbleLeft = size.width - bubbleSize.width - contentInset.right
        }
        let bubbleFrame = CGRect(x: bubbleLeft, y: contentInset.top, width: bubbleSize.width, height: bubbleSize.height)
        let labelFrame = CGRect(x: 0, y: 0, width: ceil(textSize.width), height: ceil(textSize.height))
        
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

// MARK: - Long Press Gesture + Copy Menu

extension ChatTextBubbleView {
    
    func textHasDataDetectorLink(_ text: String?) -> Bool {
        guard let text = text, text.count > 0 else {
            return false
        }
        
        if dataDetector == nil {
            do {
                try dataDetector = NSDataDetector(types: textCheckingTypes.rawValue)
            } catch {
                DebugLog.e(caller: self, "Encountered error with data detector for \(textCheckingTypes)...: \(error)")
            }
        }
        
        if let dataDetector = dataDetector {
            let range = NSRange(location: 0, length: text.count)
            return dataDetector.numberOfMatches(in: text, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: range) > 0
        }
        return false
    }
    
    @objc func longPressGestureAction(_ gesture: UILongPressGestureRecognizer) {
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
    
    override var canBecomeFirstResponder: Bool {
        return true
    }
    
    override func copy(_ sender: Any?) {
        UIPasteboard.general.string = label.text
    }
    
    override func canPerformAction(_ action: Selector, withSender sender: Any?) -> Bool {
        return action == #selector(ChatMessagesView.copy(_:))
    }
}
