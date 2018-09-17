//
//  QuickRepliesListView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol QuickRepliesListViewDelegate: class {
    func quickRepliesListViewDidLayoutNewQuickReplies(_ quickRepliesListView: QuickRepliesListView)
}

class QuickRepliesListView: UIView {
    enum AnimationDirection {
        case `in`
        case out
    }
    
    weak var delegate: QuickRepliesListViewDelegate?
    
    var onQuickReplySelected: ((QuickReply) -> Bool)?
    
    var selectionDisabled: Bool = false
    
    var contentInsetBottom: CGFloat = 0 {
        didSet {
            scrollView.contentInset.bottom = contentInsetBottom
            let scrollInsets = scrollView.scrollIndicatorInsets
            scrollView.scrollIndicatorInsets = UIEdgeInsets(top: scrollInsets.top, left: scrollInsets.left, bottom: contentInsetBottom, right: scrollInsets.right)
        }
    }
    
    var contentInsetTop: CGFloat {
        return scrollView.contentInset.top
    }
    
    var isEmpty: Bool {
        return quickReplies?.isEmpty ?? true
    }
    
    private(set) var message: ChatMessage? {
        didSet {
            selectedQuickReply = nil
        }
    }
    
    private(set) var selectedQuickReply: QuickReply?
    
    private(set) var quickReplies: [QuickReply]?
    
    private let scrollView = UIScrollView()
    
    private var quickReplyViews: [QuickReplyView] = []
    
    private let initialDelay: TimeInterval = 0.3
    private let delayIncrement: TimeInterval = 0.2
    private let translationDuration: TimeInterval = 0.4
    private let initialFadeDuration: TimeInterval = 0.6
    private let fadeDurationIncrement: TimeInterval = 0.2
    
    // MARK: Initialization
    
    func commonInit() {
        scrollView.backgroundColor = .clear
        scrollView.scrollsToTop = false
        scrollView.alwaysBounceVertical = false
        scrollView.delegate = self
        scrollView.contentInset = UIEdgeInsets(top: QuickReplyView.contentInset.top * 5 - 1, left: 0, bottom: QuickReplyView.contentInset.bottom * 2, right: 0)
        addSubview(scrollView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: - Display
    
    func hideAll() {
        removeAll(animated: true) { [weak self] _ in
            self?.reset()
        }
    }
    
    func showHidden() {
        selectedQuickReply = nil
        selectionDisabled = false
        addAll(animated: false, shouldDelay: false)
    }
    
    func update(for message: ChatMessage?, animated: Bool, completion: (() -> Void)? = nil) {
        self.message = message
        quickReplies = message?.quickReplies
        removeAll(animated: animated, shouldAnimateUp: message != nil) { [weak self] delayNext in
            self?.addAll(animated: animated, shouldDelay: delayNext) { [weak self] in
                self?.reset()
                completion?()
            }
        }
    }
    
    func updateDisplay() {
        for i in quickReplyViews.indices {
            styleQuickReplyView(at: i)
        }
        
        setNeedsLayout()
    }
    
    func updateEnabled() {
        for i in quickReplyViews.indices {
            setQuickReplyViewEnabled(at: i, enabled: !selectionDisabled)
        }
        
        setNeedsLayout()
    }
    
    // MARK: - Layout
    
    func updateFrames(in bounds: CGRect) {
        frame = bounds
        updateDisplay()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        scrollView.frame = bounds
    }
    
    private func setQuickReplyViewEnabled(at index: Int, enabled: Bool) {
        guard index < quickReplyViews.count else {
            return
        }
        
        let view = quickReplyViews[index]
        setQuickReplyViewEnabled(view, enabled: enabled)
    }
    
    private func styleQuickReplyView(at index: Int) {
        guard index < quickReplies?.count ?? 0,
              let quickReply = quickReplies?[index] else {
            return
        }
        
        let view = quickReplyViews[index]
        styleQuickReplyView(view, for: quickReply)
    }
    
    private func styleQuickReplyView(_ view: QuickReplyView) {
        guard let index = quickReplyViews.index(of: view),
              let quickReply = quickReplies?[index] else {
            return
        }
        
        styleQuickReplyView(view, for: quickReply)
    }
    
    private func styleQuickReplyView(_ view: QuickReplyView, for quickReply: QuickReply) {
        let enabled = (selectedQuickReply == nil && !selectionDisabled) || selectedQuickReply == quickReply
        view.update(for: quickReply, enabled: enabled)
        view.frame = CGRect(origin: view.frame.origin, size: view.sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude)))
        view.setNeedsLayout()
    }
    
