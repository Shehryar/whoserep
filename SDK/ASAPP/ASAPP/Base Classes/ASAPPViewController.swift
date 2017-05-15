//
//  ASAPPViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public class ASAPPViewController: UIViewController {

    var hideViewContentsWhileBackgrounded: Bool = false
    
    let backgroundedViewCover = SecureScreenCoverView()
    
    deinit {
        stopObservingNotifications()
    }
    
    // MARK:- View
    
    override public func viewDidLoad() {
        super.viewDidLoad()

        // BackgroundViewCover
        backgroundedViewCover.backgroundColor = ASAPP.styles.colors.backgroundSecondary
        backgroundedViewCover.addGestureRecognizer(UITapGestureRecognizer(target: self, action: #selector(showViewContents)))
        
        // Nav Bar
        updateNavigationBar()
        
        // Notifications
        beginObservingNotifications()
    }
    
    // MARK:- Layout
    
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        backgroundedViewCover.frame = view.bounds
    }
}

// MARK:- Notifications

extension ASAPPViewController {
    
    func beginObservingNotifications() {
        // App left foreground
        let backgroundNotificationNames = [Notification.Name.UIApplicationDidEnterBackground,
                                        Notification.Name.UIApplicationWillResignActive]
        let hideContentsSelector = #selector(ASAPPViewController.hideViewContents)
        for notificationName in backgroundNotificationNames {
            NotificationCenter.default.addObserver(self,
                                                   selector: hideContentsSelector,
                                                   name: notificationName,
                                                   object: nil)
        }
        
        // App entered foreground
        let foregroundNotificationNames = [Notification.Name.UIApplicationDidBecomeActive,
                                           Notification.Name.UIApplicationWillEnterForeground]
        let showContentsSelector = #selector(ASAPPViewController.showViewContents)
        for notificationName in foregroundNotificationNames {
            NotificationCenter.default.addObserver(self,
                                                   selector: showContentsSelector,
                                                   name: notificationName,
                                                   object: nil)
        }
    }
    
    func stopObservingNotifications() {
        NotificationCenter.default.removeObserver(self)
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

// MARK:- Screen Cover

extension ASAPPViewController {
    
    func hideViewContents() {
        guard hideViewContentsWhileBackgrounded else {
            return
        }
        
        if view.subviews.contains(backgroundedViewCover) {
            view.bringSubview(toFront: backgroundedViewCover)
        } else {
            view.addSubview(backgroundedViewCover)
        }
    }
    
    func showViewContents() {
        backgroundedViewCover.removeFromSuperview()
    }
}
