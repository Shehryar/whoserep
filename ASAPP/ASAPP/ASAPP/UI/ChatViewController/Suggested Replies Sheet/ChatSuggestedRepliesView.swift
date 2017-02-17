//
//  ChatSuggestedRepliesView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatSuggestedRepliesViewDelegate: class {
    func chatSuggestedRepliesViewDidCancel(_ repliesView: ChatSuggestedRepliesView)
    func chatSuggestedRepliesViewDidTapBack(_ repliesView: ChatSuggestedRepliesView)
    func chatSuggestedRepliesViewWillTapBack(_ repliesView: ChatSuggestedRepliesView)
    /// Delegate returns YES if the button was successfully acted upon
    func chatSuggestedRepliesView(_ replies: ChatSuggestedRepliesView, didTapSRSButtonItem buttonItem: SRSButtonItem) -> Bool
}

class ChatSuggestedRepliesView: UIView {

    // MARK: Public Properties

    var transparentInsetTop: CGFloat {
        return buttonSize / 2.0 - separatorTopStroke / 2.0
    }
    
    weak var delegate: ChatSuggestedRepliesViewDelegate?
    
    var actionableEventLogSeqs: [Int]? {
        var actionableEventLogSeqs = [Int]()
        for view in actionableMessageViews {
            if let event = view.event {
                actionableEventLogSeqs.append(event.eventLogSeq)
            } else {
                return nil
            }
        }
        return actionableEventLogSeqs
    }
    
    var currentActionableEvent: Event? {
        return actionableMessageViews.last?.event
    }
    
    var currentSRSClassification: String? {
        return currentActionableEvent?.srsResponse?.classification
    }
    
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
        patternView.backgroundColor = Colors.patternBackgroundColor()
        patternBackgroundView.addSubview(patternView)
        
        patternBackgroundView.backgroundColor = ASAPP.styles.backgroundColor2
        addSubview(patternBackgroundView)
        
        addSubview(actionableMessageViewsContainer)
        
        separatorTopView.backgroundColor = ASAPP.styles.separatorColor1
        addSubview(separatorTopView)
        
        backButton.accessibilityLabel = ASAPPLocalizedString("Previous Options")
        backButton.image = Images.asappImage(.iconBack)
        backButton.imageSize = CGSize(width: 11, height: 11)
        backButton.foregroundColor = Colors.mediumTextColor()
        backButton.onTap = { [weak self] in
            if let blockSelf = self {
                blockSelf.delegate?.chatSuggestedRepliesViewWillTapBack(blockSelf)
            }
            
            self?.goToPreviousActionableMessage()
            
            if let blockSelf = self {
                blockSelf.delegate?.chatSuggestedRepliesViewDidTapBack(blockSelf)
            }
        }
        styleButton(backButton)
        addSubview(backButton)
        
        closeButton.isHidden = true
        closeButton.image = Images.asappImage(.iconSmallX)
        closeButton.imageSize = CGSize(width: 11, height: 11)
        closeButton.foregroundColor = Colors.mediumTextColor()
        closeButton.onTap = { [weak self] in
            if let blockSelf = self {
                blockSelf.delegate?.chatSuggestedRepliesViewDidCancel(blockSelf)
            }
        }
        styleButton(closeButton)
        addSubview(closeButton)
        
        updateBackButtonVisibility()
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func styleButton(_ button: Button) {
        button.setForegroundColor(ASAPP.styles.foregroundColor1, forState: .normal)
        button.setForegroundColor(ASAPP.styles.foregroundColor1.highlightColor(), forState: .normal)
        button.setBackgroundColor(ASAPP.styles.backgroundColor1, forState: .normal)
        button.setBackgroundColor(ASAPP.styles.backgroundColor2, forState: .highlighted)
        button.layer.borderColor = ASAPP.styles.separatorColor1.cgColor
        button.layer.borderWidth = 2
        button.clipsToBounds = true
    }
    
    // MARK: Display
    
    func updateDisplay() {
        for view in actionableMessageViews {
            view.updateDisplay()
        }
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
        let rowHeight = ChatActionableMessageView.approximateRowHeight()
        let visibleRows: CGFloat = UIScreen.main.bounds.height > 575 ? 4.6 : 3.5
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
  
    fileprivate func createActionableMessageView(_ actionableMessage: SRSResponse, forEvent event: Event) -> ChatActionableMessageView {
        let actionableMessageView = ChatActionableMessageView()
        actionableMessageView.setSRSResponse(srsResponse: actionableMessage, event: event)
        actionableMessageView.onButtonItemSelection = { [weak self] (buttonItem) in
            if let strongSelf = self,
                let delegate = strongSelf.delegate {
                return delegate.chatSuggestedRepliesView(strongSelf, didTapSRSButtonItem: buttonItem)
            }
            return false
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
                }, completion: { [weak self] (completed) in
                    viewToRemove?.removeFromSuperview()
                    
                    if let currentView = self?.actionableMessageViews.last {
                        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, currentView)
                    }
            })
        }
    }
    
    // MARK: Public
    
    func reloadActionableMessagesWithEvents(_ events: [Event]?) {
        guard let events = events else { return }
        
        clear()
        
        for event in events {
            if let srsResponse = event.srsResponse {
                setActionableMessage(srsResponse, forEvent: event, animated: false)
            }
        }
    }
    
    func setActionableMessage(_ actionableMessage: SRSResponse, forEvent event: Event, animated: Bool = false) {
        let actionableMessageView = createActionableMessageView(actionableMessage, forEvent: event)
        
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
    
    func reloadButtonItemsForActionableMessage(_ actionableMessage: SRSResponse, event: Event) {
        for actionableMessageView in actionableMessageViews {
            if actionableMessageView.event?.eventLogSeq == event.eventLogSeq {
                actionableMessageView.setSRSResponse(srsResponse: actionableMessage, event: event)
                break
            }
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

