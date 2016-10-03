//
//  ComcastHomeViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 8/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

class ComcastHomeViewController: ImageBackgroundViewController {
    
    var chatButton: ASAPPButton?
    
    let debugView = DebugInfoView()
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        return .default
    }
    
    // MARK:- Initialization
    
    override func commonInit() {
        super.commonInit()
        
        ASAPP.setLogLevel(logLevel: .Debug)
        
        imageView.image = UIImage(named: "home")
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Create New User",
                                                           style: .plain,
                                                           target: self,
                                                           action: #selector(ComcastHomeViewController.promptToChangeUser))
        
        debugView.onCustomChatTap = {
            self.didTapCustomButton()
        }
        debugView.onEnvironmentChange = { (usingProduction) in
            self.refreshChatButton()
        }
        
        refreshChatButton()
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.addSubview(debugView)
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        let debugHeight: CGFloat = 200
        let debugTop: CGFloat = view.bounds.height - debugHeight - 100
        debugView.frame = CGRect(x: 0, y: debugTop, width: view.bounds.width, height: debugHeight)
    }
    
    // MARK:- ASAPP Chat Button
    
    func environmentForTesting() -> ASAPPEnvironment {
        return debugView.isUsingProduction ? .production : .staging
    }
    
    func refreshChatButton() {
        chatButton?.removeFromSuperview()
        
        chatButton = ASAPP.createChatButton(company: ComcastUserManager.getCompany(),
                                            customerId: ComcastUserManager.getUserToken(),
                                            environment: environmentForTesting(),
                                            authProvider: { () -> [String : Any] in
                                                return ComcastUserManager.getAuthData()
            },
                                            contextProvider: { () -> [String : Any] in
                                                return ComcastUserManager.getContext()
            },
                                            callbackHandler: { (deepLink, deepLinkData) in
                                                self.handleAction(deepLink, userInfo: deepLinkData)
            },
                                            styles: nil,
                                            presentingViewController: self)
        
        if let chatButton = chatButton {
            chatButton.hideUntilAnimateInIsCalled()
            chatButton.frame = CGRect(x: 0, y: 25, width: 65, height: 65)
            let buttonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 65, height: 88))
            buttonContainerView.addSubview(chatButton)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonContainerView)
            
            chatButton.animateIn(afterDelay: 1.0)
        }
    }
    
    // MARK:- Custom Chat Button
    
    func didTapCustomButton() {
        let chatViewController = ASAPP.createChatViewController(company: ComcastUserManager.getCompany(),
                                                                customerId: ComcastUserManager.getUserToken(),
                                                                environment: environmentForTesting(),
                                                                authProvider: { () -> [String : Any] in
                                                                    return ComcastUserManager.getAuthData()
            },
                                                                contextProvider: { () -> [String : Any] in
                                                                    return ComcastUserManager.getContext()
            },
                                                                callbackHandler: { (deepLink, deepLinkData) in
                                                                    self.handleAction(deepLink, userInfo: deepLinkData)
            },
                                                                styles: nil)
        
        present(chatViewController, animated: true, completion: nil)
    }
}

// MARK:- User Management

extension ComcastHomeViewController {
    func promptToChangeUser() {
        let alert = UIAlertController(title: "Create a new user?",
                                      message: "This will delete your existing conversation and replace it with that of a new user.",
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Create New User", style: .default, handler: { (action) in
            _ = ComcastUserManager.createNewUserToken()
            self.refreshChatButton()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .cancel, handler: { (action) in
            // No action
        }))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK:- Handling ASAPP Actions

extension ComcastHomeViewController {
    func handleAction(_ action: String, userInfo: [String : Any]?) {
        
        switch action {
        case "tv":
            showTVHome()
            return
            
        case "troubleshoot":
            if let userInfo = userInfo, let service = userInfo["service"] as? String {
                switch service {
                case "internet":
                    showInternetTroubleshoot()
                    return
                    
                default:
                    showTvTroubleshoot()
                    return
                }
            } else {
                showTvTroubleshoot()
                return
            }
            
        case "internet":
            showInternetHome()
            return
            
        case "internet-troubleshoot":
            showInternetTroubleshoot()
            return
            
        case "restart":
            showRestartDevice()
            return
            
        case "payment":
            showPaymentScreen()
            return
            
        case "showTechMap":
            showTechnicianMap()
            return
            
        default: break
        }
        
        let alert = UIAlertController(title: "SRS Action Received",
                                      message: "The host app is responsible for handling this action (\(action)) appropriately.",
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

// MARK:- Showing Test View Controllers

extension ComcastHomeViewController {
    
    internal func showViewControllerWithImage(_ imageName: String, title: String?) {
        let viewController = ImageBackgroundViewController()
        viewController.title = title
        viewController.imageView.image = UIImage(named: imageName)
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func showInternetHome() {
        showViewControllerWithImage("home_internet", title: "Internet")
    }
    
    func showTVHome() {
        showViewControllerWithImage("home_tv", title: "Television")
    }
    
    func showInternetTroubleshoot() {
        showViewControllerWithImage("speedTroubleshoot", title: "Troubleshooting")
    }
    
    func showTvTroubleshoot() {
        showViewControllerWithImage("tv_troubleshoot", title: "Troubleshooting")
    }
    
    func showRestartDevice() {
        showViewControllerWithImage("restartDeviceImage", title: "Device Restart")
    }
    
    func showPaymentScreen() {
        if UIScreen.main.bounds.size.width > 400 {
            showViewControllerWithImage("payment-screen-6plus", title: "Make Payment")
        } else {
            showViewControllerWithImage("payment-screen-6", title: "Make Payment")
        }
    }
    
    func showTechnicianMap() {
        showViewControllerWithImage("tech-map-screen", title: "Where's my Technician?")
    }
}
