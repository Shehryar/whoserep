//
//  TooltipContainerView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/16/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TooltipContainerView: UIView {
    
    var onTouch: (() -> Void)?
    
    // MARK: Initialization
    
    func commonInit() {
        backgroundColor = UIColor.clear
        isUserInteractionEnabled = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Touches
    
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        onTouch?()
        return false
    }
}
