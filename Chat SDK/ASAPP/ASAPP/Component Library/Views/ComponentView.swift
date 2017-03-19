//
//  ComponentView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/18/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

protocol ComponentView {
    
    var component: Component? { get set }
    
    func sizeThatFits(_ size: CGSize) -> CGSize
}
