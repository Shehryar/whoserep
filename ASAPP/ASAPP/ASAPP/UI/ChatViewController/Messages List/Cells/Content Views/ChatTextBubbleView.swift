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
            let previousMessage = oldValue
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
            if message.isReply {
                let fillColor = ASAPP.styles.replyMessageFillColor ?? ASAPP.styles.backgroundColor1
                label.textColor = ASAPP.styles.replyMessageTextColor
                label.linkTextAttributes = [
                    NSForegroundColorAttributeName : ASAPP.styles.replyMessageTextColor,
                    NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue
                ]
                bubbleView.strokeColor = ASAPP.styles.replyMessageStrokeColor
                bubbleView.fillColor = fillColor
            } else {
                let fillColor = ASAPP.styles.messageFillColor ?? ASAPP.styles.backgroundColor1
                label.textColor = ASAPP.styles.messageTextColor
                label.backgroundColor = UIColor.clear
                label.linkTextAttributes = [
                    NSForegroundColorAttributeName : ASAPP.styles.messageTextColor,
                    NSUnderlineStyleAttributeName : NSUnderlineStyle.styleSingle.rawValue
                ]
                
                bubbleView.strokeColor = ASAPP.styles.messageStrokeColor
                bubbleView.fillColor = fillColor
            }
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
    
    var dataDetectorTypes: UIDataDetectorTypes = [.phoneNumber, .link, .address]
    
    var dataDetector: NSDataDetector?
    
    // MARK: Properties: UI
    
    let bubbleView = BubbleView()
    
    let label = UITextView()
    
    // MARK: Initialization
    
    func commonInit() {
        if #available(iOS 10.0, *) {
            dataDetectorTypes = [.phoneNumber, .link, .address, .shipmentTrackingNumber, .flightNumber]
        }
        
        backgroundColor = ASAPP.styles.backgroundColor1
        
        bubbleView.backgroundColor = ASAPP.styles.backgroundColor1
        bubbleView.clipsToBounds = false
        addSubview(bubbleView)
        
        label.isEditable = false
        label.isSelectable = true
        label.isScrollEnabled = false
        label.scrollsToTop = false
        label.clipsToBounds = false
        label.textContainerInset = textInset
        label.textContainer.lineFragmentPadding = 0.0
        label.font = ASAPP.styles.font(for: .chatMessageText)
        label.backgroundColor = UIColor.clear
        label.dataDetectorTypes = dataDetectorTypes
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
        guard let message = message else {
            return
        }
        
        var roundedCorners: UIRectCorner
        if message.isReply {
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
        if let message = message, !message.isReply {
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

// MARK:- Long Press Gesture + Copy Menu

extension ChatTextBubbleView {
    
    func textHasDataDetectorLink(_ text: String?) -> Bool {
        guard let text = text, text.characters.count > 0 else {
            return false
        }
        
        dataDetector = try? (dataDetector ?? NSDataDetector(types: NSTextCheckingTypes(dataDetectorTypes.rawValue)))
        if let dataDetector = dataDetector {
            return dataDetector.numberOfMatches(in: text, options: NSRegularExpression.MatchingOptions(rawValue: 0), range: NSMakeRange(0, text.characters.count)) > 0
        }
        return false
    }
    
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