    private func setQuickReplyViewEnabled(_ view: QuickReplyView, enabled: Bool) {
        view.update(enabled: enabled)
        view.setNeedsLayout()
    }
    
    private func updateViewsAnimated(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3) { [weak self] in
                self?.updateDisplay()
            }
        } else {
            updateDisplay()
        }
    }
    
    func getTotalHeight() -> CGFloat {
        var total: CGFloat = 0
        
        for quickReply in quickReplies ?? [] {
            let view = QuickReplyView(frame: .zero)
            view.update(for: quickReply, enabled: true)
            let size = view.sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
            total += size.height
        }
        
        return total
    }
}

extension QuickRepliesListView {
    // MARK: - Animations
    
    func getTotalAnimationDuration(delay shouldDelay: Bool, direction: AnimationDirection) -> TimeInterval {
        let lastIndex = (quickReplyViews.count) - 1
        let delay = getDelay(initial: shouldDelay, at: lastIndex)
        let translationDuration = getTranslationDuration(direction: direction)
        return delay + translationDuration
    }
    
    private func getDelay(initial: Bool, at index: Int) -> TimeInterval {
        return (initial ? initialDelay : 0) + delayIncrement * Double(index)
    }
    
    private func getFadeDuration(at index: Int, direction: AnimationDirection) -> TimeInterval {
        return ((direction == .in ? 1 : 0.5) * initialFadeDuration) + Double(index) * fadeDurationIncrement
    }
    
    private func getTranslationDuration(direction: AnimationDirection) -> TimeInterval {
        return (direction == .in ? 1 : 0.5) * translationDuration
    }
    
    private func getTranslationOffset(for view: QuickReplyView) -> CGFloat {
        return view.buttonMinHeight * 0.75
    }
    
    private func removeAll(animated: Bool, shouldAnimateUp: Bool = true, _ completion: ((_ delayNext: Bool) -> Void)? = nil) {
        guard !quickReplyViews.isEmpty else {
            completion?(true)
            return
        }
        
        guard animated else {
            quickReplyViews.forEach { $0.removeFromSuperview() }
            quickReplyViews = []
            scrollView.setNeedsLayout()
            scrollView.layoutIfNeeded()
            scrollView.setNeedsDisplay()
            completion?(false)
            return
        }
        
        var views = quickReplyViews.filter({
            $0.frame.minY < bounds.maxY || $0.frame.maxY > bounds.minY
        })
        
        if !shouldAnimateUp {
            views = views.reversed()
        }
        
        for (i, view) in views.enumerated() {
            let oper: (CGFloat, CGFloat) -> CGFloat = shouldAnimateUp ? (-) : (+)
            let targetY = oper(view.center.y, getTranslationOffset(for: view))
            let delay = getDelay(initial: false, at: i)
            let fadeDuration = getFadeDuration(at: i, direction: .out)
            let translationDuration = getTranslationDuration(direction: .out)
            
            // fade and translation durations are intentionally swapped
            UIView.animate(withDuration: fadeDuration, delay: delay, options: .curveEaseInOut, animations: {
                view.center.y = targetY
                view.setNeedsLayout()
            })
            
            UIView.animate(withDuration: translationDuration, delay: delay, options: .curveEaseInOut, animations: {
                view.alpha = 0
                view.setNeedsLayout()
            })
        }
        
        Dispatcher.delay(.seconds(getTotalAnimationDuration(delay: false, direction: .out))) { [weak self] in
            self?.quickReplyViews = []
            self?.scrollView.setNeedsLayout()
            self?.scrollView.layoutIfNeeded()
            self?.scrollView.setNeedsDisplay()
            completion?(false)
        }
    }
    
