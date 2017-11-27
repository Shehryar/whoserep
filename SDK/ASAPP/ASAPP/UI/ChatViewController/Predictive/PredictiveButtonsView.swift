//
//  PredictiveButtonsView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class PredictiveButtonsView: UIView {

    var onButtonTap: ((_ buttonTitle: String, _ isFromPrediction: Bool) -> Void)?
    
    private(set) var buttonTitles: [String]?
    
    var expanded: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    private var isChatStyle = false
    
    private var waitingToAnimateIn = false
    
    private var relatedButtons = [Button]()
    
    private let otherLabel = UILabel()
    
    private var otherButtons = [Button]()
    
    private let otherLabelMarginTop: CGFloat = 25
    
    private let otherLabelMarginBottom: CGFloat = 15
    
    private let buttonSpacing: CGFloat = 12
    
    private var animating = false
    
    private var shouldDisplayOtherLabel: Bool {
        return relatedButtons.count > 0 && otherButtons.count > 0 && expanded
    }
    
    private var buttonFont: UIFont {
        return isChatStyle ? ASAPP.styles.textStyles.bodyBoldItalic.font : ASAPP.styles.textStyles.body.font
    }
    
    // MARK: Initialization
    
    func commonInit() {
        otherLabel.setAttributedText(
            ASAPP.strings.predictiveOtherSuggestions,
            textType: .subheader,
            color: ASAPP.styles.colors.predictiveTextSecondary)
        otherLabel.alpha = 0.0
        addSubview(otherLabel)
    }
    
    required init() {
        super.init(frame: .zero)
        
        commonInit()
    }
    
    init(style: ASAPPWelcomeLayout) {
        super.init(frame: .zero)
        
        isChatStyle = (style == .chat)
        
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Display
    
    func updateDisplay() {
        otherLabel.setAttributedText(
            ASAPP.strings.predictiveOtherSuggestions,
            textType: .subheader,
            color: ASAPP.styles.colors.predictiveTextSecondary)
        
        for button in relatedButtons {
            button.font = buttonFont
        }
        
        for button in otherButtons {
            button.font = buttonFont
        }
        
        setNeedsLayout()
    }
    
    // MARK: View Creation
    
    func newButton(_ title: String, highlighted: Bool = false, isPrediction: Bool) -> Button {
        let button: Button
        switch ASAPP.styles.welcomeLayout {
        case .buttonMenu:
            button = Button()
            button.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        case .chat:
            button = BubbleButton()
            button.contentInset = UIEdgeInsets(top: 9, left: 20, bottom: 9, right: 20)
        }
        
        button.font = buttonFont
    
        let borderColor: UIColor?
        if highlighted {
            button.setForegroundColor(ASAPP.styles.colors.predictiveButtonPrimary.textNormal, forState: .normal)
            button.setForegroundColor(ASAPP.styles.colors.predictiveButtonPrimary.textHighlighted, forState: .highlighted)
            button.setBackgroundColor(ASAPP.styles.colors.predictiveButtonPrimary.backgroundNormal, forState: .normal)
            button.setBackgroundColor(ASAPP.styles.colors.predictiveButtonPrimary.backgroundHighlighted, forState: .highlighted)
            borderColor = ASAPP.styles.colors.predictiveButtonPrimary.border
        } else {
            button.setForegroundColor(ASAPP.styles.colors.predictiveButtonSecondary.textNormal, forState: .normal)
            button.setForegroundColor(ASAPP.styles.colors.predictiveButtonSecondary.textHighlighted, forState: .highlighted)
            button.setBackgroundColor(ASAPP.styles.colors.predictiveButtonSecondary.backgroundNormal, forState: .normal)
            button.setBackgroundColor(ASAPP.styles.colors.predictiveButtonSecondary.backgroundHighlighted, forState: .highlighted)
            borderColor = ASAPP.styles.colors.predictiveButtonSecondary.border
        }
    
        switch ASAPP.styles.welcomeLayout {
        case .buttonMenu:
            if let borderColor = borderColor {
                button.layer.borderColor = borderColor.cgColor
                button.layer.borderWidth = 1.0
            } else {
                button.layer.borderColor = nil
                button.layer.borderWidth = 0
            }
            
            button.layer.cornerRadius = 18.0
            button.clipsToBounds = true
        case .chat:
            (button as! BubbleButton).bubble.strokeColor = borderColor
        }
        
        button.title = title
        button.onTap = { [weak self] in
            self?.onButtonTap?(title, isPrediction)
        }
        
        return button
    }
    
    // MARK: Layout
    
    func viewIsWithinVisibleHeight(_ view: UIView) -> Bool {
        return view.frame.maxY < bounds.size.height
    }
    
    func updateSubviewAlphas() {
        guard !waitingToAnimateIn else { return }
        
        for view in subviews {
            if view == otherLabel {
                if expanded && viewIsWithinVisibleHeight(view) {
                    if view == otherLabel {
                        view.alpha = shouldDisplayOtherLabel ? 1 : 0
                    } else {
                        view.alpha = 1
                    }
                } else {
                    view.alpha = 0
                }
            } else {
                view.alpha = viewIsWithinVisibleHeight(view) ? 1 : 0
            }
        }
    }
    
    func updateFrames() {
        let maxWidth = bounds.width
        let maxSubviewSize = CGSize(width: maxWidth, height: 0)
        
        var top: CGFloat = 0.0
        
        // Related Buttons
        
        for button in relatedButtons {
            let buttonSize = button.sizeThatFits(maxSubviewSize)
            let width = ceil(buttonSize.width)
            let x: CGFloat
            switch ASAPP.styles.welcomeLayout {
            case .buttonMenu:
                x = 0
            case .chat:
                x = maxWidth - width
            }
            button.frame = CGRect(x: x, y: top, width: width, height: ceil(buttonSize.height))
            top = button.frame.maxY + buttonSpacing
        }
        
        // Section Header
        
        if expanded && shouldDisplayOtherLabel {
            top += otherLabelMarginTop
        }
        let otherLabelHeight = ceil(otherLabel.sizeThatFits(maxSubviewSize).height)
        otherLabel.frame = CGRect(x: 0, y: top, width: maxWidth, height: otherLabelHeight)
        
        if expanded && shouldDisplayOtherLabel {
            top = otherLabel.frame.maxY + otherLabelMarginBottom
        }
        
        // Other Buttons
        
        for button in otherButtons {
            let buttonSize = button.sizeThatFits(maxSubviewSize)
            let width = ceil(buttonSize.width)
            let x: CGFloat
            switch ASAPP.styles.welcomeLayout {
            case .buttonMenu:
                x = 0
            case .chat:
                x = maxWidth - width
            }
            button.frame = CGRect(x: x, y: top, width: width, height: ceil(buttonSize.height))
            top = button.frame.maxY + buttonSpacing
        }
        
        if !waitingToAnimateIn {
            updateSubviewAlphas()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !animating {
            updateFrames()
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        var height: CGFloat = 0
        
        for button in relatedButtons {
            let buttonSize = button.sizeThatFits(size)
            height += ceil(buttonSize.height) + buttonSpacing
        }
        
        if expanded && shouldDisplayOtherLabel {
            height += otherLabelMarginTop
        }
        
        let otherLabelSize = otherLabel.sizeThatFits(size)
        if expanded && shouldDisplayOtherLabel {
            height += ceil(otherLabelSize.height) + otherLabelMarginBottom
        }
        
        for button in otherButtons {
            let buttonSize = button.sizeThatFits(size)
            height += ceil(buttonSize.height) + buttonSpacing
        }
        
        return CGSize(width: size.width, height: height)
    }
    
    // MARK: - Public Instance Methods
    
    func clear() {
        for button in relatedButtons {
            button.removeFromSuperview()
        }
        relatedButtons.removeAll()
        
        for button in otherButtons {
            button.removeFromSuperview()
        }
        otherButtons.removeAll()
        
        otherLabel.alpha = 0.0
    }
    
    func update(relatedButtonTitles: [String]?, otherButtonTitles: [String]?, hideButtonsForAnimation: Bool = false) {
        clear()
        
        if hideButtonsForAnimation {
            waitingToAnimateIn = true
        }
        
        // Add New Buttons
        
        if let buttonTitles = relatedButtonTitles {
            for buttonTitle in buttonTitles {
                let button = newButton(buttonTitle, highlighted: true, isPrediction: true)
                button.alpha = 0.0
                addSubview(button)
                relatedButtons.append(button)
            }
        }
        
        if let buttonTitles = otherButtonTitles {
            for buttonTitle in buttonTitles {
                let button = newButton(buttonTitle, highlighted: false, isPrediction: false)
                button.alpha = 0.0
                addSubview(button)
                otherButtons.append(button)
            }
        }
        
        if !hideButtonsForAnimation {
            animateButtonsIn(false)
        }
        
        setNeedsLayout()
    }
    
    func animateButtonsIn(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        guard animated else {
            for button in relatedButtons {
                button.alpha = 1
            }
            
            if shouldDisplayOtherLabel {
                otherLabel.alpha = 1.0
            } else {
                otherLabel.alpha = 0.0
            }
            
            for button in otherButtons {
                button.alpha = 1
            }
            waitingToAnimateIn = false
            completion?()
            return
        }
        
        updateFrames()
        animating = true
        waitingToAnimateIn = false
        
        // Get array of views to animate
        
        var viewsToAnimate = [UIView]()
        for view in relatedButtons { viewsToAnimate.append(view) }
        if shouldDisplayOtherLabel {
            viewsToAnimate.append(otherLabel)
        }
        for view in otherButtons { viewsToAnimate.append(view) }
        
        // Set initial center
        
        let verticalAdjustment: CGFloat = 20.0
        for view in viewsToAnimate {
            view.center = CGPoint(x: view.center.x, y: view.center.y + verticalAdjustment)
        }

        // Animate Views
        
        var delay = 0.0
        let delayIncrement = 0.1
        
        for view in viewsToAnimate {
            UIView.animate(
                withDuration: 0.6,
                delay: delay,
                options: .curveEaseOut,
            animations: {
                view.center = CGPoint(x: view.center.x, y: view.center.y - verticalAdjustment)
                if self.viewIsWithinVisibleHeight(view) {
                    view.alpha = 1
                }
            }, completion: { _ in
                if view == viewsToAnimate.last {
                    self.animating = false
                    
                    self.setNeedsLayout()
                    completion?()
                }
            })
            delay += delayIncrement
        }
    }
}
