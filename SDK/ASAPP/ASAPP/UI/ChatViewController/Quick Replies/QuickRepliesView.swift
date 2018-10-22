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
            listView.contentInsetBottom = 0
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
    
    let restartButton = RestartButton()
    
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
        updateRestartButtonDisplay()
    }
    
    func updateRestartButtonDisplay() {
        let quickRepliesAreCutOff = !listView.isEmpty && listView.getTotalHeight() > sizeThatFits(bounds.size).height - restartButton.frame.height
        if isRestartButtonVisible,
            containerView.alpha == 0 || quickRepliesAreCutOff {
            restartButton.showBlur()
        } else {
            restartButton.hideBlur()
        }
        restartButton.updateDisplay()
    }
}

// MARK: - Layout

extension QuickRepliesView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    private struct CalculatedLayout {
        let separatorTopViewFrame: CGRect
        let containerViewFrame: CGRect
        let listViewFrame: CGRect
        let blurredBackgroundFrame: CGRect
        let restartButtonFrame: CGRect
    }
    
    private func getFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        let separatorTopViewFrame = CGRect(x: 0, y: 0, width: size.width, height: separatorTopStroke)
        
        let containerTop = separatorTopViewFrame.maxY
        let containerHeight = size.height - containerTop
        let containerViewFrame = CGRect(x: 0, y: containerTop, width: size.width, height: containerHeight)
        
        let listViewSize = listView.sizeThatFits(containerViewFrame.size)
        let listViewFrame = CGRect(origin: .zero, size: listViewSize)
        
        // the blur effect looks bad when growing from nothing. make it larger than necessary while the container is short.
        let blurredBackgroundFrame = containerViewFrame.height > 5
            ? containerViewFrame
            : CGRect(x: containerView.frame.minX,
                     y: -restartButton.defaultHeight,
                     width: containerViewFrame.width,
                     height: restartButton.defaultHeight)
        
        let restartButtonFrame = CGRect(x: 0, y: containerViewFrame.maxY - restartButton.defaultHeight, width: size.width, height: restartButton.defaultHeight)
        
        return CalculatedLayout(
            separatorTopViewFrame: separatorTopViewFrame,
            containerViewFrame: containerViewFrame,
            listViewFrame: listViewFrame,
            blurredBackgroundFrame: blurredBackgroundFrame,
            restartButtonFrame: restartButtonFrame)
    }
    
    func updateFrames(in bounds: CGRect? = nil) {
        let bounds = bounds ?? self.bounds
        let layout = getFramesThatFit(bounds.size)
        
        separatorTopView.frame = layout.separatorTopViewFrame
        containerView.frame = layout.containerViewFrame
        listView.frame = layout.listViewFrame
        blurredBackground.frame = layout.blurredBackgroundFrame
        restartButton.frame = layout.restartButtonFrame
        
        listView.updateFrames(in: listView.bounds)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let restartButtonHeight = isRestartButtonVisible ? restartButton.defaultHeight : 0
        
        if listView.isEmpty {
            return CGSize(width: size.width, height: restartButtonHeight + 1)
        }
        
        let layout = getFramesThatFit(size)
        return CGSize(width: size.width, height: restartButtonHeight + layout.listViewFrame.height)
    }
    
    func sizeThatFills(_ size: CGSize) -> CGSize {
        let layout = getFramesThatFit(size)
        return CGSize(width: size.width, height: restartButton.defaultHeight + layout.listViewFrame.height)
    }
}

// MARK: - Instance Methods

extension QuickRepliesView {
  
    private func updateListView(with message: ChatMessage) {
        listView.update(for: message, shouldAnimateUp: true, animated: true)
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
            listView.update(for: message, shouldAnimateUp: false, animated: true)
        }
    }
    
    func disableAndClear() {
        listView.selectionDisabled = true
        listView.updateEnabled()
        clear(animated: true)
    }
    
    func clear(animated: Bool, completion: (() -> Void)? = nil) {
        listView.update(for: nil, shouldAnimateUp: false, animated: animated, completion: completion)
    }
    
    func showPrevious() {
        listView.showHidden()
    }
    
    func reset() {
        separatorTopView.alpha = 1
        containerView.alpha = 1
        blurredBackground.alpha = 1
    }
    
    func fadeOut(showRestartButton: Bool, animated: Bool) {
        listView.update(for: nil, shouldAnimateUp: true, animated: animated)
        
        blurredBackground.alpha = 0
        
        if animated {
            animating = true
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.separatorTopView.alpha = 0
                self?.containerView.alpha = 0
                self?.isRestartButtonVisible = showRestartButton
                self?.setNeedsLayout()
                self?.layoutIfNeeded()
            }, completion: { [weak self] _ in
                if showRestartButton {
                    self?.separatorTopView.alpha = 1
                }
                self?.animating = false
            })
        } else {
            separatorTopView.alpha = showRestartButton ? 1 : 0
            containerView.alpha = 0
            isRestartButtonVisible = showRestartButton
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
    
    func showBlur() {
        blurredBackground.isHidden = false
        backgroundColor = .clear
        
        updateRestartButtonDisplay()
        
        setNeedsDisplay()
    }
    
    func hideBlur() {
        blurredBackground.isHidden = true
        backgroundColor = .white
        
        if isRestartButtonVisible {
            restartButton.replaceBlur()
        }
        
        setNeedsDisplay()
    }
}

extension QuickRepliesView: QuickRepliesListViewDelegate {
    func quickRepliesListViewDidLayoutNewQuickReplies(_ quickRepliesListView: QuickRepliesListView) {
        updateRestartButtonDisplay()
    }
}
