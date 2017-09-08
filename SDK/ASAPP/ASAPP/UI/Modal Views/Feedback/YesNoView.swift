//
//  YesNoView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/7/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class YesNoView: UIView {
    fileprivate(set) var currentChoice: Bool?
    
    fileprivate let contentInset = UIEdgeInsets.zero
    fileprivate let buttonSpacing: CGFloat = 50
    fileprivate let unselectedColor = UIColor(red: 0.8, green: 0.82, blue: 0.85, alpha:1)
    fileprivate let yesColor = UIColor(red: 0.11, green: 0.65, blue: 0.43, alpha: 1)
    fileprivate let noColor = UIColor(red: 0.82, green: 0.11, blue: 0.26, alpha: 1)
    
    fileprivate lazy var yesView = UIButton()
    fileprivate lazy var noView = UIButton()
    
    // MARK: Initialization
    
    func commonInit() {
        yesView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        yesView.layer.cornerRadius = yesView.frame.width / 2
        yesView.setTitleColor(.white, for: .normal)
        yesView.titleLabel!.font = ASAPP.styles.textStyles.header2.font
        yesView.isUserInteractionEnabled = false
        yesView.setTitle("YES", for: .normal)
        yesView.backgroundColor = yesColor
        addSubview(yesView)
        
        noView.frame = CGRect(x: 0, y: 0, width: 40, height: 40)
        noView.layer.cornerRadius = noView.frame.width / 2
        noView.setTitleColor(.white, for: .normal)
        noView.titleLabel!.font = ASAPP.styles.textStyles.header2.font
        noView.isUserInteractionEnabled = false
        noView.setTitle("NO", for: .normal)
        noView.backgroundColor = noColor
        addSubview(noView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // Mark: Layout
    
    func getButtonSizeThatFits(_ size: CGSize) -> CGSize {
        var buttonSize = size.width - contentInset.left - contentInset.right
        buttonSize -= buttonSpacing
        buttonSize /= 2
        
        if size.height > 0 {
            let maxButtonHeight = size.height - contentInset.top - contentInset.bottom
            buttonSize = floor(min(buttonSize, maxButtonHeight))
        }
        
        return CGSize(width: buttonSize, height: buttonSize)
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        updateFrames()
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let buttonSize = getButtonSizeThatFits(size)
        let height = buttonSize.height + contentInset.top + contentInset.bottom
        return CGSize(width: size.width, height: height)
    }
    
    func updateFrames() {
        let buttonSize = getButtonSizeThatFits(bounds.size)
        let horizontalRemainder = 2 * buttonSize.width - buttonSpacing
        var contentLeft = contentInset.left + horizontalRemainder / 2
        for button in [yesView, noView] {
            guard button.transform.isIdentity else {
                contentLeft += buttonSize.width + buttonSpacing
                continue
            }
            
            button.frame = CGRect(x: contentLeft, y: contentInset.top, width: buttonSize.width, height: buttonSize.height)
            button.layer.cornerRadius = buttonSize.width / 2
            contentLeft = button.frame.maxX + buttonSpacing
        }
    }
}

// MARK:- Updating the choice

extension YesNoView {
    func setChoice(_ choice: Bool, animated: Bool) {
        guard choice != currentChoice else {
            return
        }
        
        let oldChoice = currentChoice
        currentChoice = choice
        
        yesView.isEnabled = choice
        noView.isEnabled = !choice
        
        guard animated && oldChoice != choice else {
            return
        }
        
        func getTransform(for choice: Bool) -> CGAffineTransform {
            return choice ? CGAffineTransform(scaleX: 1.4, y: 1.4) : CGAffineTransform.identity
        }
        
        func getYesColor(for choice: Bool) -> UIColor {
            return choice ? yesColor : unselectedColor
        }
        
        func getNoColor(for choice: Bool) -> UIColor {
            return choice ? noColor : unselectedColor
        }
        
        UIView.animate(
            withDuration: 0.1,
            delay: 0,
            usingSpringWithDamping: 0.7,
            initialSpringVelocity: 20,
            options: .beginFromCurrentState,
            animations: {
                self.yesView.transform = getTransform(for: choice)
                self.yesView.backgroundColor = getYesColor(for: choice)
                self.noView.transform = getTransform(for: !choice)
                self.noView.backgroundColor = getNoColor(for: !choice)
            }, completion: { _ in
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    options: [.beginFromCurrentState, .curveEaseOut],
                    animations: {
                        self.yesView.transform = CGAffineTransform.identity
                        self.noView.transform = CGAffineTransform.identity
                    }, completion: nil)
            })
    }
}

// MARK: - Touches

extension YesNoView {
    func getChoice(from location: CGPoint) -> Bool {
        return location.x < yesView.frame.maxX
    }
    
    func updateChoice(for touches: Set<UITouch>) {
        guard let touch = touches.first else {
            return
        }
        
        let location = touch.location(in: self)
        let choice = getChoice(from: location)
        
        setChoice(choice, animated: true)
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateChoice(for: touches)
    }
    
    override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
        updateChoice(for: touches)
    }
}
