//
//  ComponentView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol InteractionHandler: class {
    
    func didTapButtonView(_ buttonView: ButtonView, with component: Component)
}

protocol ComponentView {
    
    var component: Component? { get set }
    
    weak var interactionHandler: InteractionHandler? { get set }
    
    var view: UIView { get }
}

extension ComponentView where Self: UIView {
        
    var view: UIView {
        return self
    }
    
    func findSubview(with id: String) -> UIView? {
        for view in subviews {
            if (view as? ComponentView)?.component?.id == id {
                return view
            }
        }
        return nil
    }
}
