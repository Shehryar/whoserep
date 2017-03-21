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
    var id: String? { get }
    var style: ComponentStyle { get }
    
    static func make(with content: Any?,
                     id: String?,
                     style: ComponentStyle) -> Component?
}
