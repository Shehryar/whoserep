//
//  ComponentCardView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/20/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentCardView: UIView, MessageButtonsViewContainer {
    weak var delegate: MessageButtonsViewContainerDelegate?
    
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
            updateBorder()
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
        }
    }
    
    // MARK: Initialization
    
    func commonInit() {
        
        updateBorder()
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
    
    // MAKR: Utility
    
    func updateBorder() {
        if borderDisabled {
            clipsToBounds = false
            backgroundColor = UIColor.clear
            layer.borderColor = nil
            layer.borderWidth = 0
        } else {
            clipsToBounds = true
            backgroundColor = ASAPP.styles.colors.backgroundPrimary
            layer.borderColor = ASAPP.styles.colors.replyMessageBorder.cgColor
            layer.borderWidth = ASAPP.styles.separatorStrokeWidth
            layer.cornerRadius = 20
            layer.masksToBounds = true
        }
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
