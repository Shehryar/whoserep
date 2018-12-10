//
//  ScaleView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 4/23/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class RatingButton: UIButton {
    var value: Int = 0
    var scaleType: ScaleItem.ScaleType = .fiveNumber
    
    var preferredSize: CGSize {
        switch scaleType {
        case .fiveNumber:
            return CGSize(width: 44, height: 40)
        case .fiveStar:
            return CGSize(width: 39, height: 39)
        case .nrs11:
            return CGSize(width: UIView.minimumTargetLength, height: UIView.minimumTargetLength)
        }
    }
    
    func update(for value: Int, scaleType: ScaleItem.ScaleType) {
        self.scaleType = scaleType
        self.value = value
        
        switch scaleType {
        case .fiveNumber:
            backgroundColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
            setTitleColor(ASAPP.styles.colors.dark, for: .normal)
            setTitle(String(value), for: .normal)
            titleLabel?.updateFont(for: .body)
            layer.cornerRadius = 3
            setImage(nil, for: .normal)
        case .fiveStar:
            backgroundColor = .clear
            setTitle(nil, for: .normal)
            setImage(ComponentIcon.getImage(.ratingStar)?.tinted(ASAPP.styles.colors.dark, alpha: 0.15), for: .normal)
        case .nrs11:
            backgroundColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
            setTitleColor(ASAPP.styles.colors.dark, for: .normal)
            setTitle(String(value), for: .normal)
            titleLabel?.updateFont(for: .body)
            layer.cornerRadius = layer.frame.height / 2
            setImage(nil, for: .normal)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            switch scaleType {
            case .fiveNumber:
                if isSelected {
                    backgroundColor = ASAPP.styles.colors.primary
                    setTitleColor(backgroundColor?.chooseFirstAcceptableColor(of: [.white, ASAPP.styles.colors.dark]), for: .normal)
                    setTitleShadow(color: .black, offset: CGSize(width: 0, height: 2), radius: 4, opacity: 0.2)
                } else {
                    backgroundColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
                    setTitleColor(ASAPP.styles.colors.dark, for: .normal)
                    setTitleShadow(opacity: 0)
                }
            case .fiveStar:
                if isSelected {
                    setImage(ComponentIcon.getImage(.ratingStar)?.tinted(ASAPP.styles.colors.primary, alpha: 1), for: .normal)
                } else {
                    setImage(ComponentIcon.getImage(.ratingStar)?.tinted(ASAPP.styles.colors.dark, alpha: 0.15), for: .normal)
                }
            case .nrs11:
                if isSelected {
                    backgroundColor = ASAPP.styles.colors.primary
                    setTitleColor(backgroundColor?.chooseFirstAcceptableColor(of: [.white, ASAPP.styles.colors.dark]), for: .normal)
                } else {
                    backgroundColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
                    setTitleColor(ASAPP.styles.colors.dark, for: .normal)
                }
            }
        }
    }
}

class ScaleView: BaseComponentView {
    var buttonsByValue = [Int: RatingButton]()
    
