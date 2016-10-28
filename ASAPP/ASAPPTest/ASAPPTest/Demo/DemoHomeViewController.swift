//
//  DemoHomeViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/8/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

class DemoHomeViewController: ImageBackgroundViewController {
    
    var companyMarker: String {
        didSet {
            userManager = DemoUserManager(companyMarker: companyMarker)
            
            updateViewForCompany()
        }
    }
    
    let canChangeCompany: Bool
    
    var userManager: DemoUserManager
    
    // MARK: Private Properties
    
    fileprivate var canToggleCompany = true
    
    fileprivate var environment: ASAPPEnvironment {
        return DemoSettings.currentEnvironment()
    }
    
    fileprivate var chatButton: ASAPPButton?
        
    fileprivate let settingsBannerView = DemoCurrentSettingsBanner()
    
    // MARK:- Initialization
    
    required init(companyMarker: String, canChangeCompany: Bool) {
        self.companyMarker = companyMarker
        self.canChangeCompany = canChangeCompany
        self.userManager = DemoUserManager(companyMarker: companyMarker)
        super.init(nibName: nil, bundle: nil)
        
        ASAPP.setLogLevel(logLevel: .Debug)
        
        updateBarButtonItems()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        updateViewForCompany()
        
        view.addSubview(settingsBannerView)
        
//        let button = UIButton(frame: CGRect(x: 100, y: 200, width: 50, height: 50))
//        button.setTitle("X", for: .normal)
//        button.titleLabel?.font = UIFont.boldSystemFont(ofSize: 30)
//        button.setTitleColor(UIColor.blue, for: .normal)
//        button.addTarget(self, action: #selector(DemoHomeViewController.didTapCustomButton), for: .touchUpInside)
//        view.addSubview(button)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        settingsBannerView.updateLabels()
        updateBarButtonItems()
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        var settingsBannerTop: CGFloat = 0.0
        if let navBar = navigationController?.navigationBar {
            settingsBannerTop = navBar.frame.maxY
        }
        settingsBannerView.frame = CGRect(x: 0.0, y: settingsBannerTop, width: view.bounds.width, height: 20)
    }
}

// MARK:- Company-Specific 

extension DemoHomeViewController {
    
    func updateViewForCompany() {
        
        var companyMarkerForImage = companyMarker
        if companyMarkerForImage == "text-rex" {
            companyMarkerForImage = "sprint"
        }
        
        // Background
        imageView.image = UIImage(named: "\(companyMarkerForImage)-home")
        
        // Nav Logo
        let logoImageView = UIImageView(image: UIImage(named: "\(companyMarkerForImage)-logo"))
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.frame = CGRect(x: 0, y: 0, width: 120, height: 26)
        logoImageView.isUserInteractionEnabled = true
        
        if canChangeCompany {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(DemoHomeViewController.toggleCompany))
            tapGesture.numberOfTapsRequired = 4
            logoImageView.addGestureRecognizer(tapGesture)
        }
        
        navigationItem.titleView = logoImageView
        
        // Nav Bar
     
        var companyStatusBarStyle: UIStatusBarStyle = .default
        if companyMarker == "comcast" {
            companyStatusBarStyle = .lightContent
        }
        styleNavigationController(navController: navigationController)
        statusBarStyle = companyStatusBarStyle
        
        // Settings Banner
//        settingsBannerView.backgroundColor = barTintColor
//        settingsBannerView.foregroundColor = titleColor
        
        // Chat Button
        refreshChatButton()
    }
    
    func styleNavigationController(navController: UINavigationController?) {
        var barTintColor: UIColor = UIColor.white
        var buttonTintColor: UIColor = UIColor(red:0.247, green:0.293, blue:0.365, alpha:1)
        var titleColor: UIColor = UIColor.darkText
        let titleFont: UIFont = UIFont.boldSystemFont(ofSize: 16)
        let buttonFont: UIFont = UIFont.systemFont(ofSize: 16)
        if companyMarker == "comcast" {
            barTintColor = UIColor(red:0.074, green:0.075, blue:0.074, alpha:1)
            buttonTintColor = UIColor.white
            titleColor = UIColor.white
        } else {
            buttonTintColor = UIColor.darkGray
        }
        navController?.navigationBar.barTintColor = barTintColor
        navController?.navigationBar.tintColor = buttonTintColor
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : buttonFont
            ], for: UIControlState())
        navController?.navigationBar.titleTextAttributes = [
            NSForegroundColorAttributeName : titleColor,
            NSFontAttributeName : titleFont
        ]
        navController?.navigationBar.isTranslucent = true
    }
    
    func toggleCompany() {
        guard canToggleCompany else { return }
        
        canToggleCompany = false
        
        if companyMarker == "comcast" {
            companyMarker = "sprint"
//            companyMarker = "text-rex"
        } else {
            companyMarker = "comcast"
        }
        
        DispatchQueue.main.asyncAfter(
            deadline: DispatchTime.now() + Double(Int64(1000 * Double(NSEC_PER_MSEC))) / Double(NSEC_PER_SEC), execute: {
                self.canToggleCompany = true
        })
    }
}

// MARK:- DemoSettingsViewControllerDelegate

extension DemoHomeViewController: DemoSettingsViewControllerDelegate {
    
    func demoSettingsViewControllerDidUpdateSettings(_ viewController: DemoSettingsViewController) {
        settingsBannerView.updateLabels()
        refreshChatButton()
        updateBarButtonItems()
    }
}

// MARK:- Chat

extension DemoHomeViewController {
    
