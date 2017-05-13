//
//  RadioButtonsContainerView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class RadioButtonsContainerView: _RootComponentWrapperView {
    
    // MARK: Properties
    
    override var component: Component? {
        didSet {
            if let radioButtonsContainerItem = component as? RadioButtonsContainerItem {
                rootView = radioButtonsContainerItem.root.createView()?.view
            } else {
                rootView = nil
            }
        }
    }
}
