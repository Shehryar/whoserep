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

    var hideViewContentsWhileBackgrounded: Bool = false
    
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

// MARK: - Interface Orientation

/// :nodoc:
extension ASAPPViewController {
    
    override public var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
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
        
        let componentViewController = ComponentViewController(viewName: action.name, viewData: action.data)
        componentViewController.delegate = delegate
        
        let navigationController = ComponentNavigationController(rootViewController: componentViewController)
        navigationController.displayStyle = action.displayStyle
        present(navigationController, animated: true, completion: nil)
    }
    
    func showWebPage(fromAction action: Action?) {
        guard let action = action as? WebPageAction else { return }
        
        // SFSafariViewController
        if let urlScheme = action.url.scheme {
            if ["http", "https"].contains(urlScheme) {
                let safariVC = SFSafariViewController(url: action.url)
                present(safariVC, animated: true, completion: nil)
                return
            } else {
                DebugLog.w("URL is missing http/https url scheme: \(action.url)")
            }
        }
        
        // Open in Safari
        if UIApplication.shared.canOpenURL(action.url) {
            UIApplication.shared.openURL(action.url)
        }

    }
}
