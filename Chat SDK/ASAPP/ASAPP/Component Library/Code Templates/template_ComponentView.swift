//
//  template_ComponentView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentViewTemplate: UIView, ComponentView {

    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            
        }
    }
    
    // MARK: Init
    
    func commonInit() {
        
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }

    // MARK: Layout
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return .zero
    }
}
