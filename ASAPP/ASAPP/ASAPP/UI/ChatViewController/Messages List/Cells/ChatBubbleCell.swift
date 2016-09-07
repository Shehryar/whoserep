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
    
    private(set) var isReply: Bool = false {
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
    
    // MARK: Private Properties
    
    internal var ignoresReplyBubbleStyling = false
    
    internal let bubbleView = BubbleView()
    
    private var animating = false
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .None
        opaque = true
        
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
    }
}

// MARK:- Layout

extension ChatBubbleCell {
    
    func maxBubbleWidthForBoundsSize(size: CGSize) -> CGFloat{
        return floor(0.85 * (size.width - contentInset.left - contentInset.right))
    }
}

// MARK:- Instance Methods

extension ChatBubbleCell {
    
    func animate() {
        // Subclasses can override
    }
}
