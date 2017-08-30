//
//  ChatMessageCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 2/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol ChatMessageCellDelegate: class {
 
    func chatMessageCell(_ cell: ChatMessageCell,
                         didTap buttonItem: ButtonItem,
                         from message: ChatMessage)
    
    func chatMessageCell(_ cell: ChatMessageCell,
                         didPageCarouselViewItem: CarouselViewItem,
                         from: ComponentView)
}

class ChatMessageCell: UITableViewCell {

    // MARK:- Properties: Content
    
    var message: ChatMessage? {
        didSet {
            textBubbleView.message = message
            
            timeLabel.textAlignment = isReply ? .left : .right
            timeLabel.setAttributedText(message?.metadata.sendTimeString, textType: .detail2)
            
            setNeedsLayout()
        }
    }
    
    var isReply: Bool {
        if let message = message {
            return message.metadata.isReply
        }
        return false
    }
    
    var messagePosition: MessageListPosition = .none {
        didSet {
            textBubbleView.messagePosition = messagePosition
            updateContentInset()
        }
    }
    
    var isTimeLabelVisible: Bool = false {
        didSet {
            timeLabel.alpha = isTimeLabelVisible ? 1.0 : 0.0
            updateContentInset()
            setNeedsLayout()
        }
    }
    
    weak var delegate: ChatMessageCellDelegate?
    
    // MARK:- Properties: Layout + State
    
    let attachmentViewMarginTop: CGFloat = 4.0
    
    let timeLabelMarginTop: CGFloat = 4.0
    
    internal var attachmentViewMaxWidthPercentage: CGFloat {
        return 1.0
    }
    
    fileprivate(set) var contentInset = UIEdgeInsets(top: 3, left: 16, bottom: 3, right: 16) {
        didSet {
            if oldValue != contentInset {
                setNeedsLayout()
            }
        }
    }
    
    fileprivate var isAnimating: Bool = false
    
    fileprivate var animationStartTime: TimeInterval?
    
    // MARK:- Properties: UI Elements
    
    let textBubbleView = ChatTextBubbleView()
    
    var attachmentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            if let attachmentView = attachmentView {
                contentView.insertSubview(attachmentView, belowSubview: textBubbleView)
                contentView.sendSubview(toBack: timeLabel)
                setNeedsLayout()
            }
        }
    }
    
    let timeLabel = UILabel()
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .none
        isOpaque = true
        backgroundColor = ASAPP.styles.colors.messagesListBackground
    
        contentView.addSubview(textBubbleView)
        
        timeLabel.alpha = 0.0
        timeLabel.backgroundColor = ASAPP.styles.colors.messagesListBackground
        contentView.insertSubview(timeLabel, belowSubview: textBubbleView)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    // MARK: Styling Methods
    
    private func updateContentInset() {
        var updatedContentInset = UIEdgeInsets(top: 3, left: 16, bottom: 3, right: 16)
        
        switch messagePosition {
        case .firstOfMany:
            updatedContentInset.bottom = 1
            break
            
        case .middleOfMany:
            updatedContentInset.top = 1
            if !isTimeLabelVisible {
                updatedContentInset.bottom = 1
            }
            break
            
        case .lastOfMany:
            updatedContentInset.top = 1
            break
            
        case .none:
            // No need to change
            break
        }
        contentInset = updatedContentInset
    }
}

// MARK:- Reuse

extension ChatMessageCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        layer.removeAllAnimations()
        
        textBubbleView.message = nil
        timeLabel.text = nil
        
        textBubbleView.alpha = 1.0
        attachmentView?.alpha = 1.0
        isTimeLabelVisible = false
        
        isAnimating = false
        animationStartTime = nil
    }
}

// MARK:- Display

extension ChatMessageCell {
    
    func updateFonts() {
        textBubbleView.updateFonts()
        timeLabel.setAttributedText(message?.metadata.sendTimeString, textType: .detail2)
        
        setNeedsLayout()
    }
}

// MARK:- Layout + Sizing

extension ChatMessageCell {
    
    func getAttachmentViewSizeThatFits(_ size: CGSize) -> CGSize {
        var attachmentViewSize: CGSize = .zero
        if let attachmentView = attachmentView {
            let maxAttachmentWidth = floor(size.width * attachmentViewMaxWidthPercentage)
            attachmentViewSize = attachmentView.sizeThatFits(CGSize(width: maxAttachmentWidth, height: 0))
        }
        return attachmentViewSize
    }
    
