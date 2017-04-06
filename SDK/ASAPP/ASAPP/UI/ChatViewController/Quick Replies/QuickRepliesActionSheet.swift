//
//  QuickRepliesActionSheet.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol QuickRepliesActionSheetDelegate: class {
    func quickRepliesActionSheetDidCancel(_ actionSheet: QuickRepliesActionSheet)
    func quickRepliesActionSheetDidTapBack(_ actionSheet: QuickRepliesActionSheet)
    func quickRepliesActionSheetWillTapBack(_ actionSheet: QuickRepliesActionSheet)
    /// Delegate returns YES if the button was successfully acted upon
    func quickRepliesActionSheet(_ actionSheet: QuickRepliesActionSheet,
                                 didSelect buttonItem: SRSButtonItem,
                                 for message: ChatMessage) -> Bool
}

class QuickRepliesActionSheet: UIView {

    // MARK: Public Properties

    weak var delegate: QuickRepliesActionSheetDelegate?
    
    var eventIds: [Int] {
        var eventIds = [Int]()
        for view in listViews {
            if let message = view.message {
                eventIds.append(message.eventId)
            }
        }
        return eventIds
    }
    
    var currentMessage: ChatMessage? {
        return listViews.last?.message
    }
    
    var currentSRSClassification: String? {
        return (currentMessage?.attachment as? EventSRSResponse)?.classification
    }
    
    var transparentInsetTop: CGFloat {
        return buttonSize / 2.0 - separatorTopStroke / 2.0
    }
    
    // MARK: Private Properties
    
    fileprivate let buttonSize: CGFloat = 46.0
    
    fileprivate let separatorTopStroke: CGFloat = 2.0
    
    fileprivate var listViews = [QuickRepliesListView]()
    
    fileprivate var currentViewIndex = 0
    
    fileprivate var animating = false
    
    // MARK: UI Properties
    
    fileprivate let backButton = Button()
    
    fileprivate let closeButton = Button()
    
    fileprivate let separatorTopView = UIView()
    
    fileprivate let patternBackgroundView = UIView()
    
    fileprivate let patternView = UIView()
    
    fileprivate let containerView = UIView()
    
    // MARK: Initialization
    
    func commonInit() {
        patternView.backgroundColor = Colors.patternBackgroundColor()
        patternBackgroundView.addSubview(patternView)
        
        patternBackgroundView.backgroundColor = ASAPP.styles.quickReplyButtonBackroundColor
        addSubview(patternBackgroundView)
        
        addSubview(containerView)
        
        separatorTopView.backgroundColor = ASAPP.styles.primarySeparatorColor
        addSubview(separatorTopView)
        
        backButton.accessibilityLabel = ASAPPLocalizedString("Previous Options")
        backButton.image = Images.asappImage(.iconBack)
        backButton.imageSize = CGSize(width: 11, height: 11)
        backButton.foregroundColor = Colors.mediumTextColor()
        backButton.onTap = { [weak self] in
            if let blockSelf = self {
                blockSelf.delegate?.quickRepliesActionSheetWillTapBack(blockSelf)
            }
            
            self?.goToPreviousListView()
            
            if let blockSelf = self {
                blockSelf.delegate?.quickRepliesActionSheetDidTapBack(blockSelf)
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
                blockSelf.delegate?.quickRepliesActionSheetDidCancel(blockSelf)
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
        button.setForegroundColor(ASAPP.styles.primaryTextColor, forState: .normal)
        button.setForegroundColor(ASAPP.styles.primaryTextColor.highlightColor(), forState: .normal)
        button.setBackgroundColor(ASAPP.styles.primaryBackgroundColor, forState: .normal)
        button.setBackgroundColor(ASAPP.styles.secondaryBackgroundColor, forState: .highlighted)
        button.layer.borderColor = ASAPP.styles.primarySeparatorColor.cgColor
        button.layer.borderWidth = 2
        button.clipsToBounds = true
    }
    
    // MARK: Display
    
    func updateDisplay() {
        for view in listViews {
            view.updateDisplay()
        }
    }
}

// MARK:- Layout

extension QuickRepliesActionSheet {
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
        
        // listViews
        
        let containerTop = separatorTopView.frame.maxY
        let containerHeight = bounds.height - containerTop
        containerView.frame = CGRect(x: 0.0, y: containerTop, width: bounds.width, height: containerHeight)
        
        if !animating {
            updateListViewFrames()
        }
    }
    
    func preferredDisplayHeight() -> CGFloat {
        let rowHeight = QuickRepliesListView.approximateRowHeight()
        let visibleRows: CGFloat = UIScreen.main.bounds.height > 575 ? 4.6 : 3.5
        return rowHeight * visibleRows + transparentInsetTop
    }
    
    func updateListViewFrames() {
        let width = containerView.bounds.width
        let height = containerView.bounds.height
        
        var left = -width * CGFloat(currentViewIndex)
        for listView in listViews {
            listView.frame = CGRect(x: left, y: 0, width: width, height: height)
            left += width
        }
    }
    
    func updateBackButtonVisibility() {
        if listViews.count > 1 {
            backButton.alpha = 1
        } else {
            backButton.alpha = 0
        }
    }
}

// MARK:- Instance Methods

extension QuickRepliesActionSheet {
  
