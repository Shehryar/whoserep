//
//  ChatSuggestedRepliesView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatSuggestedRepliesViewDelegate {
    func chatSuggestedRepliesViewDidCancel(_ repliesView: ChatSuggestedRepliesView)
    func chatSuggestedRepliesView(_ replies: ChatSuggestedRepliesView, didTapSRSButtonItem buttonItem: SRSButtonItem)
}


// TODO: Handle Accessibility

class ChatSuggestedRepliesView: UIView, ASAPPStyleable {

    // MARK: Public Properties

    var transparentInsetTop: CGFloat {
        return buttonSize / 2.0 - separatorTopStroke / 2.0
    }
    
    var delegate: ChatSuggestedRepliesViewDelegate?
    
    // MARK: Private Properties
    
    fileprivate let buttonSize: CGFloat = 46.0
    
    fileprivate let separatorTopStroke: CGFloat = 2.0
    
    fileprivate var actionableMessageViews = [ChatActionableMessageView]()
    
    fileprivate var selectedButtonItem: SRSButtonItem?
    
    fileprivate var currentActionableViewIndex = 0
    
    fileprivate var animating = false
    
    // MARK: UI Properties
    
    fileprivate let backButton = Button()
    
    fileprivate let closeButton = Button()
    
    fileprivate let separatorTopView = UIView()
    
    fileprivate let patternBackgroundView = UIView()
    
    fileprivate let patternView = UIView()
    
    fileprivate let actionableMessageViewsContainer = UIView()
    
    // MARK: Initialization
    
    func commonInit() {
        patternBackgroundView.addSubview(patternView)
        addSubview(patternBackgroundView)
        
        addSubview(actionableMessageViewsContainer)
        addSubview(separatorTopView)
        
        backButton.image = Images.iconBack()
        backButton.imageSize = CGSize(width: 11, height: 11)
        backButton.foregroundColor = Colors.mediumTextColor()
        backButton.onTap = { [weak self] in
            self?.goToPreviousActionableMessage()
        }
        addSubview(backButton)
        
        closeButton.isHidden = true
        closeButton.image = Images.iconSmallX()
        closeButton.imageSize = CGSize(width: 11, height: 11)
        closeButton.foregroundColor = Colors.mediumTextColor()
        closeButton.onTap = { [weak self] in
            if let blockSelf = self {
                blockSelf.delegate?.chatSuggestedRepliesViewDidCancel(blockSelf)
            }
        }
        addSubview(closeButton)
        
        updateBackButtonVisibility()
        applyStyles(styles)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: ASAPPStyleable
    
    fileprivate(set) var styles = ASAPPStyles()
    
    func applyStyles(_ styles: ASAPPStyles) {
        self.styles = styles
        
        styleButton(backButton, withStyles: styles)
        styleButton(closeButton, withStyles: styles)
        
        separatorTopView.backgroundColor = styles.separatorColor1
        
        patternBackgroundView.backgroundColor = styles.backgroundColor2
        patternView.backgroundColor = Colors.patternBackgroundColor()
    
        for actionableMessageView in actionableMessageViews {
            actionableMessageView.applyStyles(styles)
        }
    }
    
    func styleButton(_ button: Button, withStyles styles: ASAPPStyles) {
        button.setForegroundColor(styles.foregroundColor1, forState: .normal)
        button.setForegroundColor(styles.foregroundColor1.highlightColor(), forState: .normal)
        button.setBackgroundColor(styles.backgroundColor1, forState: .normal)
        button.setBackgroundColor(styles.backgroundColor2, forState: .highlighted)
        button.layer.borderColor = styles.separatorColor1.cgColor
        button.layer.borderWidth = 2
        button.clipsToBounds = true
    }
}

// MARK:- Layout

extension ChatSuggestedRepliesView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Buttons
        let buttonInset: CGFloat = 15
        let cornerRadius = buttonSize / 2.0
        let backButtonLeft = buttonInset
        backButton.frame = CGRect(x: backButtonLeft, y: 0.0, width: buttonSize, height: buttonSize)
        backButton.layer.cornerRadius = cornerRadius
        
        let closeButtonLeft = bounds.width - buttonSize - buttonInset
        closeButton.frame = CGRect(x: closeButtonLeft, y: 0.0, width: buttonSize, height: buttonSize)
        closeButton.layer.cornerRadius = cornerRadius
        
