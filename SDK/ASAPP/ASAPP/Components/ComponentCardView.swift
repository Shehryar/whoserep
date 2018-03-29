//
//  ComponentCardView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/20/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentCardView: BubbleView, MessageButtonsViewContainer, MessageBubbleCornerRadiusUpdating {
    weak var delegate: MessageButtonsViewContainerDelegate?
    
    var backgroundLayer: CALayer?
    
    var message: ChatMessage? {
        didSet {
            guard let message = message else {
                return
            }
            
            roundedCorners = getBubbleCorners(for: message, isAttachment: true)
            
            setNeedsDisplay()
        }
    }
    
    var messagePosition: MessageListPosition = .none {
        didSet {
            if let message = message {
                roundedCorners = getBubbleCorners(for: message, isAttachment: true)
            }
        }
    }
    
    var component: Component? {
        didSet {
            componentView = component?.createView()
            componentView?.interactionHandler = interactionHandler
            componentView?.contentHandler = contentHandler
            setNeedsLayout()
        }
    }
    
    var borderDisabled: Bool = false {
        didSet {
            if borderDisabled {
                strokeColor = nil
            }
        }
    }
    
    var interactionHandler: InteractionHandler? {
        didSet {
            componentView?.interactionHandler = interactionHandler
        }
    }
    
    var contentHandler: ComponentViewContentHandler? {
        didSet {
            componentView?.contentHandler = contentHandler
        }
    }
    
    private(set) var componentView: ComponentView? {
        didSet {
            oldValue?.view.removeFromSuperview()
            
            componentView?.interactionHandler = interactionHandler
            if let componentView = componentView {
                addSubview(componentView.view)
            }
            setNeedsLayout()
        }
    }
    
    var messageButtonsView: MessageButtonsView? {
        didSet {
            if let view = messageButtonsView, oldValue == nil {
                view.contentInsets = UIEdgeInsets(top: 10, left: 16, bottom: 10, right: 16)
                view.delegate = self
                addSubview(view)
            }
            
            if let message = message {
                roundedCorners = getBubbleCorners(for: message, isAttachment: true)
            }
        }
    }
    
    func commonInit() {
        super.commonInit()
        fillColor = .clear
        strokeColor = ASAPP.styles.colors.replyMessageBorder
        strokeLineWidth = 1
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    deinit {
        componentView?.interactionHandler = nil
    }
    
    override func draw(_ rect: CGRect) {
        drawBubble(rect)
        
        backgroundLayer = setLinearGradient(degrees: 25, colors: ASAPP.styles.colors.attachmentGradientColors)
    }
    
    override func prepareForReuse() {
        backgroundLayer?.removeAllAnimations()
        backgroundLayer?.removeFromSuperlayer()
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let messageButtonsHeight = getMessageButtonsViewSizeThatFits(bounds.width).height
        messageButtonsView?.frame = CGRect(x: 0, y: bounds.height - messageButtonsHeight, width: bounds.width, height: messageButtonsHeight)
        
        componentView?.view.frame = CGRect(x: 0, y: 0, width: bounds.width, height: bounds.height - messageButtonsHeight)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let componentView = componentView else {
            return .zero
        }
        
        let fittedSize = componentView.view.sizeThatFits(size)
        
        let messageButtonsSize = getMessageButtonsViewSizeThatFits(size.width)
            
        return CGSize(width: fittedSize.width, height: fittedSize.height + messageButtonsSize.height)
    }
}

extension ComponentCardView: MessageButtonsViewDelegate {
    func messageButtonsView(_ messageButtonsView: MessageButtonsView, didTapButtonWith action: Action) {
        delegate?.messageButtonsViewContainer(self, didTapButtonWith: action)
    }
}
