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
    private var buttonSize: CGFloat = 56
    private var buttonSpacing: CGFloat = 32
    private var unselectedColor = UIColor(red: 0.89, green: 0.89, blue: 0.89, alpha: 1)
    private var yesColor = UIColor(red: 0.11, green: 0.65, blue: 0.43, alpha: 1)
    private var noColor = UIColor(red: 0.82, green: 0.11, blue: 0.26, alpha: 1)
    private var contentInset = UIEdgeInsets.zero
    private let animationDuration = 0.3
    
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
            
            yesColor = item.positiveSelectedColor
            noColor = item.negativeSelectedColor
            
            positiveText = item.positiveText
            negativeText = item.negativeText
            
            if positiveText == nil && negativeText == nil {
                let thumbsUp = ComponentIcon.getImage(.thumbsUp)
                let thumbsDown = ComponentIcon.getImage(.thumbsDown)
                yesView.setImage(thumbsUp?.tinted(yesColor), for: .normal)
                noView.setImage(thumbsDown?.tinted(noColor), for: .normal)
                yesView.setImage(thumbsUp, for: .highlighted)
                noView.setImage(thumbsDown, for: .highlighted)
            }
            
            isPositiveOnRight = item.isPositiveOnRight
            
            buttonSize = item.circleSize
            buttonSpacing = item.circleSpacing
            
            contentInset = item.style.padding
            
            setNeedsLayout()
            
            updateColors()
            updateBorderColors()
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
        
        for view in [yesView, noView] {
            view.titleLabel!.font = font
            view.titleLabel!.adjustsFontSizeToFitWidth = true
            view.titleLabel!.minimumScaleFactor = 0.2
            view.titleLabel!.numberOfLines = 1
            view.titleLabel!.baselineAdjustment = .alignCenters
            view.contentVerticalAlignment = .center
            view.isUserInteractionEnabled = false
            addSubview(view)
        }
        
        updateColors()
        updateBorderColors()
    }
    
    // MARK: Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        let height = buttonSize + contentInset.top + contentInset.bottom
        let width = 2 * buttonSize + buttonSpacing + contentInset.left + contentInset.right
        return CGSize(width: width, height: height)
    }
    
    override func updateFrames() {
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
        
        let borderWidth = buttonSize / 18.666
        let cornerRadius = buttonSize / 2
        let buttons = isPositiveOnRight ? [noView, yesView] : [yesView, noView]
        for button in buttons {
            button.frame = CGRect(x: contentLeft, y: contentInset.top, width: buttonSize, height: buttonSize)
            button.layer.cornerRadius = cornerRadius
            button.layer.borderWidth = borderWidth
            let inset = ceil(borderWidth)
            button.titleEdgeInsets = UIEdgeInsets(top: inset, left: inset, bottom: inset, right: inset)
            contentLeft = button.frame.maxX + buttonSpacing
        }
    }
    
    func updateColors() {
        if let choice = currentChoice {
            yesView.backgroundColor = choice ? yesColor : unselectedColor
            noView.backgroundColor = !choice ? noColor : unselectedColor
            yesView.setTitleColor(.white, for: .normal)
            noView.setTitleColor(.white, for: .normal)
        } else {
            yesView.layer.borderColor = yesColor.cgColor
            noView.layer.borderColor = noColor.cgColor
            yesView.backgroundColor = .clear
            noView.backgroundColor = .clear
            yesView.setTitleColor(yesColor, for: .normal)
            noView.setTitleColor(noColor, for: .normal)
        }
    }
    
    func animateBorderColors() {
        guard let choice = currentChoice else {
            return
        }
        
        let yesViewColor = choice ? yesColor : unselectedColor
        let noViewColor = !choice ? noColor : unselectedColor
        
        let yesColorAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.borderColor))
        yesColorAnimation.fromValue = yesView.layer.borderColor
        yesColorAnimation.toValue = yesViewColor.cgColor
        yesColorAnimation.duration = animationDuration
        yesColorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        let yesGroup = CAAnimationGroup()
        yesGroup.animations = [yesColorAnimation]
        yesGroup.beginTime = CACurrentMediaTime()
        yesGroup.isRemovedOnCompletion = true
        yesView.layer.add(yesGroup, forKey: nil)
        
        let noColorAnimation = CABasicAnimation(keyPath: #keyPath(CALayer.borderColor))
        noColorAnimation.fromValue = noView.layer.borderColor
        noColorAnimation.toValue = noViewColor.cgColor
        noColorAnimation.duration = animationDuration
        noColorAnimation.timingFunction = CAMediaTimingFunction(name: kCAMediaTimingFunctionEaseInEaseOut)
        let noGroup = CAAnimationGroup()
        noGroup.animations = [noColorAnimation]
        noGroup.beginTime = CACurrentMediaTime()
        noGroup.isRemovedOnCompletion = true
        noView.layer.add(noGroup, forKey: nil)
        
        updateBorderColors()
    }
    
    func updateBorderColors() {
        let yesViewColor = currentChoice ?? true ? yesColor : unselectedColor
        let noViewColor = !(currentChoice ?? false) ? noColor : unselectedColor
        
        yesView.layer.borderColor = yesViewColor.cgColor
        noView.layer.borderColor = noViewColor.cgColor
    }
}

// MARK: - Updating the choice

extension BinaryRatingView {
    func setChoice(_ choice: Bool, animated: Bool) {
        guard choice != currentChoice else {
            return
        }
        
        currentChoice = choice
        
        func updateStates() {
            yesView.isHighlighted = true
            noView.isHighlighted = true
        }
        
        if animated {
            animateBorderColors()
            UIView.animate(withDuration: animationDuration, delay: 0, options: .curveEaseInOut, animations: { [weak self] in
                updateStates()
                self?.updateFrames()
                self?.updateColors()
            })
        } else {
            updateStates()
            updateFrames()
            updateColors()
            updateBorderColors()
        }
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