    func updateBarButtonItems() {
        let userButton = UIBarButtonItem(image: UIImage(named: "icon-user"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(DemoHomeViewController.promptToChangeUser))
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "icon-gear"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(DemoHomeViewController.showSettings))
        
        if DemoSettings.useDemoPhoneUser() {
            navigationItem.leftBarButtonItems = [
                settingsButton
            ]
        } else {
            navigationItem.leftBarButtonItems = [
                userButton,
                settingsButton
            ]
        }
    }
    
    func refreshChatButton() {
        chatButton?.removeFromSuperview()
        
//        print("Company: \(userManager.companyMarker)\nuserToken: \(userManager.getUserToken())\nEnvironment: \(environment.rawValue)")
        
        chatButton = ASAPP.createChatButton(
            company: userManager.companyMarker,
            customerId: userManager.getUserToken(),
            environment: environment,
            authProvider: { [weak self] () -> [String : Any] in
                return self?.userManager.getAuthData() ?? ["" : "" as AnyObject]
            },
            contextProvider: { [weak self] () -> [String : Any] in
                return self?.userManager.getContext() ?? ["" : "" as AnyObject]
            },
            callbackHandler: { [weak self] (deepLink, deepLinkData) in
                guard let blockSelf = self else { return }
                
                if !blockSelf.handleAction(deepLink, userInfo: deepLinkData) {
                    blockSelf.displayHandleActionAlert(deepLink, userInfo: deepLinkData)
                }
            },
            styles: nil,
            presentingViewController: self)
        
        
        if let chatButton = chatButton {
            chatButton.frame = CGRect(x: 0, y: 25, width: 65, height: 65)
            let buttonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 65, height: 88))
            buttonContainerView.addSubview(chatButton)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonContainerView)
        }
    }
    
    func didTapCustomButton() {
        
        let chatViewController = ASAPP.createChatViewController(
            company: userManager.companyMarker,
            customerId: userManager.getUserToken(),
            environment: environment,
            authProvider: { [weak self] () -> [String : Any] in
                return self?.userManager.getAuthData() ?? ["" : "" as AnyObject]
            },
            contextProvider: { [weak self] () -> [String : Any] in
                return self?.userManager.getContext() ?? ["" : "" as AnyObject]
            },
            callbackHandler: { [weak self] (deepLink, deepLinkData) in
                guard let blockSelf = self else { return }
                
                if !blockSelf.handleAction(deepLink, userInfo: deepLinkData) {
                    blockSelf.displayHandleActionAlert(deepLink, userInfo: deepLinkData)
                }
            },
            styles: nil)
        
        present(chatViewController, animated: false, completion: nil)
    }
}

// MARK:- Settings

extension DemoHomeViewController {
    
    func promptToChangeUser() {
        let alert = UIAlertController(title: "Create a new user?",
                                      message: "This will delete your existing conversation and replace it with that of a new user.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Create New User",
                                      style: .default,
                                      handler: { (action) in
                                        _ = self.userManager.createNewUserToken()
                                        self.refreshChatButton()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel",
                                      style: .cancel,
                                      handler: { (action) in
                                        // No action
        }))
        
        present(alert, animated: true, completion: nil)
    }
    
    func showSettings() {
        let settingsViewController = DemoSettingsViewController()
        settingsViewController.statusBarStyle = statusBarStyle
        settingsViewController.delegate = self
        let navController = NavigationController(rootViewController: settingsViewController)
        styleNavigationController(navController: navController)
        present(navController, animated: true, completion: nil)
    }
}

// MARK:- Handling ASAPP Actions

extension DemoHomeViewController {
    
    func displayHandleActionAlert(_ action: String, userInfo: [String : Any]?) {
        let message: String
        let userInfo = userInfo ?? [:]
        if !userInfo.isEmpty {
            message = "The host app is responsible for handling this action appropriately.\n\(userInfo)"
        } else {
            message = "The host app is responsible for handling this action appropriately."
        }
        
        let alert = UIAlertController(title: "Action Received: \(action)",
            message: message,
            preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func handleAction(_ action: String, userInfo: [String : Any]?) -> Bool {
        
        var handled: Bool
        
        switch action {
        case "tv":
            handled = showViewController("tv", title: "Television")
            break
            
        case "troubleshoot", "internet-troubleshoot":
            handled = showViewController("troubleshoot", title: "Troubleshooter")
            break
            
        case "internet":
            handled = showViewController("internet", title: "Internet")
            break
            
        case "restart":
            handled = showViewController("restart", title: "Device Restart")
            break
            
        case "payment":
            handled = showViewController("payment", title: "Payments")
            break
            
        case "showTechMap":
            handled = showViewController("tech-map", title: "Location")
            break
            
        case "understandBill":
            let billDetailsVC = BillDetailsViewController()
            billDetailsVC.statusBarStyle = statusBarStyle
            navigationController?.pushViewController(billDetailsVC, animated: true)
            handled = true
            break
            
        default:
            handled = false
            break
        }
        
        return handled
    }
}

// MARK:- Action View Controllers

extension DemoHomeViewController {
    
    func showViewController(_ imageName: String, title: String?) -> Bool {
        guard let image = imageForImageName(imageName: imageName) else {
            return false
        }
        
        let viewController = ImageBackgroundViewController()
        viewController.title = title
        viewController.imageView.image = image
        viewController.statusBarStyle = statusBarStyle
        navigationController?.pushViewController(viewController, animated: true)
        
        return true
    }
    
    // MARK: Utility
    
    private func imageForImageName(imageName: String) -> UIImage? {
        // TODO: Check for device size
        
        var companyMarkerForImage = companyMarker
        if companyMarkerForImage == "text-rex" {
            companyMarkerForImage = "sprint"
        }
        
        if let image = UIImage(named: "\(companyMarkerForImage)-\(imageName)") {
            return image
        }
        
        return nil
    }
}
