//
//  Component.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class Component: NSObject {
    
    // MARK:- Properties
    
    var viewClass: UIView.Type {
        assert(false, "Subclass '\(String(describing: type(of: self)))' must override variable 'viewClass: ComponentView.Type'!")
        return ButtonView.self
    }
    
    let id: String?
    
    let name: String?
    
    var value: Any?
    
    let style: ComponentStyle
    
    // MARK:- Init
    
    required init?(id: String?,
                   name: String?,
                   value: Any?,
                   style: ComponentStyle,
                   styles: [String : Any]?,
                   content: [String : Any]?) {
        self.id = id
        self.name = name
        self.value = value
        self.style = style
        super.init()
    }
    
    // MARK: View Generation
    
    func createView() -> ComponentView? {
        var view = viewClass.init() as? ComponentView
        view?.component = self
        return view
    }
}
