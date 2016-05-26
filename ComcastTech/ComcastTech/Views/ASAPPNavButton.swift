//
//  TopNavButton.swift
//  ComcastTech
//
//  Created by Vicky Sehrawat on 5/23/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ASAPPNavButton: UIButton {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    internal enum ASAPPButtonType: String {
        case Text, Image
    }
    
    var type: ASAPPButtonType!
    var viewController: UIViewController!
    let gradientLayer = CAGradientLayer()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        self.setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setup() {
        self.clipsToBounds = true
        
        self.backgroundColor = UIColor(red: 91/255, green: 101/255, blue: 126/255, alpha: 1)
        gradientLayer.frame = CGRectMake(0, 0, 300, 50)
        self.layer.addSublayer(gradientLayer)
        
        self.updateBackground()
    }
    
    func updateBackground() {
        let topColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.0).CGColor
        if self.selected {
            let bottomColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.3).CGColor
            gradientLayer.colors = [topColor, bottomColor]
            gradientLayer.locations = [0.0, 1.0]
        } else {
            gradientLayer.colors = [topColor, topColor]
            gradientLayer.locations = [0.0, 1.0]
        }
    }
    
}
