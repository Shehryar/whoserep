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
    
    let component: Component
    
    // MARK: Init
    
    required init(component: Component) {
        self.component = component
        super.init(frame: .zero)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
}
