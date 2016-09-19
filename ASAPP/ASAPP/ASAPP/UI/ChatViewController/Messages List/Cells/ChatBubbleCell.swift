//
//  ChatBubbleCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

enum MessageListPosition {
    case Default
    case FirstOfMany
    case MiddleOfMany
    case LastOfMany
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
    
    var listPosition: MessageListPosition = .Default {
        didSet {
            if oldValue != listPosition {
                updateBubbleCorners()
            }
        }
    }
    
    var contentInset = UIEdgeInsets(top: 3, left: 22, bottom: 3, right: 22) {
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
                detailLabel.text = dateFormatter.stringFromDate(eventDate)
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
    
    private let dateFormatter = NSDateFormatter()
    
    private var animating = false
    
    private var animationStartTime: Double = 0.0
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .None
        opaque = true
        
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
            case .Default:
                roundedCorners = [.TopLeft, .TopRight, .BottomRight]
                break
                
            case .FirstOfMany:
                roundedCorners =  .AllCorners
                break
                
            case .MiddleOfMany:
                roundedCorners =  .AllCorners
                break
                
            case .LastOfMany:
                roundedCorners = [.TopLeft, .TopRight, .BottomRight]
                break
            }
        } else {
            switch listPosition {
            case .Default:
                roundedCorners = [.TopRight, .TopLeft, .BottomLeft]
                break
                
            case .FirstOfMany:
                roundedCorners = .AllCorners
                break
                
            case .MiddleOfMany:
                roundedCorners = .AllCorners
                break
                
            case .LastOfMany:
                roundedCorners =  [.TopRight, .TopLeft, .BottomLeft] 
                break
            }
        }
        bubbleView.roundedCorners = roundedCorners
    }
    
    // MARK:- ASAPPStyleable
    
    private(set) var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        applyStyles(styles, isReply: isReply)
    }
    
    func applyStyles(styles: ASAPPStyles, isReply: Bool) {
        self.styles = styles
        self.isReply = isReply
        
        updateFontsAndColors()
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
            detailLabel.hidden = false
            detailLabel.alpha = 1
        }
    }
    
    // MARK: Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        layer.removeAllAnimations()
        bubbleView.alpha = 1
        bubbleView.transform = CGAffineTransformIdentity
        animationStartTime = 0
        animating = false
        event = nil
        setDetailLabelHidden(true, animated: false, completion: nil)
    }
}

// MARK:- Layout

extension ChatBubbleCell {
    
    /// Subclasses can override this method
    func bubbleSizeForSize(size: CGSize) -> CGSize {
        return CGSizeZero
    }
    
    /// Subclasses can override this method
    func updateFrames() {
        let bubbleSize = bubbleSizeForSize(bounds.size)
        let detailSize = detailLabelSizeForSize(bounds.size)
        var bubbleLeft = contentInset.left
        var detailLeft = contentInset.left
        if !isReply {
            bubbleLeft = CGRectGetWidth(bounds) - bubbleSize.width - contentInset.right
            detailLeft = CGRectGetWidth(bounds) - detailSize.width - contentInset.right
        }
        bubbleView.frame = CGRect(x: bubbleLeft, y: contentInset.top, width: bubbleSize.width, height: bubbleSize.height)
        
        var detailTop = CGRectGetMaxY(bubbleView.frame)
        if !detailLabelHidden && detailSize.height > 0 {
            detailTop += detailLabelMargin
        }
        detailLabel.frame = CGRect(x: detailLeft, y: detailTop, width: detailSize.width, height: detailSize.height)
    }
    
    func detailLabelSizeForSize(size: CGSize) -> CGSize {
        let maxWidth = maxBubbleWidthForBoundsSize(size)
        let detailSize = detailLabel.sizeThatFits(CGSize(width: maxWidth, height: 0))
        
        return CGSize(width: ceil(detailSize.width), height: ceil(detailSize.height))
    }
    
    func maxBubbleWidthForBoundsSize(size: CGSize) -> CGFloat{
        return floor(0.85 * (size.width - contentInset.left - contentInset.right))
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var contentHeight = bubbleSizeForSize(size).height
        
        let maxLabelWidth = maxBubbleWidthForBoundsSize(size)
        if !detailLabelHidden {
            let detailLabelSize = detailLabel.sizeThatFits(size)
            if detailLabelSize.height > 0 {
                contentHeight += detailLabelSize.height + detailLabelMargin
            }
        }
        
        return CGSize(width: size.width, height: contentHeight + contentInset.top + contentInset.bottom)
    }
}

// MARK:- Instance Methods

extension ChatBubbleCell {
    
    func setDetailLabelHidden(hidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        if hidden == detailLabelHidden { return }
        
        if animated {
            UIView.animateWithDuration(0.3, animations: {
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
        animationStartTime = NSDate().timeIntervalSince1970
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
        var animationBeginCenter = CGPoint(x: 0, y: CGRectGetHeight(bounds) - contentInset.bottom)
        
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
        animationBeginCenter.x = animationEndCenter.x
        
        
        bubbleView.alpha = 0
        bubbleView.center = animationBeginCenter
        
        UIView.animateKeyframesWithDuration(0.2, delay: 0, options: .BeginFromCurrentState, animations: {
            self.bubbleView.alpha = 1
            self.bubbleView.center = animationEndCenter
            }, completion: { (completed) in
                self.animating = false
                self.setNeedsLayout()
        })
    }
}
