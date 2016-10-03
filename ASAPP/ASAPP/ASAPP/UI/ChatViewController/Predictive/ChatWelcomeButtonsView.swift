//
//  ChatWelcomeButtonsView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatWelcomeButtonsView: UIView {

    var onButtonTap: ((_ buttonTitle: String) -> Void)?
    
    fileprivate(set) var buttonTitles: [String]?
    
    var expanded: Bool = true {
        didSet {
            setNeedsLayout()
        }
    }
    
    let styles: ASAPPStyles
    
    fileprivate var waitingToAnimateIn = false
    
    fileprivate var relatedButtons = [Button]()
    
    fileprivate let otherLabel = UILabel()
    
    fileprivate var otherButtons = [Button]()
    
    fileprivate let otherLabelMarginTop: CGFloat = 25
    
    fileprivate let otherLabelMarginBottom: CGFloat = 15
    
    fileprivate let buttonSpacing: CGFloat = 15
    
    fileprivate var animating = false
    
    fileprivate var shouldDisplayOtherLabel: Bool {
        return relatedButtons.count > 0 && otherButtons.count > 0
    }
    
    // MARK: Initialization
    
    required init(styles: ASAPPStyles?) {
        self.styles = styles ?? ASAPPStyles()
        super.init(frame: CGRect.zero)
        
        otherLabel.font = styles?.detailFont
        otherLabel.textColor = Colors.steelMed50Color()
        otherLabel.attributedText = NSAttributedString(string: ASAPPLocalizedString("OTHER SUGGESTIONS:"),
                                                       attributes: [
                                                        NSFontAttributeName : self.styles.detailFont,
                                                        NSKernAttributeName : 1
            ])
        
        otherLabel.alpha = 0.0
        addSubview(otherLabel)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Creation
    
    func newButton(_ title: String, highlighted: Bool = false) -> Button {
        let button = Button()
        button.contentInset = UIEdgeInsets(top: 12, left: 20, bottom: 12, right: 20)
        button.setForegroundColor(Colors.whiteColor(), forState: .normal)
        button.setForegroundColor(Colors.whiteColor(), forState: .highlighted)
        if highlighted {
            button.setBackgroundColor(UIColor(red:0.492, green:0.513, blue:0.547, alpha:1), forState: .normal)
            button.setBackgroundColor(UIColor(red:0.492, green:0.513, blue:0.547, alpha:1).withAlphaComponent(0.5), forState: .highlighted)
        } else {
            button.setBackgroundColor(UIColor(red:0.444, green:0.462, blue:0.509, alpha:1), forState: .normal)
            button.setBackgroundColor(UIColor(red:0.444, green:0.462, blue:0.509, alpha:1).withAlphaComponent(0.5), forState: .highlighted)
        }
        button.font = styles.bodyFont.withSize(15)
        button.layer.cornerRadius = 18.0
        button.clipsToBounds = true
        button.title = title
        button.onTap = { [weak self] in
            self?.onButtonTap?(title)
        }
        
        return button
    }
    
    // MARK: Layout
    
    func viewIsWithinVisibleHeight(_ view: UIView) -> Bool {
        return view.frame.maxY < bounds.size.height
    }
    
    func updateSubviewAlphas() {
        guard !animating && !waitingToAnimateIn else { return }
        
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
            button.frame = CGRect(x: 0, y: top, width: ceil(buttonSize.width), height: ceil(buttonSize.height))
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
            button.frame = CGRect(x: 0, y: top, width: ceil(buttonSize.width), height: ceil(buttonSize.height))
            top = button.frame.maxY + buttonSpacing
        }
        
        if !animating && !waitingToAnimateIn {
            updateSubviewAlphas()
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !animating {
            updateFrames()
        }
    }
    
    // MARK:- Public Instance Methods
    
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
                let button = newButton(buttonTitle, highlighted: true)
                button.alpha = 0.0
                addSubview(button)
                relatedButtons.append(button)
            }
        }
        
        if let buttonTitles = otherButtonTitles {
            for buttonTitle in buttonTitles {
                let button = newButton(buttonTitle, highlighted: false)
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
            UIView.animate(withDuration: 0.6,
                           delay: delay,
                           options: .curveEaseOut,
                           animations: {
                            if self.viewIsWithinVisibleHeight(view) {
                                view.alpha = 1
                            }
                            view.center = CGPoint(x: view.center.x, y: view.center.y - verticalAdjustment)
            }) { (completed) in
                if view == viewsToAnimate.last {
                    self.animating = false
                    self.waitingToAnimateIn = false
                    self.setNeedsLayout()
                    completion?()
                }
            }
            delay += delayIncrement
        }
    }
}
