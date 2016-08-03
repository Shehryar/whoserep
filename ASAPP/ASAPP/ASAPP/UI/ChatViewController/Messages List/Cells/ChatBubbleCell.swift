//
//  ChatBubbleCell.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SnapKit

enum MessageBubbleStyling {
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
                setNeedsUpdateConstraints()
            }
        }
    }
    
    var bubbleStyling: MessageBubbleStyling = .Default {
        didSet {
            if oldValue != bubbleStyling {
                updateBubbleCorners()
            }
        }
    }
    
    var contentInset = UIEdgeInsets(top: 2, left: 16, bottom: 2, right: 16) {
        didSet {
            if oldValue != contentInset {
                setNeedsUpdateConstraints()
            }
        }
    }
    
    // MARK: Private Properties
    
    internal var maxMessageWidth: CGFloat {
        return floor(0.8 * (CGRectGetWidth(bounds) - contentInset.left - contentInset.right))
    }
    
    internal var ignoresReplyBubbleStyling = false
    
    internal let bubbleView = BubbleView()
    
    private var leftConstraint: Constraint?
    
    private var rightConstraint: Constraint?
    
    private var animating = false
    
    // MARK: Init
    
    func commonInit() {
        selectionStyle = .None
        opaque = true
        
        bubbleView.translatesAutoresizingMaskIntoConstraints = false
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
            switch bubbleStyling {
            case .Default:
                roundedCorners = [.TopLeft, .TopRight, .BottomRight]
                break
                
            case .FirstOfMany:
                roundedCorners =  .AllCorners//[.TopLeft, .TopRight, .BottomRight] // FB-style
                break
                
            case .MiddleOfMany:
                roundedCorners =  .AllCorners//[.TopRight, .BottomRight]
                break
                
            case .LastOfMany:
                roundedCorners = [.TopLeft, .TopRight, .BottomRight]//[.TopRight, .BottomRight, .BottomLeft]
                break
            }
        } else {
            switch bubbleStyling {
            case .Default:
                roundedCorners = [.TopRight, .TopLeft, .BottomLeft]
                break
                
            case .FirstOfMany:
                roundedCorners = .AllCorners//[.TopRight, .TopLeft, .BottomLeft]
                break
                
            case .MiddleOfMany:
                roundedCorners = .AllCorners// [.TopLeft, .BottomLeft]
                break
                
            case .LastOfMany:
                roundedCorners =  [.TopRight, .TopLeft, .BottomLeft] //[.TopLeft, .BottomLeft, .BottomRight]
                break
            }
        }
        bubbleView.roundedCorners = roundedCorners
    }
    
    // MARK:- ASAPPStyleable
    
    var styles: ASAPPStyles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        applyStyles(styles, isReply: isReply)
    }
    
    func applyStyles(styles: ASAPPStyles, isReply: Bool) {
        self.styles = styles
        self.isReply = isReply
        
        updateFontsAndColors()
    }
    
    func updateFontsAndColors() {
        guard !ignoresReplyBubbleStyling else {
            return
        }
        
        backgroundColor = styles.backgroundColor1
        if isReply {
            bubbleView.fillColor = styles.replyMessageFillColor
            bubbleView.strokeColor = styles.replyMessageStrokeColor
        } else {
            bubbleView.fillColor = styles.messageFillColor
            bubbleView.strokeColor = styles.messageStrokeColor
        }
        bubbleView.backgroundColor = styles.backgroundColor1
    }
}

// MARK:- Layout

extension ChatBubbleCell {
    
    override func updateConstraints() {
        leftConstraint?.uninstall()
        rightConstraint?.uninstall()
        
        bubbleView.snp_updateConstraints { (make) in
            if isReply {
                self.leftConstraint = make.left.equalTo(contentView.snp_left).offset(contentInset.left).constraint
            } else {
                self.rightConstraint = make.right.equalTo(contentView.snp_right).offset(-contentInset.right).constraint
            }
            make.top.equalTo(contentView.snp_top).offset(contentInset.top)
            make.width.lessThanOrEqualTo(maxMessageWidth)
        }
        
        contentView.snp_updateConstraints { (make) in
            make.edges.equalTo(self)
            make.height.greaterThanOrEqualTo(bubbleView.snp_height).offset(contentInset.top + contentInset.bottom)
        }
        super.updateConstraints()
    }
}

// MARK:- Instance Methods

extension ChatBubbleCell {
    
    func animate() {
        // Subclasses can override
    }
}