    private func addAll(animated: Bool, shouldDelay: Bool, _ completion: (() -> Void)? = nil) {
        scrollView.subviews.forEach { view in
            (view as? QuickReplyView)?.removeFromSuperview()
        }
        scrollView.contentOffset = CGPoint(x: 0, y: -scrollView.contentInset.top)
        scrollView.setNeedsLayout()
        scrollView.layoutIfNeeded()
        
        guard let quickReplies = quickReplies else {
            completion?()
            return
        }
        
        var totalHeight: CGFloat = 0
        
        for (i, quickReply) in quickReplies.enumerated() {
            let view = QuickReplyView(frame: .zero)
            view.delegate = self
            view.gestureRecognizer?.delegate = self
            view.update(for: quickReply, enabled: true)
            
            let size = view.sizeThatFits(CGSize(width: bounds.width, height: .greatestFiniteMagnitude))
            let startOffset = animated ? getTranslationOffset(for: view) : 0
            view.frame = CGRect(x: 0, y: totalHeight + startOffset, width: size.width, height: size.height)
            
            totalHeight += size.height
            let endY = view.center.y - startOffset
            
            quickReplyViews.append(view)
            scrollView.addSubview(view)
            
            guard animated else {
                continue
            }
            
            view.alpha = 0
            view.setNeedsLayout()
            view.layoutIfNeeded()
            
            let delay = getDelay(initial: shouldDelay, at: i)
            let fadeDuration = getFadeDuration(at: i, direction: .in)
            let translationDuration = getTranslationDuration(direction: .in)
            
            UIView.animate(withDuration: translationDuration, delay: delay, options: .curveEaseInOut, animations: {
                view.center.y = endY
                view.setNeedsLayout()
            })
            
            UIView.animate(withDuration: fadeDuration, delay: delay, options: .curveEaseInOut, animations: {
                view.alpha = 1
                view.setNeedsLayout()
            })
        }
        
        scrollView.contentSize = CGSize(width: bounds.width, height: totalHeight)
        
        delegate?.quickRepliesListViewDidLayoutNewQuickReplies(self)
        
        guard animated else {
            completion?()
            return
        }
        
        Dispatcher.delay(.seconds(getTotalAnimationDuration(delay: shouldDelay, direction: .in))) {
            completion?()
        }
    }
    
    private func reset() {
        selectionDisabled = false
    }
}

extension QuickRepliesListView: QuickReplyViewDelegate {
    func didTapQuickReplyView(_ quickReplyView: QuickReplyView) {
        guard selectedQuickReply == nil,
              !selectionDisabled,
              let index = quickReplyViews.index(of: quickReplyView),
              let quickReply = quickReplies?[index],
              let onQuickReplySelected = onQuickReplySelected else {
            return
        }
        
        selectedQuickReply = quickReply
        if !onQuickReplySelected(quickReply) {
            selectedQuickReply = nil
        }
        updateViewsAnimated(false)
        hideAll()
    }
}

extension QuickRepliesListView: UIGestureRecognizerDelegate {
    func gestureRecognizer(_ gestureRecognizer: UIGestureRecognizer, shouldRecognizeSimultaneouslyWith otherGestureRecognizer: UIGestureRecognizer) -> Bool {
        return true
    }
}

extension QuickRepliesListView: UIScrollViewDelegate {
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        for view in quickReplyViews {
            view.gestureRecognizer?.isEnabled = false
            view.gestureRecognizer?.isEnabled = true
            view.canBeHighlighted = false
            view.setHighlighted(false, animated: false)
        }
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView, willDecelerate decelerate: Bool) {
        for view in quickReplyViews {
            view.canBeHighlighted = true
        }
    }
}

// MARK: - Public Methods

extension QuickRepliesListView {
    func flashScrollIndicatorsIfNecessary() {
        if scrollView.contentSize.height > scrollView.bounds.height + 30 {
            Dispatcher.delay(.defaultAnimationDuration * 2) { [weak self] in
                self?.scrollView.flashScrollIndicators()
            }
        }
    }
    
    func deselectButtonSelection(animated: Bool) {
        if selectedQuickReply != nil {
            selectedQuickReply = nil
            updateViewsAnimated(animated)
        }
    }
    
    func clearSelection() {
        selectedQuickReply = nil
        selectionDisabled = false
        updateDisplay()
    }
    
    class func approximateRowHeight() -> CGFloat {
        return QuickReplyView.approximateHeight(with: ASAPP.styles.textStyles.body.font)
    }
}
