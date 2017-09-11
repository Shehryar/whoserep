//
//  UINavigationControllerExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/11/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension UINavigationController {
    func popToRootViewController(animated: Bool, completion: @escaping () -> Void) {
        if animated {
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            self.popToRootViewController(animated: true)
            CATransaction.commit()
        } else {
            self.popToRootViewController(animated: false)
            completion()
        }
    }
}