    fileprivate func createQuickRepliesListView(with message: ChatMessage) -> QuickRepliesListView {
        let listView = QuickRepliesListView()
        listView.message = message
        listView.onButtonItemSelection = { [weak self] (buttonItem) in
            if let strongSelf = self,
                let delegate = strongSelf.delegate {
                return delegate.quickRepliesActionSheet(strongSelf, didSelect: buttonItem, for: message)
            }
            return false
        }
        containerView.addSubview(listView)
        listViews.append(listView)
        updateListViewFrames()
        
        return listView
    }
    
    fileprivate func goToPreviousListView() {
        if listViews.count > 1 && currentViewIndex > 0 {
            currentViewIndex -= 1
            
            let viewToRemove = self.listViews.last
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.updateListViewFrames()
                self.listViews.removeLast()
                self.updateBackButtonVisibility()
                }, completion: { [weak self] (completed) in
                    viewToRemove?.removeFromSuperview()
                    
                    if let currentView = self?.listViews.last {
                        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, currentView)
                    }
            })
        }
    }
    
    // MARK: Public
    
    func reload(with messages: [ChatMessage]?) {
        clear()
        
        if let messages = messages {
            for message in messages {
                add(message: message, animated: false)
            }
        }
    }
    
    func add(message: ChatMessage, animated: Bool) {
        let listView = createQuickRepliesListView(with: message)
        if let nextIndex = listViews.index(of: listView) {
            currentViewIndex = nextIndex
        }
        
        if listViews.count > 1 && animated {
            animating = true
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: {
                self.updateBackButtonVisibility()
                self.updateListViewFrames()
                }, completion: { (completed) in
                    self.animating = false
                    listView.flashScrollIndicatorsIfNecessary()
                    for previousView in self.listViews {
                        if previousView != listView {
                            previousView.clearSelection()
                        }
                    }
            })
        } else {
            updateBackButtonVisibility()
            updateListViewFrames()
            listView.flashScrollIndicatorsIfNecessary()
        }
    }
    
    func reloadButtons(for message: ChatMessage) {
        for listView in listViews {
            if listView.message?.eventId == message.eventId {
                listView.message = message
                break
            }
            
        }
    }
    
    func clear() {
        for view in listViews {
            view.message = nil
            view.removeFromSuperview()
        }
        listViews.removeAll()
    }
    
    func deselectCurrentSelection(animated: Bool) {
        if let currentView = listViews.last {
            currentView.deselectButtonSelection(animated: animated)
        }
    }
}

