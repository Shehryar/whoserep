//
//  BinaryRatingView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BinaryRatingView: BaseComponentView {
    private lazy var yesView = UIButton()
    private lazy var noView = UIButton()
    
    private var positiveValue = "1"
    private var negativeValue = "0"
    
    private var positiveText: String? {
        didSet {
            yesView.setTitle(positiveText, for: .normal)
        }
    }
    
    private var negativeText: String? {
        didSet {
            noView.setTitle(negativeText, for: .normal)
        }
    }
    
    private var isPositiveOnRight = false
    private var buttonSize: CGFloat = 40
    private var buttonSpacing: CGFloat = 40
    private var unselectedColor = UIColor(red: 0.8, green: 0.82, blue: 0.85, alpha: 1)
    private var yesColor = UIColor(red: 0.11, green: 0.65, blue: 0.43, alpha: 1)
    private var noColor = UIColor(red: 0.82, green: 0.11, blue: 0.26, alpha: 1)
    private var contentInset = UIEdgeInsets.zero
    
    private(set) var currentChoice: Bool? {
        didSet {
            if let choice = currentChoice {
                component?.value = choice ? positiveValue : negativeValue
            }
        }
    }
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            guard let item = binaryRatingItem else {
                return
            }
            
            positiveValue = item.positiveValue
            negativeValue = item.negativeValue
            
            positiveText = item.positiveText
            negativeText = item.negativeText
            
            if positiveText == nil && negativeText == nil {
                yesView.setImage(ComponentIcon.getImage(.thumbsUp), for: .normal)
                noView.setImage(ComponentIcon.getImage(.thumbsDown), for: .normal)
            }
            
            yesColor = item.positiveSelectedColor
            noColor = item.negativeSelectedColor
            
            isPositiveOnRight = item.isPositiveOnRight
            
            buttonSize = item.circleSize
            buttonSpacing = item.circleSpacing
            
            contentInset = item.style.padding
            
            setNeedsLayout()
        }
    }
    
    var binaryRatingItem: BinaryRatingItem? {
        return component as? BinaryRatingItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        clipsToBounds = false
        
        let font = ASAPP.styles.textStyles.header2.font.withSize(16)
        
        yesView.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        yesView.layer.cornerRadius = yesView.frame.width / 2
        yesView.setTitleColor(.white, for: .normal)
        yesView.titleLabel!.font = font
        yesView.titleLabel!.adjustsFontSizeToFitWidth = true
        yesView.titleLabel!.minimumScaleFactor = 0.2
        yesView.titleLabel!.numberOfLines = 1
        yesView.titleLabel!.baselineAdjustment = .alignCenters
        yesView.contentVerticalAlignment = .center
        yesView.isUserInteractionEnabled = false
        addSubview(yesView)
         
        noView.frame = CGRect(x: 0, y: 0, width: buttonSize, height: buttonSize)
        noView.layer.cornerRadius = noView.frame.width / 2
        noView.setTitleColor(.white, for: .normal)
        noView.titleLabel!.font = font
        noView.titleLabel!.adjustsFontSizeToFitWidth = true
        noView.titleLabel!.minimumScaleFactor = 0.2
        noView.titleLabel!.numberOfLines = 1
        noView.titleLabel!.baselineAdjustment = .alignCenters
        noView.contentVerticalAlignment = .center
        noView.isUserInteractionEnabled = false
        addSubview(noView)
    }
    
    // MARK: Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = buttonSize + contentInset.top + contentInset.bottom
        let width = 2 * buttonSize + buttonSpacing + contentInset.left + contentInset.right
        return CGSize(width: width, height: height)
    }
    
    override func updateFrames() {
        yesView.backgroundColor = yesColor
        noView.backgroundColor = noColor
        
        let totalWidth = 2 * buttonSize + buttonSpacing
        var contentLeft: CGFloat
        let alignment = component?.style.textAlign ?? .center
        switch alignment {
        case .center, .justified, .natural:
            let remainder = bounds.width - contentInset.left - contentInset.right - totalWidth
            contentLeft = max(0, remainder) / 2 + contentInset.left
        case .left:
            contentLeft = contentInset.left
        case .right:
            contentLeft = bounds.width - contentInset.right - totalWidth
        }
        
        let buttons = isPositiveOnRight ? [noView, yesView] : [yesView, noView]
        for button in buttons {
            guard button.transform.isIdentity else {
                contentLeft += buttonSize + buttonSpacing
                continue
            }
            
            button.frame = CGRect(x: contentLeft, y: contentInset.top, width: buttonSize, height: buttonSize)
            button.layer.cornerRadius = buttonSize / 2
            contentLeft = button.frame.maxX + buttonSpacing
        }
    }
}

// MARK: - Updating the choice

extension BinaryRatingView {
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
            animations: { [weak self] in
                self?.yesView.transform = getTransform(for: choice)
                self?.yesView.backgroundColor = getYesColor(for: choice)
                self?.noView.transform = getTransform(for: !choice)
                self?.noView.backgroundColor = getNoColor(for: !choice)
            }, completion: { _ in
                UIView.animate(
                    withDuration: 0.25,
                    delay: 0,
                    options: [.beginFromCurrentState, .curveEaseOut],
                    animations: { [weak self] in
                        self?.yesView.transform = CGAffineTransform.identity
                        self?.noView.transform = CGAffineTransform.identity
                    }, completion: nil)
        })
    }
}

// MARK: - Touches

extension BinaryRatingView {
    func getChoice(from location: CGPoint) -> Bool {
        return isPositiveOnRight
            ? location.x >= yesView.frame.minX - buttonSpacing / 2
            : location.x <= yesView.frame.maxX + buttonSpacing / 2
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
