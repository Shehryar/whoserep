//
//  ASAPPViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit
import SafariServices

/// :nodoc:
public class ASAPPViewController: UIViewController {
    var hideViewContentsWhileBackgrounded = false
    
    let backgroundedViewCover = SecureScreenCoverView()
    
    deinit {
        stopObservingNotifications()
    }
    
    // MARK: - View
    
    /**
     Overrides `UIViewController.viewDidLoad()`.
     */
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
    
    // MARK: - Layout
    
    /**
     Overrides `UIViewController.viewWillLayoutSubviews()`.
     */
    public override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        backgroundedViewCover.frame = view.bounds
    }
}

// MARK: - Notifications

extension ASAPPViewController {
    
    func beginObservingNotifications() {
        // App left foreground
        let backgroundNotificationNames = [NSNotification.Name.UIApplicationDidEnterBackground,
                                           NSNotification.Name.UIApplicationWillResignActive]
        let hideContentsSelector = #selector(ASAPPViewController.hideViewContents)
        for notificationName in backgroundNotificationNames {
            NotificationCenter.default.addObserver(self,
                                                   selector: hideContentsSelector,
                                                   name: notificationName,
                                                   object: nil)
        }
        
        // App entered foreground
        let foregroundNotificationNames = [NSNotification.Name.UIApplicationDidBecomeActive,
                                           NSNotification.Name.UIApplicationWillEnterForeground]
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

// MARK: - Status Bar

/// :nodoc:
extension ASAPPViewController {
    
    override public var preferredStatusBarStyle: UIStatusBarStyle {
        if ASAPP.styles.colors.navBarBackground?.isDark() == true {
            return .lightContent
        }
        return .default
    }
    
    override public var preferredStatusBarUpdateAnimation: UIStatusBarAnimation {
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

// MARK: - UINavigationBar

extension ASAPPViewController {
    
    func updateNavigationBar() {
        guard let navigationBar = navigationController?.navigationBar else {
            return
        }
        navigationBar.applyASAPPStyles()
        navigationBar.replaceBottomBorder()
        setNeedsStatusBarAppearanceUpdate()
    }
}

// MARK: - Screen Cover

extension ASAPPViewController {
    
    @objc func hideViewContents() {
        guard hideViewContentsWhileBackgrounded else {
            return
        }
        
        if view.subviews.contains(backgroundedViewCover) {
            view.bringSubview(toFront: backgroundedViewCover)
        } else {
            view.addSubview(backgroundedViewCover)
        }
    }
    
    @objc func showViewContents() {
        backgroundedViewCover.removeFromSuperview()
    }
}

// MARK: - Alerts

extension ASAPPViewController {
    
    func showAlert(title: String? = nil, message: String? = nil) {
        if title == nil && message == nil {
            DebugLog.w(caller: self, "Unable to call showAlert(::) with nil title and message.")
            return
        }
        
        if !Thread.isMainThread {
            Dispatcher.performOnMainThread { [weak self] in
                self?.showAlert(title: title, message: message)
            }
            return
        }
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: ASAPP.strings.alertDismissButton,
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showRequestErrorAlert(title: String? = nil, message: String? = nil) {
        showAlert(title: title ?? ASAPP.strings.requestErrorGenericFailureTitle,
                  message: message ?? ASAPP.strings.requestErrorGenericFailure)
    }
}

// MARK: - Actions

extension ASAPPViewController {
    
    func showComponentView(fromAction action: Action, delegate: ComponentViewControllerDelegate) {
        guard let action = action as? ComponentViewAction else {
            return
        }
        
        let componentViewController = ComponentViewController(viewName: action.name, viewData: action.data, isInset: action.displayStyle == .inset)
        componentViewController.delegate = delegate
        
        let navigationController = ComponentNavigationController(rootViewController: componentViewController)
        navigationController.displayStyle = action.displayStyle
        present(navigationController, animated: true, completion: nil)
    }
}
