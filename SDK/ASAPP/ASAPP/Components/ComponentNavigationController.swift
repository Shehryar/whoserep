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
    
    var displayStyle: ComponentViewDisplayStyle = .full {
        didSet {
            useCustomPresentation = displayStyle == .inset
        }
    }
    
    fileprivate(set) var useCustomPresentation: Bool = false {
        didSet {
            if useCustomPresentation {
                isNavigationBarHidden = true
                presentationAnimator.fixedBottom = true
                presentationAnimator.viewInsetTop = 40
                presentationAnimator.viewInsetSides = 0
                presentationAnimator.viewInsetBottom = 0
                presentationAnimator.tapToDismissEnabled = true
                modalPresentationStyle = .custom
                transitioningDelegate = presentationAnimator
            } else {
                isNavigationBarHidden = false
                modalPresentationStyle = .fullScreen
                transitioningDelegate = nil
                presentationAnimator.tapToDismissEnabled = false
            }
        }
    }
}
