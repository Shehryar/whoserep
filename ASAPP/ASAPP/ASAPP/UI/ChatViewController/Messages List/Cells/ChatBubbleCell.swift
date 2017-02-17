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

class ChatBubbleCell: UITableViewCell {

    // MARK: Public Properties
    
    var isReply: Bool = false {
        didSet {
            if oldValue != isReply {
                updateFontsAndColors()
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
    
    var contentInset = UIEdgeInsets(top: 3, left: 16, bottom: 3, right: 16) {
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
                let timestamp = dateFormatter.string(from: eventDate as Date)
                detailLabel.setAttributedText(timestamp,
                                              textStyle: .chatTimestamp,
                                              color: ASAPP.styles.foregroundColor2,
                                              styles: ASAPP.styles)
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
        
        bubbleView.clipsToBounds = true
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
    
    func bubbleFillColor() -> UIColor {
        return isReply ? ASAPP.styles.replyMessageFillColor : ASAPP.styles.messageFillColor
    }
    
    func bubbleStrokeColor() -> UIColor? {
        return isReply ? ASAPP.styles.replyMessageStrokeColor : ASAPP.styles.messageStrokeColor
    }
    
    func updateFontsAndColors() {
        guard !ignoresReplyBubbleStyling else {
            return
        }
        
        backgroundColor = ASAPP.styles.backgroundColor1
        bubbleView.backgroundColor = ASAPP.styles.backgroundColor1
        bubbleView.fillColor = bubbleFillColor()
        bubbleView.strokeColor = bubbleStrokeColor()
        
        detailLabel.font = ASAPP.styles.font(for: .chatTimestamp)
        detailLabel.textColor = ASAPP.styles.foregroundColor2
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
        detailLabel.text = nil
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
        
        if contentHeight > 0 {
            contentHeight += contentInset.top + contentInset.bottom
        }
        
        return CGSize(width: size.width, height: contentHeight)
    }
}

// MARK:- Instance Methods

extension ChatBubbleCell {
    
    func canShowDetailLabel() -> Bool {
        return true
    }
    
    func setDetailLabelHidden(_ hidden: Bool, animated: Bool, completion: (() -> Void)? = nil) {
        if hidden == detailLabelHidden { return }
        if !hidden && !canShowDetailLabel() {
            detailLabelHidden = true
            completion?()
            return
        }
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.detailLabelHidden = hidden
                self?.updateFrames()
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
        let animationEndCenter = bubbleView.center
        var animationBeginCenter = bubbleView.center
        animationBeginCenter.y += 12
        
        bubbleView.alpha = 0
        bubbleView.center = animationBeginCenter
        
        UIView.animateKeyframes(withDuration: 0.5, delay: 0, options: .beginFromCurrentState, animations: { [weak self] in
            self?.bubbleView.alpha = 1
            self?.bubbleView.center = animationEndCenter
            }, completion: { [weak self] (completed) in
                self?.animating = false
                self?.setNeedsLayout()
        })
    }
}
