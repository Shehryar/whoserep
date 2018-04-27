//
//  ScaleView.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 4/23/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

class ScaleView: BaseComponentView {
    
    var buttonsByValue = [Int: UIButton]()
    
    private var currentSelection: UIButton?
    
    private let numButtons = 5
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
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
            let button = UIButton()
            button.backgroundColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
            button.setTitleColor(ASAPP.styles.colors.dark, for: .normal)
            button.setTitle(String(i), for: .normal)
            button.titleLabel?.updateFont(for: .body)
            button.clipsToBounds = true
            button.layer.cornerRadius = 3
            button.addTarget(self, action: #selector(didTapButton), for: .touchUpInside)
            buttonsByValue[i] = button
            addSubview(button)
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
        let buttonSpacing: CGFloat = 15
        let buttonWidth = (maxContentSize.width - buttonSpacing * CGFloat(numButtons - 1)) / CGFloat(numButtons)
        
        for i in 1...numButtons {
            let left = padding.left + CGFloat(i - 1) * (buttonWidth + buttonSpacing)
            buttonFrames.append(CGRect(x: left, y: padding.top, width: buttonWidth, height: buttonWidth))
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
        
        return CGSize(width: size.width, height: height)
    }
    
    // MARK: - Actions
    
    @objc func didTapButton(sender: UIButton) {
        if currentSelection == sender {
            currentSelection = nil
        } else {
            currentSelection = sender
        }
        
        var currentValue: Int?
        for (i, button) in buttonsByValue {
            if currentSelection == button {
                currentValue = i
                button.backgroundColor = ASAPP.styles.colors.primary
                button.setTitleColor(.white, for: .normal)
                button.setTitleShadow(color: .black, offset: CGSize(width: 0, height: 2), radius: 4, opacity: 0.2)
            } else {
                button.backgroundColor = ASAPP.styles.colors.dark.withAlphaComponent(0.15)
                button.setTitleColor(ASAPP.styles.colors.dark, for: .normal)
                button.setTitleShadow(opacity: 0)
            }
        }
        
        component?.value = currentValue
    }
}