    /// Returns (textBubbleViewFrame, attachmentViewFrame, timeLabelFrame)
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect, CGRect) {
        let contentWidth = size.width - contentInset.left - contentInset.right
        let contentSizer = CGSize(width: contentWidth, height: 0)
        
        // Text Bubble View
        let textBubbleViewTop = contentInset.top
        let textBubbleViewHeight = ceil(textBubbleView.sizeThatFits(contentSizer).height)
        let textBubbleViewFrame = CGRect(x: contentInset.left, y: textBubbleViewTop,
                                         width: contentWidth, height: textBubbleViewHeight)
 
        // Attachment View
        let attachmentViewSize = getAttachmentViewSizeThatFits(contentSizer)
        var attachmentViewTop = textBubbleViewFrame.maxY
        if textBubbleViewHeight > 0 && attachmentViewSize.height > 0 {
            attachmentViewTop += attachmentViewMarginTop
        }
        var attachmentViewLeft = contentInset.left
        if attachmentViewMaxWidthPercentage < 1 && !isReply {
            attachmentViewLeft = size.width - contentInset.right - ceil(attachmentViewSize.width)
        }
        let attachmentViewFrame = CGRect(x: attachmentViewLeft, y: attachmentViewTop,
                                         width: ceil(attachmentViewSize.width), height: ceil(attachmentViewSize.height))
        
        // Time Label
        let timeLabelHeight = ceil(timeLabel.sizeThatFits(contentSizer).height)
        var timeLabelTop: CGFloat = contentInset.top
        if attachmentViewSize.height > 0 {
            timeLabelTop = attachmentViewFrame.maxY + (isTimeLabelVisible ? timeLabelMarginTop : -timeLabelHeight)
        } else if textBubbleViewHeight > 0 {
            timeLabelTop = textBubbleViewFrame.maxY + (isTimeLabelVisible ? timeLabelMarginTop : -timeLabelHeight)
        }
        let timeLabelFrame = CGRect(x: contentInset.left, y: timeLabelTop,
                                    width: contentWidth, height: timeLabelHeight)
        
        return (textBubbleViewFrame, attachmentViewFrame, timeLabelFrame)
    }
    
    func updateFrames() {
        let (textBubbleViewFrame, attachmentViewFrame, timeLabelFrame) = getFramesThatFit(bounds.size)
        
        textBubbleView.frame = textBubbleViewFrame
        attachmentView?.frame = attachmentViewFrame
        timeLabel.frame = timeLabelFrame
    }
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let (textBubbleViewFrame, attachmentViewFrame, timeLabelFrame) = getFramesThatFit(size)
        guard textBubbleViewFrame.height > 0 || attachmentViewFrame.height > 0 else {
            return .zero
        }
        
        let contentMaxY = max(textBubbleViewFrame.maxY, max(timeLabelFrame.maxY, attachmentViewFrame.maxY))
        let height = contentMaxY + contentInset.bottom
        
        return CGSize(width: size.width, height: height)
    }
}

// MARK:- Time Label Animation

extension ChatMessageCell {
    
    func setTimeLabelVisible(_ visible: Bool, animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.isTimeLabelVisible = visible
                self?.updateFrames()
            })
        } else {
            isTimeLabelVisible = visible
        }
    }
}

// MARK:- Cell Entrance Animation

extension ChatMessageCell {
    
    func animate() {
        guard !isAnimating else {
            return
        }
        isAnimating = true
        let blockStartTime = Date.timeIntervalSinceReferenceDate
        animationStartTime = blockStartTime
        
        prepareAnimation()
        Dispatcher.delay(100) { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            if strongSelf.isAnimating && strongSelf.animationStartTime == blockStartTime {
                self?.performAnimation()
            }
        }
    }
    
    internal func prepareAnimation() {
        textBubbleView.alpha = 0.0
        attachmentView?.alpha = 0.0
    }
    
    internal func performAnimation() {
        let translationY: CGFloat = 12.0
        
        let textBubbleViewCenterAtEnd = textBubbleView.center
        var textBubbleViewCenterAtStart = textBubbleViewCenterAtEnd
        textBubbleViewCenterAtStart.y += translationY
        textBubbleView.center = textBubbleViewCenterAtStart
        
        let attachmentViewCenterAtEnd = attachmentView?.center ?? CGPoint.zero
        var attachmentViewCenterAtStart = attachmentViewCenterAtEnd
        attachmentViewCenterAtStart.y += translationY
        attachmentView?.center = attachmentViewCenterAtStart
        
        let attachmentAnimationDelay: Double = textBubbleView.isEmpty || attachmentView == nil ? 0.0 : 0.4
        
        // Animate in the text bubble view
        UIView.animate(
            withDuration: 0.5,
            delay: 0,
            options: [.beginFromCurrentState, .curveEaseOut],
            animations: { [weak self] in
                self?.textBubbleView.alpha = 1.0
                self?.textBubbleView.center = textBubbleViewCenterAtEnd
            }, completion: nil)
        
        // Animate in the attachment view
        UIView.animate(
            withDuration: 0.5,
            delay: attachmentAnimationDelay,
            options: [.beginFromCurrentState, .curveEaseOut],
            animations: { [weak self] in
                self?.attachmentView?.alpha = 1.0
                self?.attachmentView?.center = attachmentViewCenterAtEnd
        }, completion: { [weak self] _ in
                self?.isAnimating = false
                self?.setNeedsLayout()
        })
    }
}
