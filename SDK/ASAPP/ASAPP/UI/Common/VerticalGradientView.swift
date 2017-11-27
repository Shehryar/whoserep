//
//  VerticalGradientView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/7/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class VerticalGradientView: UIView {

    private(set) var colors: [UIColor]?
    
    private let gradientLayer = CAGradientLayer()
    
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
    
    func update(colors: [UIColor]?, locations: [CGFloat]? = nil) {
        self.colors = colors
        
        var gradientColors = [CGColor]()
        
        if let colors = colors {
            gradientColors = colors.map { $0.cgColor }
        }
        
        if gradientColors.count > 0 {
            gradientLayer.colors = gradientColors
        } else {
            gradientLayer.colors = nil
        }
        
        if let locations = locations as [NSNumber]? {
            gradientLayer.locations = locations
        }
    }
    
    // MARK: Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        gradientLayer.frame = bounds
    }
}