        // Separator Top
        
        let separatorTop = closeButton.center.y - separatorTopStroke / 2.0
        separatorTopView.frame = CGRect(x: 0.0, y: separatorTop, width: bounds.width, height: separatorTopStroke)
        
        // Background
        
        let backgroundTop = separatorTopView.frame.maxY
        let backgroundHeight = bounds.height - backgroundTop
        patternBackgroundView.frame = CGRect(x: 0.0, y: backgroundTop, width: bounds.width, height: backgroundHeight)
        patternView.frame = patternBackgroundView.bounds
        
        // Actionable Views
        
        let actionableMessagesTop = separatorTopView.frame.maxY
        let actionableMessagesHeight = bounds.height - actionableMessagesTop
        actionableMessageViewsContainer.frame = CGRect(x: 0.0, y: actionableMessagesTop, width: bounds.width, height: actionableMessagesHeight)
        
        if !animating {
            updateActionableViewFrames()
        }
    }
    
    func preferredDisplayHeight() -> CGFloat {
        let rowHeight = ChatActionableMessageView.approximateRowHeight(withStyles: styles)
        let visibleRows: CGFloat = 4.23
        return rowHeight * visibleRows + transparentInsetTop
    }
    
    func updateActionableViewFrames() {
        let width = actionableMessageViewsContainer.bounds.width
        let height = actionableMessageViewsContainer.bounds.height
        
        var left = -width * CGFloat(currentActionableViewIndex)
        for actionableMessageView in actionableMessageViews {
            actionableMessageView.frame = CGRect(x: left, y: 0, width: width, height: height)
            left += width
        }
    }
    
    func updateBackButtonVisibility() {
        if actionableMessageViews.count > 1 {
            backButton.alpha = 1
        } else {
            backButton.alpha = 0
        }
    }
}

// MARK:- Instance Methods

extension ChatSuggestedRepliesView {
  
    fileprivate func createActionableMessageView(_ actionableMessage: SRSResponse) -> ChatActionableMessageView {
        let actionableMessageView = ChatActionableMessageView()
        actionableMessageView.srsResponse = actionableMessage
        actionableMessageView.onButtonItemSelection = { [weak self] (buttonItem) in
            if let strongSelf = self {
                strongSelf.delegate?.chatSuggestedRepliesView(strongSelf, didTapSRSButtonItem: buttonItem)
            }
        }
        actionableMessageViewsContainer.addSubview(actionableMessageView)
        actionableMessageViews.append(actionableMessageView)
        updateActionableViewFrames()
        
        return actionableMessageView
    }
    
    fileprivate func goToPreviousActionableMessage() {
        if actionableMessageViews.count > 1 && currentActionableViewIndex > 0 {
            currentActionableViewIndex -= 1
            
            let viewToRemove = self.actionableMessageViews.last
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.updateActionableViewFrames()
                self.actionableMessageViews.removeLast()
                self.updateBackButtonVisibility()
                }, completion: { (completed) in
                    viewToRemove?.removeFromSuperview()
            })
        }
    }
    
    // MARK: Public
    
    func setActionableMessage(_ actionableMessage: SRSResponse, animated: Bool = false) {
        let actionableMessageView = createActionableMessageView(actionableMessage)
        
        if let nextIndex = actionableMessageViews.index(of: actionableMessageView) {
            currentActionableViewIndex = nextIndex
        }
        
        if actionableMessageViews.count > 1 && animated {
            animating = true
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.updateBackButtonVisibility()
                self.updateActionableViewFrames()
                }, completion: { (completed) in
                    self.animating = false
                    actionableMessageView.flashScrollIndicatorsIfNecessary()
                    for previousView in self.actionableMessageViews {
                        if previousView != actionableMessageView {
                            previousView.clearSelection()
                        }
                    }
            })
        } else {
            updateBackButtonVisibility()
            updateActionableViewFrames()
            actionableMessageView.flashScrollIndicatorsIfNecessary()
        }
    }
    
    func clear() {
        for view in actionableMessageViews {
            view.removeFromSuperview()
        }
        actionableMessageViews.removeAll()
    }
    
    func deselectCurrentSelection(animated: Bool) {
        if let currentView = actionableMessageViews.last {
            currentView.deselectButtonSelection(animated: animated)
        }
    }
}

