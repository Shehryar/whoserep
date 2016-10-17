//
//  NavigationController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/16/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if let topViewController = topViewController {
            return topViewController.preferredStatusBarStyle
        }
        return super.preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden : Bool {
        if let topViewController = topViewController {
            return topViewController.prefersStatusBarHidden
        }
        return super.prefersStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        if let topViewController = topViewController {
            return topViewController.preferredStatusBarUpdateAnimation
        }
        return super.preferredStatusBarUpdateAnimation
    }
}