    private var currentSelection: RatingButton?
    private var scaleType: ScaleItem.ScaleType = .fiveNumber
    private let tapDebouncer = Debouncer(interval: .defaultAnimationDuration)
    private(set) var gestureRecognizer: UIGestureRecognizer?
    private var recognizerStateDidChange = false
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            scaleType = (component as? ScaleItem)?.scaleType ?? .fiveNumber
            forEachButton { value, _ in
                let button = RatingButton()
                button.clipsToBounds = true
                buttonsByValue[value] = button
                addSubview(button)
                updateAccessibilityElements(button)
            }
            updateButtons()
            setNeedsLayout()
        }
    }
    
    var scaleItem: ScaleItem? {
        return component as? ScaleItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        clipsToBounds = true
        isAccessibilityElement = false
        configureAccessibility()
        
        let press = UILongPressGestureRecognizer(target: self, action: #selector(didPress))
        press.minimumPressDuration = 0
        addGestureRecognizer(press)
        gestureRecognizer = press
    }
    
    private func configureAccessibility() {
        accessibilityElements = []
    }
    
    private func updateAccessibilityElements(_ button: UIButton) {
        accessibilityElements?.append(button)
    }
    
    private func updateButtons() {
        for (value, button) in buttonsByValue {
            button.update(for: value, scaleType: scaleType)
        }
    }
    
    var numButtons: Int {
        switch scaleType {
        case .fiveNumber, .fiveStar:
            return 5
        case .nrs11:
            return 11
        }
    }
    
    private func forEachButton(_ handler: (_ value: Int, _ index: Int) -> Void) {
        let min: Int
        switch scaleType {
        case .fiveNumber, .fiveStar:
            min = 1
        case .nrs11:
            min = 0
        }
        
        let max = min + numButtons - 1
        
        for (index, value) in (min...max).enumerated() {
            handler(value, index)
        }
    }
    
    // MARK: Layout
    
    private struct CalculatedLayout {
        let buttonFrames: [CGRect]
    }
    
    private func getFramesThatFit(_ size: CGSize) -> CalculatedLayout {
        guard let scaleItem = scaleItem else {
            return CalculatedLayout(buttonFrames: [])
        }
        let padding = scaleItem.style.padding
        
        // Max content size
        var maxContentSize = size
        if maxContentSize.width == 0 {
            maxContentSize.width = CGFloat.greatestFiniteMagnitude
        }
        if maxContentSize.height == 0 {
            maxContentSize.height = CGFloat.greatestFiniteMagnitude
        }
        maxContentSize.width -= padding.left + padding.right
        maxContentSize.height -= padding.top + padding.bottom
        
        var buttonFrames: [CGRect] = []
        let originalSize = buttonsByValue.first?.value.preferredSize ?? .zero
        let originalAspectRatio = originalSize.height / originalSize.width
        let buttonWidth: CGFloat
        let buttonSize: CGSize
        let buttonSpacing: CGFloat
        
        if scaleItem.style.alignment == .fill {
            let bestSpacing = (maxContentSize.width - CGFloat(numButtons) * originalSize.width) / CGFloat(numButtons - 1)
            buttonSpacing = max(1, bestSpacing)
        } else {
            switch scaleType {
            case .fiveNumber:
                buttonSpacing = 15
            case .fiveStar:
                buttonSpacing = 20
            case .nrs11:
                buttonSpacing = 1
            }
        }
        
        let maxButtonWidth = (maxContentSize.width - CGFloat(numButtons - 1) * buttonSpacing) / CGFloat(numButtons)
        buttonWidth = min(maxButtonWidth, originalSize.width)
        buttonSize = CGSize(width: buttonWidth, height: originalAspectRatio * buttonWidth)
        let contentWidth = buttonWidth * CGFloat(numButtons) + buttonSpacing * CGFloat(numButtons - 1)
        let offset = scaleItem.style.alignment != .fill ? (maxContentSize.width - contentWidth) / 2 : 0
        
        forEachButton { _, i in
            let left = padding.left + offset + CGFloat(i) * (buttonSize.width + buttonSpacing)
            buttonFrames.append(CGRect(x: left, y: padding.top, width: buttonSize.width, height: buttonSize.height))
        }
        
        return CalculatedLayout(buttonFrames: buttonFrames)
    }
    
    override func updateFrames() {
        let layout = getFramesThatFit(bounds.size)
        forEachButton { value, i in
            guard let button = buttonsByValue[value] else { return }
            button.frame = layout.buttonFrames[i]
            button.update(for: value, scaleType: scaleType)
        }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let scaleItem = scaleItem else {
            return .zero
        }
        
        let layout = getFramesThatFit(size)
        if layout.buttonFrames.isEmpty {
            return .zero
        }
        
        let firstButton = layout.buttonFrames.first ?? .zero
        let padding = scaleItem.style.padding
        let height = firstButton.maxY + padding.bottom
        let width = (layout.buttonFrames.last?.maxX ?? 0) + padding.right
        
        return CGSize(width: width, height: height)
    }
    
    // MARK: - Actions
    
    private func clear() {
        forEachButton { (value, _) in
            buttonsByValue[value]?.isSelected = false
        }
        component?.value = nil
    }
    
    private func handleTap(_ sender: RatingButton, toggle: Bool = true) {
        if toggle {
            if currentSelection == sender {
                currentSelection = nil
            } else {
                currentSelection = sender
            }
        } else {
            currentSelection = sender
        }
        
        let compare: (Int, Int) -> Bool
        switch scaleType {
        case .fiveNumber:
            compare = (==)
        case .fiveStar, .nrs11:
            compare = (<=)
        }
        
        for button in buttonsByValue.values {
            if compare(button.value, currentSelection?.value ?? -1) {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
        
        component?.value = currentSelection?.value
    }
    
    func didTapButton(_ button: RatingButton, toggle: Bool) {
        tapDebouncer.debounce { [weak self] in
            self?.handleTap(button, toggle: toggle)
        }
    }
    
    @objc func didPress(recognizer: UIGestureRecognizer) {
        let point = recognizer.location(in: self)
        
        if scaleType != .fiveNumber && point.x <= 0 {
            clear()
            recognizerStateDidChange = false
            return
        }
        
        guard recognizer.gestureWas(in: self) else {
            recognizerStateDidChange = false
            return
        }
        
        if recognizer.state == .changed {
            recognizerStateDidChange = true
            forEachButton { value, _ in
                guard let button = buttonsByValue[value] else { return }
                if button.frame.contains(point) {
                    handleTap(button, toggle: false)
                }
            }
        } else if recognizer.state == .ended {
            forEachButton { value, _ in
                guard let button = buttonsByValue[value] else { return }
                if button.frame.contains(point) {
                    didTapButton(button, toggle: !recognizerStateDidChange)
                    recognizerStateDidChange = false
                }
            }
        }
    }
}
