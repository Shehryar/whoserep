//
//  TouchPassThroughView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/10/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class TouchPassThroughView: UIView {
    
    let targetView: UIView
    
    required init(withTargetView targetView: UIView) {
        self.targetView = targetView
        super.init(frame: CGRect.zero)
        
        isUserInteractionEnabled = true
        backgroundColor = UIColor.clear
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Touches
    
    override func hitTest(_ point: CGPoint, with event: UIEvent?) -> UIView? {
        let hitView = super.hitTest(point, with: event)
        if hitView == self {
            return targetView.hitTest(point, with: event) ?? targetView
        }
        return hitView
    }
}
