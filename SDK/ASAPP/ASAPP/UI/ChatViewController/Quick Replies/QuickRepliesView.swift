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
    
    var currentMessage: ChatMessage? {
        return listView.message
    }
    
    private var isRestartButtonVisible: Bool = false {
        didSet {
            restartButton.alpha = isRestartButtonVisible ? 1 : 0
            listView.contentInsetBottom = 0
            updateRestartButtonDisplay()
        }
    }
    
    var initialAnimationDuration: TimeInterval {
        return listView.getTotalAnimationDuration(delay: true, direction: .in)
    }
    
    private var contentHeight: CGFloat {
        return listView.contentInsetTop + listView.getTotalHeight()
    }
    
    private var contentInsetBottom: CGFloat = 0 {
        didSet {
            listView.contentInsetBottom = contentInsetBottom
        }
    }
    
    // MARK: Private Properties
    
    private let buttonSize: CGFloat = 34
    private let separatorTopStroke: CGFloat = 1
    private let listView = QuickRepliesListView()
    private var animating = false
    private var previousState: InputState?
    
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
        let containerHeight = size.height
        let containerViewFrame = CGRect(x: 0, y: 0, width: size.width, height: containerHeight)
        
        let listViewSize = listView.sizeThatFits(containerViewFrame.size)
        let listViewFrame = CGRect(x: 0, y: 0, width: listViewSize.width, height: listViewSize.height + contentInsetBottom)
        
        // the blur effect looks bad when growing from nothing. make it larger than necessary while the container is short.
        let blurredBackgroundFrame = containerViewFrame.height > 5
            ? containerViewFrame
            : CGRect(x: containerView.frame.minX,
                     y: -restartButton.defaultHeight,
                     width: containerViewFrame.width,
                     height: restartButton.defaultHeight)
        
        let restartButtonFrame = CGRect(x: 0, y: containerViewFrame.maxY - restartButton.defaultHeight, width: size.width, height: restartButton.defaultHeight)
        let separatorTop = containerView.frame.height == 0 ? restartButtonFrame.minY : 0
        let separatorTopViewFrame = CGRect(x: 0, y: separatorTop, width: size.width, height: separatorTopStroke)
        
        return CalculatedLayout(
            separatorTopViewFrame: separatorTopViewFrame,
            containerViewFrame: containerViewFrame,
            listViewFrame: listViewFrame,
            blurredBackgroundFrame: blurredBackgroundFrame,
            restartButtonFrame: restartButtonFrame)
    }
    
    private func updateFrames(in bounds: CGRect? = nil) {
        let bounds = bounds ?? self.bounds
        let layout = getFramesThatFit(bounds.size)
        
        separatorTopView.frame = layout.separatorTopViewFrame
        containerView.frame = layout.containerViewFrame
        listView.frame = layout.listViewFrame
        blurredBackground.frame = layout.blurredBackgroundFrame
        restartButton.frame = layout.restartButtonFrame
        
        listView.updateFrames(in: listView.bounds)
    }
    
    private func sizeThatFits(_ size: CGSize, withRestartButton: Bool) -> CGSize {
        let restartButtonHeight = withRestartButton ? restartButton.defaultHeight : 0
        
        if listView.isEmpty {
            return CGSize(width: size.width, height: restartButtonHeight)
        }
        
        let layout = getFramesThatFit(size)
        return CGSize(width: size.width, height: restartButtonHeight + layout.listViewFrame.height)
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return sizeThatFits(size, withRestartButton: isRestartButtonVisible)
    }
    
    func sizeThatFills(_ size: CGSize) -> CGSize {
        let layout = getFramesThatFit(size)
        return CGSize(width: size.width, height: restartButton.defaultHeight + layout.listViewFrame.height)
    }
    
    func contentsCanFitWith(_ inputHeight: CGFloat) -> Bool {
        if !isRestartButtonVisible && contentHeight < frame.height - inputHeight {
            return true
        }
        
        return false
    }
}

// MARK: - Public

extension QuickRepliesView {
    func prepare(for state: UIState, in bounds: CGRect) {
        let animated = state.animation == .needsToAnimate
        
        if ![.inset].contains(state.queryUI.input) {
            reset()
        }
        
        if [.chatInputWithQuickReplies, .quickRepliesAlone, .quickRepliesWithNewQuestion].contains(state.queryUI.input),
           let lastReply = state.lastReply {
            show(message: lastReply, animated: animated)
        } else if [.inset].contains(state.queryUI.input) {
            fadeOut(animated: animated)
        } else if ![.prechat].contains(state.queryUI.input) {
            let shouldAnimate = state.queryUI.input != .newQuestionAloneLoading
            clear(animated: shouldAnimate && animated)
        }
        
        if state.queryUI.input == .newQuestionAloneLoading {
            showRestartSpinner(animated: animated)
        } else {
            hideRestartSpinner(animated: animated)
        }
        
        if previousState?.isEmpty ?? true
           || previousState?.isEmpty == false && [.newQuestionWithInset].contains(state.queryUI.input) {
            let size = sizeThatFits(bounds.size, withRestartButton: state.queryUI.input.hasRestartButton)
            frame = CGRect(x: 0, y: bounds.maxY - size.height, width: size.width, height: size.height)
            updateFrames(in: bounds)
            layoutIfNeeded()
        }
    }
    
