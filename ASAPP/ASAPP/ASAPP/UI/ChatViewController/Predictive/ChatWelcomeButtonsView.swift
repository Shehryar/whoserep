//
//  ChatWelcomeButtonsView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatWelcomeButtonsView: UIView {

    var onButtonTap: ((buttonTitle: String) -> Void)?
    
    private(set) var buttonTitles: [String]?
    
    var expanded: Bool = true {
        didSet {
            updateSubviewAlphas()
            setNeedsLayout()
        }
    }
    
    var maxVisibleHeight: CGFloat? {
        didSet {
            updateSubviewAlphas()
        }
    }
    
    let styles: ASAPPStyles
    
    private var waitingToAnimateIn = false
    
    private var relatedButtons = [Button]()
    
    private let otherLabel = UILabel()
    
    private var otherButtons = [Button]()
    
    private let otherLabelMarginTop: CGFloat = 25
    
    private let otherLabelMarginBottom: CGFloat = 15
    
    private let buttonSpacing: CGFloat = 15
    
    private var animating = false
    
    // MARK: Initialization
    
    required init(styles: ASAPPStyles?) {
        self.styles = styles ?? ASAPPStyles()
        super.init(frame: CGRectZero)
        
        otherLabel.font = styles?.detailFont
        otherLabel.textColor = Colors.steelMed50Color()
        otherLabel.text = ASAPPLocalizedString("OTHER SUGGESTIONS:")
        addSubview(otherLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Creation
    
    func newButton(title: String, highlighted: Bool = false) -> Button {
        let button = Button()
        button.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.setForegroundColor(Colors.whiteColor(), forState: .Normal)
        button.setForegroundColor(Colors.whiteColor(), forState: .Highlighted)
        if highlighted {
            button.setBackgroundColor(Colors.marbleLightColor().colorWithAlphaComponent(0.35), forState: .Normal)
            button.setBackgroundColor(Colors.marbleLightColor().colorWithAlphaComponent(0.08), forState: .Highlighted)
        } else {
            button.setBackgroundColor(Colors.marbleLightColor().colorWithAlphaComponent(0.15), forState: .Normal)
            button.setBackgroundColor(Colors.marbleLightColor().colorWithAlphaComponent(0.08), forState: .Highlighted)
        }
        button.font = styles.bodyFont.fontWithSize(15)
        button.layer.cornerRadius = 18.0
        button.clipsToBounds = true
        button.title = title
        button.onTap = { [weak self] in
            self?.onButtonTap?(buttonTitle: title)
        }
        
        return button
    }
    
    // MARK: Layout
    
    func viewIsWithinVisibleHeight(view: UIView) -> Bool {
        guard let maxVisibleHeight = maxVisibleHeight else {
            return true
        }
        
        return CGRectGetMaxY(view.frame) < maxVisibleHeight
    }
    
    func updateSubviewAlphas() {
        guard !animating && !waitingToAnimateIn else { return }
        
        for view in subviews {
            if view == otherLabel {
                if expanded && viewIsWithinVisibleHeight(view) {
                    view.alpha = 1
                } else {
                    view.alpha = 0
                }
            } else {
                view.alpha = viewIsWithinVisibleHeight(view) ? 1 : 0
            }
        }
    }
    
    func updateFrames() {
        let maxWidth = CGRectGetWidth(bounds)
        let maxSubviewSize = CGSize(width: maxWidth, height: 0)
        
        var top: CGFloat = 0.0
        
        // Related Buttons
        
        for button in relatedButtons {
            let buttonSize = button.sizeThatFits(maxSubviewSize)
            button.frame = CGRect(x: 0, y: top, width: ceil(buttonSize.width), height: ceil(buttonSize.height))
            top = CGRectGetMaxY(button.frame) + buttonSpacing
        }
        
        // Section Header
        
        if expanded {
            top += otherLabelMarginTop
        }
        let otherLabelHeight = ceil(otherLabel.sizeThatFits(maxSubviewSize).height)
        otherLabel.frame = CGRect(x: 0, y: top, width: maxWidth, height: otherLabelHeight)
        
        if expanded {
            top = CGRectGetMaxY(otherLabel.frame) + otherLabelMarginBottom
        }
        
        // Other Buttons
        
        for button in otherButtons {
            let buttonSize = button.sizeThatFits(maxSubviewSize)
            button.frame = CGRect(x: 0, y: top, width: ceil(buttonSize.width), height: ceil(buttonSize.height))
            top = CGRectGetMaxY(button.frame) + buttonSpacing
        }
        
        updateSubviewAlphas()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !animating {
            updateFrames()
        }
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var height: CGFloat = 0.0
        
        let maxSubviewSize = CGSize(width: size.width, height: 0)
        
        // Related Buttons
        
        for button in relatedButtons {
            height += ceil(button.sizeThatFits(maxSubviewSize).height)
        }
        
        // Section Header
        
        if expanded {
            height += ceil(otherLabel.sizeThatFits(maxSubviewSize).height)
            height += otherLabelMarginTop + otherLabelMarginBottom
        }
        
        // Other Buttons
        
        for button in otherButtons {
            height += ceil(button.sizeThatFits(maxSubviewSize).height)
            if button != otherButtons.last {
                height += buttonSpacing
            }
        }
        
        return CGSize(width: size.width, height: height)
    }
    
    // MARK:- Public Instance Methods
    
    func setButtonTitles(buttonTitles: [String]?, highlightFirstButton: Bool, hideButtonsForAnimation: Bool = false) {
        if hideButtonsForAnimation {
            waitingToAnimateIn = true
        }
        
        for button in relatedButtons {
            button.removeFromSuperview()
        }
        relatedButtons.removeAll()
        
        for button in otherButtons {
            button.removeFromSuperview()
        }
        otherButtons.removeAll()
        
        if hideButtonsForAnimation {
            otherLabel.alpha = 0.0
        }
        
        if let buttonTitles = buttonTitles {
            for buttonTitle in buttonTitles {
                let isRelatedButton = buttonTitle == buttonTitles.first && highlightFirstButton
                let button = newButton(buttonTitle, highlighted: isRelatedButton)
                if hideButtonsForAnimation {
                    button.alpha = 0.0
                }
                addSubview(button)
                
                if isRelatedButton {
                    relatedButtons.append(button)
                } else {
                    otherButtons.append(button)
                }
            }
        }
        
        setNeedsLayout()
    }
    
    func animateButtonsIn(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard animated else {
            for button in relatedButtons {
                button.alpha = 1
            }
            otherLabel.alpha = 1
            for button in otherButtons {
                button.alpha = 1
            }
            waitingToAnimateIn = false
            completion?()
            return
        }
        
        updateFrames()
        
        animating = true
        
        let verticalAdjustment: CGFloat = 20.0
        for button in relatedButtons {
            button.center = CGPoint(x: button.center.x, y: button.center.y + verticalAdjustment)
        }
        otherLabel.center = CGPoint(x: otherLabel.center.x, y: otherLabel.center.y + verticalAdjustment)
        for button in otherButtons {
            button.center = CGPoint(x: button.center.x, y: button.center.y + verticalAdjustment)
        }
        
        var delay = 0.0
        let delayIncrement = 0.1
        let duration = 0.6
        
        func animateInView(view: UIView, delay: Double, animationCompletion: (() -> Void)?) {
            UIView.animateWithDuration(0.6,
                                       delay: delay,
                                       options: .CurveEaseOut,
                                       animations: {
                                        if self.viewIsWithinVisibleHeight(view) {
                                            view.alpha = 1
                                        }
                                        view.center = CGPoint(x: view.center.x, y: view.center.y - verticalAdjustment)
                }) { (completed) in
                    animationCompletion?()
            }
        }
        
        for button in relatedButtons {
            animateInView(button, delay: delay, animationCompletion: nil)
            delay += delayIncrement
        }
        
        animateInView(otherLabel, delay: delay, animationCompletion: nil)
        delay += delayIncrement
        
        for button in otherButtons {
            animateInView(button, delay: delay, animationCompletion: { 
                if button == self.otherButtons.last {
                    self.animating = false
                    self.waitingToAnimateIn = false
                    self.setNeedsLayout()
                    completion?()
                }
            })
            delay += delayIncrement
        }
    }
}
