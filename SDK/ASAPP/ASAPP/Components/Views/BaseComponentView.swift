//
//  BaseComponentView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/24/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BaseComponentView: UIView, ComponentView, ComponentStyleable {

    static let defaultBackgroundColor = UIColor.clear
    
    // MARK: ComponentView Properties
    
    var component: Component? {
        didSet {
            if let component = component {
                applyStyle(component.style)
            }
        }
    }
    
    weak var interactionHandler: InteractionHandler? {
        didSet {
            updateSubviewsWithInteractionHandler()
        }
    }
    
    // MARK: Init
    
    func commonInit() {
        clipsToBounds = true
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    // MARK: Interaction Delegate
    
    func updateSubviewsWithInteractionHandler() {
        for (idx, _) in subviews.enumerated() {
            var view = subviews[idx] as? ComponentView
            view?.interactionHandler = self.interactionHandler
        }
    }
}
