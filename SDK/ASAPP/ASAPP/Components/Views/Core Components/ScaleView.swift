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
        }
    }
    
    func update(for index: Int, scaleType: ScaleItem.ScaleType) {
        self.scaleType = scaleType
        value = index
        
        switch scaleType {
        case .fiveNumber:
            backgroundColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
            setTitleColor(ASAPP.styles.colors.dark, for: .normal)
            setTitle(String(index), for: .normal)
            titleLabel?.updateFont(for: .body)
            layer.cornerRadius = 3
            setImage(nil, for: .normal)
        case .fiveStar:
            backgroundColor = .clear
            setTitle(nil, for: .normal)
            setImage(ComponentIcon.getImage(.star)?.tinted(ASAPP.styles.colors.dark, alpha: 0.15), for: .normal)
        }
    }
    
    override var isSelected: Bool {
        didSet {
            switch scaleType {
            case .fiveNumber:
                if isSelected {
                    backgroundColor = ASAPP.styles.colors.primary
                    setTitleColor(.white, for: .normal)
                    setTitleShadow(color: .black, offset: CGSize(width: 0, height: 2), radius: 4, opacity: 0.2)
                } else {
                    backgroundColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
                    setTitleColor(ASAPP.styles.colors.dark, for: .normal)
                    setTitleShadow(opacity: 0)
                }
            case .fiveStar:
                if isSelected {
                    setImage(ComponentIcon.getImage(.star)?.tinted(ASAPP.styles.colors.primary, alpha: 1), for: .normal)
                } else {
                    setImage(ComponentIcon.getImage(.star)?.tinted(ASAPP.styles.colors.dark, alpha: 0.15), for: .normal)
                }
            }
        }
    }
}

class ScaleView: BaseComponentView {
    
    var buttonsByValue = [Int: RatingButton]()
    
    private var currentSelection: RatingButton?
    private let numButtons = 5
    private var scaleType: ScaleItem.ScaleType = .fiveNumber
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            scaleType = (component as? ScaleItem)?.scaleType ?? .fiveNumber
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
        
        for i in 1...numButtons {
            let button = RatingButton()
            button.clipsToBounds = true
            button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
            buttonsByValue[i] = button
            addSubview(button)
        }
        
        updateButtons()
    }
    
    private func updateButtons() {
        for (i, button) in buttonsByValue {
            button.update(for: i, scaleType: scaleType)
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
        let buttonSize: CGSize
        
        let buttonSpacing: CGFloat
        switch scaleType {
        case .fiveNumber:
            buttonSpacing = 15
        case .fiveStar:
            buttonSpacing = 20
        }
        
        let maxButtonWidth = (maxContentSize.width - buttonSpacing * CGFloat(numButtons - 1)) / CGFloat(numButtons)
        
        let originalSize = buttonsByValue.first?.value.preferredSize ?? .zero
        
        if originalSize.width > maxButtonWidth {
            buttonSize = CGSize(width: maxButtonWidth, height: (originalSize.height / originalSize.width) * maxButtonWidth)
        } else {
            buttonSize = originalSize
        }
        
        for i in 1...numButtons {
            let left = padding.left + CGFloat(i - 1) * (buttonSize.width + buttonSpacing)
            buttonFrames.append(CGRect(x: left, y: padding.top, width: buttonSize.width, height: buttonSize.height))
        }
        
        return CalculatedLayout(buttonFrames: buttonFrames)
    }
    
    override func updateFrames() {
        let layout = getFramesThatFit(bounds.size)
        for i in 1...numButtons {
            buttonsByValue[i]?.frame = layout.buttonFrames[i - 1]
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
    
    @objc func didTapButton(sender: RatingButton) {
        if currentSelection == sender {
            currentSelection = nil
        } else {
            currentSelection = sender
        }
        
        let compare: (Int, Int) -> Bool
        switch scaleType {
        case .fiveNumber:
            compare = (==)
        case .fiveStar:
            compare = (<=)
        }
        
        for button in buttonsByValue.values {
            if compare(button.value, currentSelection?.value ?? 0) {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
        
        component?.value = currentSelection?.value
    }
}
