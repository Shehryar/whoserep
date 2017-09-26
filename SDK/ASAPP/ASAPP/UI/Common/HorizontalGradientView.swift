//
//  HorizontalGradientView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class HorizontalGradientView: UIView {

    private(set) var leftColor: UIColor?
    private(set) var rightColor: UIColor?
    
    private let gradientLayer = CAGradientLayer()
    
    // MARK: Initialization
    
    func commonInit() {
        gradientLayer.startPoint = CGPoint(x: 0, y: 0.5)
        gradientLayer.endPoint = CGPoint(x: 1, y: 0.5)
        layer.addSublayer(gradientLayer)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Instance Methods
    
    func update(_ leftColor: UIColor?, middleColor: UIColor? = nil, rightColor: UIColor?) {
        self.leftColor = leftColor
        self.rightColor = rightColor
        
        var gradientColors = [CGColor]()
        if let leftColor = leftColor {
            gradientColors.append(leftColor.cgColor)
        }
        if let middleColor = middleColor {
            gradientColors.append(middleColor.cgColor)
        }
        if let rightColor = rightColor {
            gradientColors.append(rightColor.cgColor)
        }
        
        if gradientColors.count > 0 {
            gradientLayer.colors = gradientColors
        } else {
            gradientLayer.colors = nil
        }
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
