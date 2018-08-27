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
    
    var eventId: Int? {
        return listView.message?.metadata.eventId
    }
    
    var currentMessage: ChatMessage? {
        return listView.message
    }
    
    var currentSRSClassification: String? {
        return currentMessage?.metadata.classification
    }
    
    var isRestartButtonVisible: Bool = false {
        didSet {
            restartButton.alpha = isRestartButtonVisible ? 1 : 0
            listView.contentInsetBottom = isRestartButtonVisible ? restartButton.defaultHeight : 0
            updateRestartButtonDisplay()
        }
    }
    
    var initialAnimationDuration: TimeInterval {
        return listView.getTotalAnimationDuration(delay: true, direction: .in)
    }
    
    var contentHeight: CGFloat {
        return listView.contentInsetTop + listView.getTotalHeight()
    }
    
    var contentInsetBottom: CGFloat = 0 {
        didSet {
            listView.contentInsetBottom = contentInsetBottom
        }
    }
    
    // MARK: Private Properties
    
    private let buttonSize: CGFloat = 34
    
    private let separatorTopStroke: CGFloat = 1
    
    private let listView = QuickRepliesListView()
    
    private var animating = false
    
    // MARK: UI Properties
    
    private let restartButton = RestartButton()
    
    private let separatorTopView = UIView()
    
    private let containerView = UIView()
    
    private let blurredBackground = UIVisualEffectView(effect: UIBlurEffect(style: .light))
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = .clear
        clipsToBounds = true
        
        addSubview(blurredBackground)
        
        listView.delegate = self
        containerView.addSubview(listView)
        
        addSubview(containerView)
        
        separatorTopView.backgroundColor = ASAPP.styles.colors.separatorSecondary
        addSubview(separatorTopView)
        
        restartButton.onTap = { [weak self] in
            if let strongSelf = self {
                strongSelf.delegate?.quickRepliesViewDidTapRestart(strongSelf)
            }
        }
        restartButton.alpha = isRestartButtonVisible ? 1 : 0
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
        listView.updateDisplay()
    }
    
    func updateRestartButtonDisplay() {
        if isRestartButtonVisible,
            !listView.isEmpty,
            listView.getTotalHeight() > containerView.frame.height - restartButton.defaultHeight {
            restartButton.showBlur()
        } else {
            restartButton.hideBlur()
        }
    }
}

// MARK: - Layout

extension QuickRepliesView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    func updateFrames() {
        // Separator Top
        
        separatorTopView.frame = CGRect(x: 0, y: 0, width: bounds.width, height: separatorTopStroke)
        
        // listViews
        
        let containerTop = separatorTopView.frame.maxY
        let containerHeight = bounds.height - containerTop
        containerView.frame = CGRect(x: 0, y: containerTop, width: bounds.width, height: containerHeight)
        listView.frame = containerView.bounds
        
        // the blur effect looks bad when growing from nothing. make it larger than necessary while the container is short.
        blurredBackground.frame = containerView.frame.height > 5 ? containerView.frame : CGRect(x: containerView.frame.minX, y: -restartButton.defaultHeight, width: containerView.frame.width, height: restartButton.defaultHeight)
        
        restartButton.frame = CGRect(x: 0, y: containerView.frame.maxY - restartButton.defaultHeight, width: bounds.width, height: restartButton.defaultHeight)
    }
    
    func preferredDisplayHeight() -> CGFloat {
        if listView.isEmpty {
            return isRestartButtonVisible ? restartButton.defaultHeight : 0
        }
        
        let rowHeight = QuickRepliesListView.approximateRowHeight()
        let restartButtonHeight = isRestartButtonVisible ? restartButton.defaultHeight : 0
        return restartButtonHeight + rowHeight * 3.55
    }
}

// MARK: - Instance Methods

extension QuickRepliesView {
  
    private func updateListView(with message: ChatMessage) {
        listView.update(for: message, animated: true)
        listView.onQuickReplySelected = { [weak self] (quickReply) in
            if let strongSelf = self,
               let delegate = strongSelf.delegate {
                return delegate.quickRepliesView(strongSelf, didSelect: quickReply, from: message)
            }
            return false
        }
    }
    
    // MARK: Public
    
    func show(message: ChatMessage, animated: Bool) {
        updateListView(with: message)
        listView.flashScrollIndicatorsIfNecessary()
    }
    
    func reloadButtons(for message: ChatMessage) {
        if listView.message?.metadata.eventId == message.metadata.eventId {
            listView.update(for: message, animated: true)
        }
    }
    
    func disableAndClear() {
        listView.selectionDisabled = true
        listView.updateEnabled()
        clear(animated: true)
    }
    
    func clear(animated: Bool, completion: (() -> Void)? = nil) {
        separatorTopView.alpha = 1
        listView.update(for: nil, animated: animated, completion: completion)
    }
    
    func showPrevious() {
        listView.showHidden()
    }
    
    func showRestartButtonAlone(animated: Bool) {
        clear(animated: animated)
        
        if animated {
            animating = true
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.separatorTopView.alpha = 1
                self?.isRestartButtonVisible = true
                self?.setNeedsLayout()
                self?.layoutIfNeeded()
            }, completion: { [weak self] _ in
                self?.animating = false
            })
        } else {
            separatorTopView.alpha = 1
            isRestartButtonVisible = true
            setNeedsLayout()
            layoutIfNeeded()
        }
    }
    
    func showRestartSpinner() {
        disableAndClear()
        restartButton.showSpinner()
    }
    
    func hideRestartSpinner() {
        restartButton.hideSpinner()
    }
}

extension QuickRepliesView: QuickRepliesListViewDelegate {
    func quickRepliesListViewDidLayoutNewQuickReplies(_ quickRepliesListView: QuickRepliesListView) {
        updateRestartButtonDisplay()
    }
}
