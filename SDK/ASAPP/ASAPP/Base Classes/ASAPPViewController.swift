//
//  ASAPPViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ASAPPViewController: UIViewController {

    override public func viewDidLoad() {
        super.viewDidLoad()

        updateNavigationBar()
    }
}

// MARK:- Interface Orientation

extension ASAPPViewController {
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
}

// MARK:- Status Bar

extension ASAPPViewController {
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if ASAPP.styles.colors.navBarBackground.isDark() {
            return .lightContent
        }
        return .default
    }
    
    override public var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .fade
    }
    
    func updateStatusBar(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            })
        } else {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
}

// MARK:- UINavigationBar

extension ASAPPViewController {
    
    func updateNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else {
            return
        }
        
        navigationBar.isTranslucent = false
        navigationBar.isOpaque = true
        navigationBar.shadowImage = nil
        navigationBar.setBackgroundImage(nil, for: .default)
        navigationBar.setBackgroundImage(nil, for: .compact)
        navigationBar.backgroundColor = nil
        if ASAPP.styles.colors.navBarBackground.isDark() {
            navigationBar.barStyle = .black
            if ASAPP.styles.colors.navBarBackground != UIColor.black {
                navigationBar.barTintColor = ASAPP.styles.colors.navBarBackground
            }
        } else {
            navigationBar.barStyle = .default
            if ASAPP.styles.colors.navBarBackground != UIColor.white {
                navigationBar.barTintColor = ASAPP.styles.colors.navBarBackground
            }
        }
        navigationBar.tintColor = ASAPP.styles.colors.navBarButton
        setNeedsStatusBarAppearanceUpdate()
    }
}
