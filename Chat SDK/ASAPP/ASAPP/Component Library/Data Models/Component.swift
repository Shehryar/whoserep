//
//  Component.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

// MARK:- Component

protocol Component {
    var type: ComponentType { get }
    var id: String? { get }
    var layout: ComponentLayout { get }
    
    static func make(with content: [String : AnyObject]?,
                     id: String?,
                     layout: ComponentLayout) -> Component?
}