    func updateFrames(for inputState: InputState, in bounds: CGRect, with chatInputFrame: CGRect) {
        let quickRepliesHeight: CGFloat
        contentInsetBottom = 0
        
        switch inputState {
        case .empty, .prechat, .chatInput:
            isHidden = true
            isRestartButtonVisible = false
            quickRepliesHeight = 0
            separatorTopView.alpha = 0
            
        case .chatInputWithQuickReplies:
            isHidden = false
            isRestartButtonVisible = false
            let fittedHeight = sizeThatFits(bounds.size).height
            let inputHeight = chatInputFrame.height
            if contentHeight >= fittedHeight {
                contentInsetBottom = inputHeight
            }
            quickRepliesHeight = fittedHeight + inputHeight
            separatorTopView.alpha = 1
            
        case .quickRepliesWithNewQuestion, .newQuestionAlone,
             .newQuestionAloneLoading:
            isHidden = false
            isRestartButtonVisible = true
            quickRepliesHeight = sizeThatFits(bounds.size).height
            separatorTopView.alpha = 1
            
        case .newQuestionWithInset:
            isHidden = false
            isRestartButtonVisible = true
            quickRepliesHeight = frame.height
            containerView.alpha = 1
            separatorTopView.alpha = 1
            
        case .quickRepliesAlone:
            isHidden = false
            isRestartButtonVisible = false
            quickRepliesHeight = sizeThatFits(bounds.size).height
            separatorTopView.alpha = 1
            
        case .inset:
            isHidden = false
            isRestartButtonVisible = false
            quickRepliesHeight = frame.height
            separatorTopView.alpha = 0
            blurredBackground.alpha = 0
            containerView.alpha = 0
        }
        
        frame = CGRect(x: 0, y: bounds.maxY - quickRepliesHeight, width: bounds.width, height: quickRepliesHeight)
        updateFrames(in: bounds)
        layoutIfNeeded()
        previousState = inputState
    }
    
    func willTransition() {
        hideBlur()
    }
    
    func didTransition() {
        showBlur()
    }
}

// MARK: - Private Helpers

extension QuickRepliesView {
    private func updateListView(with message: ChatMessage, animated: Bool) {
        listView.update(for: message, shouldAnimateUp: true, animated: animated)
        listView.onQuickReplySelected = { [weak self] (quickReply) in
            if let strongSelf = self,
               let delegate = strongSelf.delegate {
                return delegate.quickRepliesView(strongSelf, didSelect: quickReply, from: message)
            }
            return false
        }
    }
    
    private func show(message: ChatMessage, animated: Bool) {
        guard message.quickReplies != nil,
              message != listView.message else {
            return
        }
        
        updateListView(with: message, animated: animated)
        listView.flashScrollIndicatorsIfNecessary()
    }
    
    private func reloadButtons(for message: ChatMessage) {
        if listView.message?.metadata.eventId == message.metadata.eventId {
            listView.update(for: message, shouldAnimateUp: false, animated: true)
        }
    }
    
    private func disableAndClear(animated: Bool) {
        listView.selectionDisabled = true
        listView.updateEnabled()
        clear(animated: animated)
    }
    
    private func clear(animated: Bool, completion: (() -> Void)? = nil) {
        listView.update(for: nil, shouldAnimateUp: false, animated: animated, completion: completion)
    }
    
    private func showPrevious() {
        listView.showHidden()
    }
    
    private func reset() {
        separatorTopView.alpha = 1
        containerView.alpha = 1
        blurredBackground.alpha = 1
    }
    
    private func fadeOut(animated: Bool) {
        listView.update(for: nil, shouldAnimateUp: true, animated: animated)
    }
    
    private func showRestartSpinner(animated: Bool) {
        disableAndClear(animated: animated)
        restartButton.showSpinner(animated: animated)
    }
    
    private func hideRestartSpinner(animated: Bool) {
        restartButton.hideSpinner(animated: animated)
    }
    
    private func showBlur() {
        blurredBackground.isHidden = false
        backgroundColor = .clear
        
        updateRestartButtonDisplay()
        
        setNeedsDisplay()
    }
    
    private func hideBlur() {
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
