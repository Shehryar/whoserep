//
//  SliderView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class SliderView: BaseComponentView {
    
    let sliderView = UISlider()
    
    let labelView = LabelView()
    
    // MARK: ComponentView Properties
    
    override var component: Component? {
        didSet {
            if let sliderItem = sliderItem {
                labelView.component = sliderItem.label
                
                sliderView.tintColor = sliderItem.style.color ?? ASAPP.styles.colors.controlTint
                sliderView.minimumValue = Float(sliderItem.minValue)
                sliderView.maximumValue = Float(sliderItem.maxValue)
                if let value = sliderItem.value as? Float {
                    sliderView.value = value
                } else {
                    sliderView.value = Float(sliderItem.minValue)
                }
                updateLabelText()
            } else {
                labelView.component = nil
            }
            setNeedsLayout()
        }
    }
    
    var sliderItem: SliderItem? {
        return component as? SliderItem
    }
    
    // MARK: Init
    
    override func commonInit() {
        super.commonInit()
        
        clipsToBounds = false
        
        addSubview(labelView)
        
        sliderView.addTarget(self,
                             action: #selector(SliderView.onValueChange),
                             for: .valueChanged)
        addSubview(sliderView)
    }
    
    // MARK: Layout
    
    func getFramesThatFit(_ size: CGSize) -> (CGRect, CGRect) {
        guard let sliderItem = sliderItem else {
            return (.zero, .zero)
        }
        let padding = sliderItem.style.padding
    
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
        
        // Label Frame
        let labelFrame: CGRect
        if let labelItem = sliderItem.label {
            let labelMargin = labelItem.style.margin
            let maxLabelWidth = maxContentSize.width - labelMargin.right - labelMargin.left
            var labelSize = labelView.sizeThatFits(CGSize(width: maxLabelWidth, height: 0))
            labelSize.width = ceil(labelSize.width)
            labelSize.height = ceil(labelSize.height)
            
            var labelLeft = padding.left + labelMargin.left
            switch labelItem.style.alignment {
            case .left:
                // No-op
                break
                
            case .center:
                labelLeft += floor((maxLabelWidth - labelSize.width) / 2.0)
                break
                
            case .right:
                labelLeft += maxLabelWidth - labelSize.width
                break
                
            case .fill:
                labelSize.width = maxLabelWidth
                break
            }
            
            let labelTop = padding.top + labelMargin.top
            labelFrame = CGRect(x: labelLeft, y: labelTop, width: labelSize.width, height: labelSize.height)
        } else {
            labelFrame = CGRect(x: padding.left, y: padding.top, width: 0, height: 0)
        }
        
        // Slider Frame
        let sliderTop: CGFloat
        if labelFrame.height > 0 {
            sliderTop = labelFrame.maxY + (sliderItem.label?.style.margin.bottom ?? 0)
        } else {
            sliderTop = padding.top
        }
        let sliderHeight = ceil(sliderView.sizeThatFits(CGSize(width: maxContentSize.width, height: 0)).height)
        let sliderFrame = CGRect(x: padding.left, y: sliderTop, width: maxContentSize.width, height: sliderHeight)
        
        
        return (labelFrame, sliderFrame)
    }
    
    override func updateFrames() {
        let (labelFrame, sliderFrame) = getFramesThatFit(bounds.size)
        sliderView.frame = sliderFrame
        labelView.frame = labelFrame
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        guard let sliderItem = sliderItem else {
            return .zero
        }
        
        let (_, sliderFrame) = getFramesThatFit(size)
        if sliderFrame.isEmpty {
            return .zero
        }
        
        let padding = sliderItem.style.padding
        let height = sliderFrame.maxY + padding.bottom
        
        return CGSize(width: size.width, height: height)
    }
    
    // MARK:- Actions
    
    func getCurrentValue() -> Int {
        return Int(round(sliderView.value))
    }
    
    func updateLabelText() {
        labelView.label.text = "\(getCurrentValue())"
        setNeedsLayout()
    }
    
    func onValueChange() {
        component?.value = getCurrentValue()
        updateLabelText()
    }
}
