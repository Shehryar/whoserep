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
                         didTap button: QuickReply)
    
    func chatMessageCell(_ cell: ChatMessageCell,
                         didChangeHeightWith message: ChatMessage)
}

class ChatMessageCell: UITableViewCell {

    // MARK: - Properties: Content
    
    var message: ChatMessage? {
        didSet {
            textBubbleView.messagePosition = messagePosition
            textBubbleView.message = message
            
            timeLabel.textAlignment = isReply ? .left : .right
            timeLabel.setAttributedText(message?.metadata.sendTimeString, textType: .detail1, color: ASAPP.styles.colors.textSecondary.withAlphaComponent(0.5))
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
            ((attachmentView ?? textBubbleView) as? MessageBubbleCornerRadiusUpdating)?.messagePosition = messagePosition
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
    
    // MARK: - Properties: Layout + State
    
    let attachmentViewMarginTop: CGFloat = 4.0
    
    let timeLabelMarginTop: CGFloat = 4.0
    
    internal let attachmentViewWidth: CGFloat = 260
    
    private(set) var contentInset = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16) {
        didSet {
            if oldValue != contentInset {
                setNeedsLayout()
            }
        }
    }
    
    private var isAnimating: Bool = false
    
    private var animationStartTime: TimeInterval?
    
    // MARK: - Properties: UI Elements
    
    let textBubbleView = ChatTextBubbleView()
    
    var attachmentView: UIView? {
        didSet {
            oldValue?.removeFromSuperview()
            
            if let attachmentView = attachmentView {
                contentView.addSubview(attachmentView)
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
        backgroundColor = .clear
    
        textBubbleView.delegate = self
        contentView.addSubview(textBubbleView)
        
        timeLabel.alpha = 0.0
        timeLabel.backgroundColor = .clear
        contentView.insertSubview(timeLabel, belowSubview: textBubbleView)
        
        isAccessibilityElement = false
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    func update(_ message: ChatMessage?, showTransientButtons: Bool) {
        self.message = message
        
        let predicate: ((QuickReply) -> Bool) = showTransientButtons ? { _ in return true } : { !$0.isTransient }
        updateMessageButtons(message?.buttons?.filter(predicate))
        
        setNeedsLayout()
    }
    
    // MARK: Styling Methods
    
    private func updateContentInset() {
        var updatedContentInset = UIEdgeInsets(top: 6, left: 16, bottom: 6, right: 16)
        
        switch messagePosition {
        case .firstOfMany:
            updatedContentInset.bottom = 3
            
        case .middleOfMany:
            updatedContentInset.top = 2
            if !isTimeLabelVisible {
                updatedContentInset.bottom = 3
            }
            
        case .lastOfMany:
            updatedContentInset.top = 2
            
        case .none:
            // No need to change
            break
        }
        contentInset = updatedContentInset
    }
}

// MARK: - Reuse

extension ChatMessageCell {
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        layer.removeAllAnimations()
        
        textBubbleView.message = nil
        timeLabel.text = nil
        updateMessageButtons(nil)
        
        textBubbleView.alpha = 1.0
        attachmentView?.alpha = 1.0
        isTimeLabelVisible = false
        
        isAnimating = false
        animationStartTime = nil
    }
}

// MARK: - Display

extension ChatMessageCell {
    
    func updateFonts() {
        textBubbleView.updateFonts()
        timeLabel.setAttributedText(message?.metadata.sendTimeString, textType: .detail2)
        
        setNeedsLayout()
    }
    
    func updateMessageButtons(_ messageButtons: [QuickReply]?) {
        if let container = (attachmentView ?? textBubbleView) as? MessageButtonsViewContainer {
            guard let messageButtons = messageButtons,
                  !messageButtons.isEmpty else {
                container.messageButtonsView?.removeFromSuperview()
                container.messageButtonsView = nil
                return
            }
            container.messageButtonsView = MessageButtonsView(messageButtons: messageButtons, separatorColor: ASAPP.styles.colors.replyMessageBorder)
        }
    }
}

// MARK: - Layout + Sizing

extension ChatMessageCell {
    
    func getAttachmentViewSizeThatFits(_ size: CGSize) -> CGSize {
        var attachmentViewSize: CGSize = .zero
        if let attachmentView = attachmentView {
            attachmentViewSize = attachmentView.sizeThatFits(CGSize(width: attachmentViewWidth, height: 0))
        }
        return attachmentViewSize
    }
    
    private struct CalculatedLayout {
        let textBubbleViewFrame: CGRect
        let attachmentViewFrame: CGRect
        let timeLabelFrame: CGRect
    }
    
    private func getFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        let contentWidth = size.width - contentInset.left - contentInset.right
        let contentSizer = CGSize(width: contentWidth, height: 0)
        
        // Text Bubble View
        let textBubbleViewTop = contentInset.top
        let textBubbleViewHeight = ceil(textBubbleView.sizeThatFits(contentSizer).height)
        let textBubbleViewFrame = CGRect(x: contentInset.left, y: textBubbleViewTop,
                                         width: contentWidth, height: textBubbleViewHeight)
 
        // Attachment View
        let attachmentViewSize = (attachmentView is ChatCarouselView) ? attachmentView?.sizeThatFits(contentSizer) ?? .zero : getAttachmentViewSizeThatFits(contentSizer)
        var attachmentViewTop = textBubbleViewFrame.maxY
        if textBubbleViewHeight > 0 && attachmentViewSize.height > 0 {
            attachmentViewTop += attachmentViewMarginTop
        }
        var attachmentViewLeft = contentInset.left
        if !isReply {
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
        
        return CalculatedLayout(textBubbleViewFrame: textBubbleViewFrame, attachmentViewFrame: attachmentViewFrame, timeLabelFrame: timeLabelFrame)
    }
    
    func updateFrames() {
        let layout = getFramesThatFit(bounds.size)
        
        textBubbleView.frame = layout.textBubbleViewFrame
        attachmentView?.frame = layout.attachmentViewFrame
        timeLabel.frame = layout.timeLabelFrame
        
        configureAccessibility()
    }
    
    func configureAccessibility() {
        var elements: [Any] = []
        if !(textBubbleView.accessibilityElements?.isEmpty ?? true) {
            elements.append(textBubbleView)
        }
        if let attachment = attachmentView {
            elements.append(attachment)
        }
        accessibilityElements = elements
    }
    
    // MARK: UIView
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let layout = getFramesThatFit(size)
        guard layout.textBubbleViewFrame.height > 0 || layout.attachmentViewFrame.height > 0 else {
            return .zero
        }
        
        let contentMaxY = max(layout.textBubbleViewFrame.maxY, max(layout.timeLabelFrame.maxY, layout.attachmentViewFrame.maxY))
        let height = contentMaxY + contentInset.bottom
        
        return CGSize(width: size.width, height: height)
    }
}

// MARK: - Time Label Animation

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

// MARK: - Cell Entrance Animation

extension ChatMessageCell {
    
    func animate() {
        guard !isAnimating else {
            return
        }
        isAnimating = true
        let blockStartTime = Date.timeIntervalSinceReferenceDate
        animationStartTime = blockStartTime
        
        prepareAnimation()
        Dispatcher.delay(.milliseconds(100)) { [weak self] in
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

extension ChatMessageCell: MessageButtonsViewContainerDelegate {
    func messageButtonsViewContainer(_ messageButtonsViewContainer: MessageButtonsViewContainer, didTap button: QuickReply) {
        delegate?.chatMessageCell(self, didTap: button)
    }
}
