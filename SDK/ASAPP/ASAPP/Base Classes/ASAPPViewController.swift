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
        navigationBar.applyASAPPStyles()
        setNeedsStatusBarAppearanceUpdate()
    }
}
