//
//  ChatBubbleCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum MessageListPosition {
    case `default`
    case firstOfMany
    case middleOfMany
    case lastOfMany
}

class ChatBubbleCell: UITableViewCell, ASAPPStyleable {

    // MARK: Public Properties
    
    var isReply: Bool = false {
        didSet {
            if oldValue != isReply {
                updateBubbleCorners()
                setNeedsLayout()
            }
        }
    }
    
    var listPosition: MessageListPosition = .default {
        didSet {
            if oldValue != listPosition {
                updateBubbleCorners()
            }
        }
    }
    
    var contentInset = UIEdgeInsets(top: 3, left: 25, bottom: 3, right: 25) {
        didSet {
            if oldValue != contentInset {
                setNeedsLayout()
            }
        }
    }
    
    var event: Event? {
        didSet {
            if let event = event {
                let eventDate = event.eventDate
                dateFormatter.dateFormat = eventDate.dateFormatForMostRecent()
                detailLabel.attributedText = NSAttributedString(string: dateFormatter.string(from: eventDate as Date), attributes: [
                    NSFontAttributeName : styles.captionFont,
                    NSForegroundColorAttributeName : styles.foregroundColor2,
                    NSKernAttributeName : 0.8
                    ])
            } else {
                detailLabel.text = nil
            }
            setNeedsLayout()
        }
    }
    
    var detailLabelMargin: CGFloat = 5.0 {
        didSet {
            setNeedsLayout()
        }
    }
    
    var detailLabelHidden: Bool = true {
        didSet {
            updateDetailLabelVisibility()
            setNeedsLayout()
        }
    }
    
    // MARK: Private Properties
    
    internal var ignoresReplyBubbleStyling = false
    
    internal let bubbleView = BubbleView()
    
    internal let detailLabel = UILabel()
    
    fileprivate let dateFormatter = DateFormatter()
    
    fileprivate var animating = false
    
    fileprivate var animationStartTime: Double = 0.0
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .none
        isOpaque = true
        
        updateDetailLabelVisibility()
        contentView.addSubview(detailLabel)
        
        contentView.addSubview(bubbleView)
        
        updateBubbleCorners()
        updateFontsAndColors()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(style: UITableViewCellStyle, reuseIdentifier: String?) {
        super.init(style: style, reuseIdentifier: reuseIdentifier)
        commonInit()
    }
    
    // MARK: Styling
    
