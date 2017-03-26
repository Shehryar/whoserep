//
//  ComponentNavigationController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentNavigationController: UINavigationController {

    let presentationAnimator = ModalCardPresentationAnimator()
    
    var useCustomPresentation: Bool = false {
        didSet {
            if useCustomPresentation {
                presentationAnimator.fixedBottom = true
                presentationAnimator.viewInsetTop = 40
                presentationAnimator.viewInsetSides = 0
                presentationAnimator.viewInsetBottom = 0
                modalPresentationStyle = .custom
                transitioningDelegate = presentationAnimator
            } else {
                modalPresentationStyle = .fullScreen
                transitioningDelegate = nil
            }
        }
    }
}
