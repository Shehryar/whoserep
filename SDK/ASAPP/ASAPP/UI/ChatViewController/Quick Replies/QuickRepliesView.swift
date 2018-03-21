//
//  QuickRepliesView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol QuickRepliesViewDelegate: class {
    func quickRepliesViewDidTapRestart(_ quickRepliesView: QuickRepliesView)
    
    /// Delegate returns true if the button was successfully acted upon
    func quickRepliesView(_ quickRepliesView: QuickRepliesView,
                          didSelect quickReply: QuickReply,
                          from message: ChatMessage) -> Bool
}

class QuickRepliesView: UIView {

    // MARK: Public Properties

    weak var delegate: QuickRepliesViewDelegate?
    
    var eventIds: [Int] {
        var eventIds = [Int]()
        for view in listViews {
            if let message = view.message {
                eventIds.append(message.metadata.eventId)
            }
        }
        return eventIds
    }
    
    var currentMessage: ChatMessage? {
        return listViews.last?.message
    }
    
    var currentSRSClassification: String? {
        return currentMessage?.metadata.classification
    }
    
    var isRestartButtonVisible: Bool = false {
        didSet {
            restartButton.alpha = isRestartButtonVisible ? 1 : 0
            listViews.forEach { view in
                view.contentInsetBottom = isRestartButtonVisible ? restartButton.defaultHeight : 0
            }
        }
    }
    
    var isCollapsed = true
    
    // MARK: Private Properties
    
    private let buttonSize: CGFloat = 34
    
    private let separatorTopStroke: CGFloat = 1
    
    private var listViews = [QuickRepliesListView]()
    
    private var currentViewIndex = 0
    
    private var animating = false
    
    // MARK: UI Properties
    
    private let restartButton = RestartButton()
    
    private let separatorTopView = UIView()
    
    private let containerView = UIView()
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = ASAPP.styles.colors.quickRepliesBackground
        
        addSubview(containerView)
        
        separatorTopView.backgroundColor = ASAPP.styles.colors.separatorSecondary
        addSubview(separatorTopView)
        
        restartButton.onTap = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.quickRepliesViewDidTapRestart(strongSelf)
            }
        }
        addSubview(restartButton)
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
        button.setForegroundColor(ASAPP.styles.colors.quickReplyButton.textNormal, forState: .normal)
        button.setForegroundColor(ASAPP.styles.colors.quickReplyButton.textHighlighted, forState: .highlighted)
        button.setBackgroundColor(ASAPP.styles.colors.quickReplyButton.backgroundNormal, forState: .normal)
        button.setBackgroundColor(ASAPP.styles.colors.quickReplyButton.backgroundHighlighted, forState: .highlighted)
        button.clipsToBounds = true
    }
    
    // MARK: Display
    
    func updateDisplay() {
        for view in listViews {
            view.updateDisplay()
        }
    }
}

// MARK: - Layout

extension QuickRepliesView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        // Separator Top
        
        separatorTopView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: separatorTopStroke)
        
        // listViews
        
        let containerTop = separatorTopView.frame.maxY
        let containerHeight = bounds.height - containerTop
        containerView.frame = CGRect(x: 0, y: containerTop, width: bounds.width, height: containerHeight)
        
        restartButton.frame = CGRect(x: 0, y: containerView.frame.maxY - restartButton.defaultHeight, width: bounds.width, height: restartButton.defaultHeight)
        
        if !animating {
            updateListViewFrames()
        }
    }
    
    func preferredDisplayHeight() -> CGFloat {
        if isCollapsed {
            return 0
        }
        
        if listViews.isEmpty || listViews[currentViewIndex].quickReplies?.isEmpty == true {
            return restartButton.defaultHeight
        }
        
        let rowHeight = QuickRepliesListView.approximateRowHeight()
        let restartButtonHeight = isRestartButtonVisible ? restartButton.defaultHeight : 0
        return restartButtonHeight + rowHeight * 3.25
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
}

// MARK: - Instance Methods

extension QuickRepliesView {
  
    private func createQuickRepliesListView(with message: ChatMessage) -> QuickRepliesListView {
        let listView = QuickRepliesListView()
        listView.message = message
        listView.onQuickReplySelected = { [weak self] (quickReply) in
            if let strongSelf = self,
               let delegate = strongSelf.delegate {
                return delegate.quickRepliesView(strongSelf, didSelect: quickReply, from: message)
            }
            return false
        }
        containerView.addSubview(listView)
        listViews.append(listView)
        updateListViewFrames()
        
        return listView
    }
    
    private func goToPreviousListView() {
        if listViews.count > 1 && currentViewIndex > 0 {
            currentViewIndex -= 1
            
            let viewToRemove = self.listViews.last
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: {
                self.updateListViewFrames()
                self.listViews.removeLast()
            }, completion: { [weak self] _ in
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
            UIView.animate(withDuration: 0.3, delay: 0.0, options: UIViewAnimationOptions(), animations: { [weak self] in
                self?.updateListViewFrames()
            }, completion: { [weak self] _ in
                self?.animating = false
                listView.flashScrollIndicatorsIfNecessary()
                for previousView in (self?.listViews ?? []) where previousView != listView {
                    previousView.clearSelection()
                }
            })
        } else {
            updateListViewFrames()
            listView.flashScrollIndicatorsIfNecessary()
        }
    }
    
    func disableCurrentButtons() {
        guard let currentView = listViews.last else {
            return
        }
        
        currentView.selectionDisabled = true
    }
    
    func reloadButtons(for message: ChatMessage) {
        for listView in listViews
        where listView.message?.metadata.eventId == message.metadata.eventId {
            listView.message = message
            break
        }
    }
    
    func clear() {
        for view in listViews {
            view.message = nil
            view.removeFromSuperview()
        }
        listViews.removeAll()
        currentViewIndex = 0
        separatorTopView.alpha = 1
    }
    
    func deselectCurrentSelection(animated: Bool) {
        if let currentView = listViews.last {
            currentView.deselectButtonSelection(animated: animated)
        }
    }
    
    func showRestartActionButton(animated: Bool) {
        clear()
        
        if animated {
            animating = true
            UIView.animate(withDuration: 0.3, delay: 0, options: UIViewAnimationOptions(), animations: { [weak self] in
                self?.separatorTopView.alpha = 1
                self?.isRestartButtonVisible = true
                self?.setNeedsLayout()
                self?.layoutIfNeeded()
                self?.updateListViewFrames()
            }, completion: { [weak self] _ in
                self?.animating = false
            })
        } else {
            separatorTopView.alpha = 1
            isRestartButtonVisible = true
            setNeedsLayout()
            layoutIfNeeded()
            updateListViewFrames()
        }
    }
}
