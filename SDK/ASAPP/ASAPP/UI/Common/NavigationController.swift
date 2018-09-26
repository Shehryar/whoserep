//
//  NavigationController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/16/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class NavigationController: UINavigationController {
    // MARK: Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if let topViewController = topViewController {
            return topViewController.preferredStatusBarStyle
        }
        return super.preferredStatusBarStyle
    }
    
    override var prefersStatusBarHidden: Bool {
        if let topViewController = topViewController {
            return topViewController.prefersStatusBarHidden
        }
        return super.prefersStatusBarHidden
    }
    
    override var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
        if let topViewController = topViewController {
            return topViewController.preferredStatusBarUpdateAnimation
        }
        return super.preferredStatusBarUpdateAnimation
    }
    
    // MARK: Orientation
    
    override public var preferredInterfaceOrientationForPresentation: UIInterfaceOrientation {
        return UIDevice.current.userInterfaceIdiom == .phone
            ? .portrait
            : UIApplication.shared.statusBarOrientation
    }
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        if UIDevice.current.userInterfaceIdiom == .pad {
            return .all
        }
        
        if let top = topViewController as? ChatViewController {
            let orientations: UIInterfaceOrientationMask = top.doneTransitioning ? .portrait : .all
            return orientations
        }
        return .portrait
    }
    
    override public var shouldAutorotate: Bool {
        return true
    }
}
