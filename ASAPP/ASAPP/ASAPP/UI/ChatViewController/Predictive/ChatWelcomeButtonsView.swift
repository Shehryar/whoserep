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
    
    let styles: ASAPPStyles
    
    private var buttons = [Button]()
    
    private let buttonSpacing: CGFloat = 10
    
    private var animating = false
    
    // MARK: Initialization
    
    required init(styles: ASAPPStyles?) {
        self.styles = styles ?? ASAPPStyles()
        super.init(frame: CGRectZero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View Creation
    
    func newButton(title: String) -> Button {
        let button = Button()
        button.contentInset = UIEdgeInsets(top: 15, left: 20, bottom: 15, right: 20)
        button.setForegroundColor(Colors.whiteColor(), forState: .Normal)
        button.setForegroundColor(Colors.whiteColor(), forState: .Highlighted)
        button.setBackgroundColor(Colors.marbleLightColor().colorWithAlphaComponent(0.2), forState: .Normal)
        button.setBackgroundColor(Colors.marbleLightColor().colorWithAlphaComponent(0.5), forState: .Highlighted)
        button.font = Fonts.latoRegularFont(withSize: 15)
        button.layer.cornerRadius = 18.0
        button.clipsToBounds = true
        button.title = title
        button.onTap = { [weak self] in
            self?.onButtonTap?(buttonTitle: title)
        }
        
        return button
    }
    
    // MARK: Layout
    
    func updateFrames() {
        let maxWidth = CGRectGetWidth(bounds)
        
        var buttonTop: CGFloat = 0.0
        for button in buttons {
            let buttonSize = button.sizeThatFits(CGSize(width: maxWidth, height: 0))
            button.frame = CGRect(x: 0, y: buttonTop, width: ceil(buttonSize.width), height: ceil(buttonSize.height))
            buttonTop = CGRectGetMaxY(button.frame) + buttonSpacing
        }
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        if !animating {
            updateFrames()
        }
    }
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        var height: CGFloat = 0.0
        for button in buttons {
            height += ceil(button.sizeThatFits(CGSize(width: size.width, height: 0)).height)
            if button != buttons.last {
                height += buttonSpacing
            }
        }
        
        return CGSize(width: size.width, height: height)
    }
    
    // MARK:- Public Instance Methods
    
    func setButtonTitles(buttonTitles: [String]?, hideButtonsForAnimation: Bool = false) {
        for button in buttons {
            button.removeFromSuperview()
        }
        buttons.removeAll()
        
        if let buttonTitles = buttonTitles {
            for buttonTitle in buttonTitles {
                let button = newButton(buttonTitle)
                if hideButtonsForAnimation {
                    button.alpha = 0.0
                }
                addSubview(button)
                buttons.append(button)
            }
        }
        
        setNeedsLayout()
    }
    
    func animateButtonsIn(completion: (() -> Void)? = nil) {
        guard let firstButton = buttons.first else { return }
        guard firstButton.alpha == 0 else { return }
        
        updateFrames()
        
        animating = true
        
        let verticalAdjustment: CGFloat = 20.0
        for button in buttons {
            button.center = CGPoint(x: button.center.x, y: button.center.y + verticalAdjustment)
        }
        
        var delay = 0.0
        let delayIncrement = 0.1
        let duration = 0.6
        for button in buttons {
            UIView.animateWithDuration(duration, delay: delay, options: .CurveEaseInOut, animations: { 
                
                button.alpha = 1.0
                button.center = CGPoint(x: button.center.x, y: button.center.y - verticalAdjustment)
                
                }, completion: { (completed) in
                    if button == self.buttons.last {
                        self.animating = false
                        self.setNeedsLayout()
                        completion?()
                    }
            })
            delay += delayIncrement
        }
    }
}