    func updateBubbleCorners() {
        var roundedCorners: UIRectCorner
        if isReply {
            switch listPosition {
            case .default:
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
            switch listPosition {
            case .default:
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
    
    // MARK:- ASAPPStyleable
    
    fileprivate(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        applyStyles(styles, isReply: isReply)
    }
    
    func applyStyles(_ styles: ASAPPStyles, isReply: Bool) {
        if styles != self.styles || isReply != self.isReply {
            self.styles = styles
            self.isReply = isReply
        
            updateFontsAndColors()
        }
    }
    
    func bubbleFillColor() -> UIColor {
        return isReply ? styles.replyMessageFillColor : styles.messageFillColor
    }
    
    func bubbleStrokeColor() -> UIColor? {
        return isReply ? styles.replyMessageStrokeColor : styles.messageStrokeColor
    }
    
    func updateFontsAndColors() {
        guard !ignoresReplyBubbleStyling else {
            return
        }
        
        backgroundColor = styles.backgroundColor1
        bubbleView.backgroundColor = styles.backgroundColor1
        bubbleView.fillColor = bubbleFillColor()
        bubbleView.strokeColor = bubbleStrokeColor()
        
        detailLabel.font = styles.captionFont
        detailLabel.textColor = styles.foregroundColor2
        detailLabel.backgroundColor = backgroundColor
        
        setNeedsLayout()
    }
    
    func updateDetailLabelVisibility() {
        if detailLabelHidden {
            detailLabel.alpha = 0
        } else {
            detailLabel.isHidden = false
            detailLabel.alpha = 1
        }
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.removeAllAnimations()
        bubbleView.alpha = 1
        bubbleView.transform = CGAffineTransform.identity
        animationStartTime = 0
        animating = false
        event = nil
        setDetailLabelHidden(true, animated: false, completion: nil)
    }
}

// MARK:- Layout

extension ChatBubbleCell {
    
    /// Subclasses can override this method
    func bubbleSizeForSize(_ size: CGSize) -> CGSize {
        return CGSize.zero
    }
    
    /// Subclasses can override this method
    func updateFrames() {
        let bubbleSize = bubbleSizeForSize(bounds.size)
        let detailSize = detailLabelSizeForSize(bounds.size)
        var bubbleLeft = contentInset.left
        var detailLeft = contentInset.left
        if !isReply {
            bubbleLeft = bounds.width - bubbleSize.width - contentInset.right
            detailLeft = bounds.width - detailSize.width - contentInset.right
        }
        bubbleView.frame = CGRect(x: bubbleLeft, y: contentInset.top, width: bubbleSize.width, height: bubbleSize.height)
        
        var detailTop = bubbleView.frame.maxY
        if !detailLabelHidden && detailSize.height > 0 {
            detailTop += detailLabelMargin
        }
        detailLabel.frame = CGRect(x: detailLeft, y: detailTop, width: detailSize.width, height: detailSize.height)
    }
    
    func detailLabelSizeForSize(_ size: CGSize) -> CGSize {
        let maxWidth = maxBubbleWidthForBoundsSize(size)
        let detailSize = detailLabel.sizeThatFits(CGSize(width: maxWidth, height: 0))
        
        return CGSize(width: ceil(detailSize.width), height: ceil(detailSize.height))
    }
    
    func maxBubbleWidthForBoundsSize(_ size: CGSize) -> CGFloat{
        return floor(0.85 * (size.width - contentInset.left - contentInset.right))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var contentHeight = bubbleSizeForSize(size).height
        
        let maxLabelWidth = maxBubbleWidthForBoundsSize(size)
        if !detailLabelHidden {
            let detailLabelSize = detailLabel.sizeThatFits(CGSize(width: maxLabelWidth, height: size.height))
            if detailLabelSize.height > 0 {
                contentHeight += ceil(detailLabelSize.height) + detailLabelMargin
            }
        }
        
        return CGSize(width: size.width, height: contentHeight + contentInset.top + contentInset.bottom)
    }
}

// MARK:- Instance Methods

extension ChatBubbleCell {
    
    func setDetailLabelHidden(_ hidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        if hidden == detailLabelHidden { return }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: {
                self.detailLabelHidden = hidden
                self.updateFrames()
                }, completion: { (completed) in
                    completion?()
            })
        } else {
            detailLabelHidden = hidden
            updateFrames()
            completion?()
        }
    }
    
    // MARK:- Animations
    
    func animate() {
        guard !animating else { return }
        
        animating = true
        animationStartTime = Date().timeIntervalSince1970
        let blockStartTime = animationStartTime
        
        prepareToAnimate()
        
        Dispatcher.delay(100) {
            if self.animating && self.animationStartTime == blockStartTime {
                self.performAnimation()
            }
        }
    }
    
    internal func prepareToAnimate() {
        bubbleView.alpha = 0
    }
    
    internal func performAnimation() {
        var animationBeginCenter = CGPoint(x: 0, y: bounds.height - contentInset.bottom)
        
        var animationEndCenter = CGPoint()
        if bubbleView.bounds.isEmpty {
            let messageSize = bubbleView.sizeThatFits(bounds.size)
            animationEndCenter.y = bounds.height - contentInset.bottom - messageSize.height / 2.0
            if isReply {
                animationEndCenter.x = contentInset.left + messageSize.width / 2.0
            } else {
                animationEndCenter.x = bounds.width - contentInset.right - messageSize.width / 2.0
            }
        } else {
            animationEndCenter = bubbleView.center
        }
        animationBeginCenter.x = animationEndCenter.x
        
        
        bubbleView.alpha = 0
        bubbleView.center = animationBeginCenter
        
        UIView.animateKeyframes(withDuration: 0.2, delay: 0, options: .beginFromCurrentState, animations: {
            self.bubbleView.alpha = 1
            self.bubbleView.center = animationEndCenter
            }, completion: { (completed) in
                self.animating = false
                self.setNeedsLayout()
        })
    }
}
