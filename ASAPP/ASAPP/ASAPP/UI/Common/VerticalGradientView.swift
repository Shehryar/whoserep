//
//  VerticalGradientView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class VerticalGradientView: UIView {

    fileprivate(set) var topColor: UIColor?
    fileprivate(set) var middleColor: UIColor?
    fileprivate(set) var bottomColor: UIColor?
    
    fileprivate let gradientLayer = CAGradientLayer()
    
    // MARK: Initialization
    
    func commonInit() {
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
    
    func update(_ topColor: UIColor?, middleColor: UIColor? = nil, bottomColor: UIColor?) {
        self.topColor = topColor
        self.middleColor = middleColor
        self.bottomColor = bottomColor
        
        var gradientColors = [CGColor]()
        if let topColor = topColor {
            gradientColors.append(topColor.cgColor)
        }
        if let middleColor = middleColor {
            gradientColors.append(middleColor.cgColor)
        }
        if let bottomColor = bottomColor {
            gradientColors.append(bottomColor.cgColor)
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
