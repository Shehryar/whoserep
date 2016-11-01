//
//  HomeViewController.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/8/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

class HomeViewController: BaseViewController {
    
    let canChangeCompany: Bool
    
    // MARK: Private Properties
    
    fileprivate var environment: ASAPPEnvironment {
        return DemoSettings.currentEnvironment()
    }
    
    fileprivate var authProvider: ASAPPAuthProvider!
    fileprivate var contextProvider: ASAPPContextProvider!
    fileprivate var callbackHandler: ASAPPCallbackHandler!

    // MARK: UI
    
    fileprivate let backgroundImageView = UIImageView()
    
    fileprivate let homeTableView: HomeTableView
    
    fileprivate var chatButton: ASAPPButton?
        
    fileprivate let settingsBannerView = HomeSettingsBanner()
    
    // MARK:- Initialization

    required init(appSettings: AppSettings, canChangeCompany: Bool) {
        self.canChangeCompany = canChangeCompany
        self.homeTableView = HomeTableView(appSettings: appSettings)
        super.init(appSettings: appSettings)
        
        self.homeTableView.delegate = self
        self.authProvider = { [weak self] in
            return self?.appSettings.getAuthData() ?? ["" : "" as AnyObject]
        }
        self.contextProvider = { [weak self] in
            return self?.appSettings.getContext() ?? ["" : "" as AnyObject]
        }
        self.callbackHandler = { [weak self] (deepLink, deepLinkData) in
            guard let blockSelf = self else { return }
            
            if !blockSelf.handleAction(deepLink, userInfo: deepLinkData) {
                blockSelf.displayHandleActionAlert(deepLink, userInfo: deepLinkData)
            }
        }
    }
    
    required init(appSettings: AppSettings) {
        fatalError("init(appSettings:) has not been implemented")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        homeTableView.delegate = nil
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        ASAPP.setLogLevel(logLevel: .Debug)
        updateBarButtonItems()
        
        view.addSubview(homeTableView)
        view.addSubview(backgroundImageView)
        view.addSubview(settingsBannerView)
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
        
        homeTableView.frame = view.bounds
        homeTableView.contentInset = UIEdgeInsets(top: settingsBannerView.frame.maxY, left: 0, bottom: 0, right: 0)
        
        backgroundImageView.frame = CGRect(x: 0, y: settingsBannerTop, width: view.bounds.width, height: view.bounds.height - settingsBannerTop)
    }
}

// MARK:- Company-Specific 

extension HomeViewController {
    
    override func reloadViewForUpdatedSettings() {
        super.reloadViewForUpdatedSettings()
        
        // Background Image
        backgroundImageView.image = appSettings.homeBackgroundImage
        backgroundImageView.isHidden = backgroundImageView.image == nil
        
        homeTableView.appSettings = appSettings
        
        // Nav Logo
        let logoImageView = UIImageView(image: appSettings.logoImage)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.frame = CGRect(x: 0, y: 0, width: appSettings.logoImageSize.width, height: appSettings.logoImageSize.height)
        logoImageView.isUserInteractionEnabled = true
        if canChangeCompany {
            let tapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.changeCompany))
            tapGesture.numberOfTapsRequired = 4
            logoImageView.addGestureRecognizer(tapGesture)
        }
        navigationItem.titleView = logoImageView
        
        // Nav Bar
        styleNavigationBar(navBar: navigationController?.navigationBar)
        statusBarStyle = appSettings.statusBarStyle

        // Chat Button
        refreshChatButton()
    }
    
    func styleNavigationBar(navBar: UINavigationBar?) {
        guard let navBar = navBar else { return }
        
        navBar.isTranslucent = true
        navBar.setBackgroundImage(nil, for: .default)
        navBar.backgroundColor = nil
        navBar.barTintColor = appSettings.navBarColor
        navBar.tintColor = appSettings.navBarTintColor
        navBar.titleTextAttributes = [
            NSForegroundColorAttributeName : appSettings.navBarTitleColor,
            NSFontAttributeName : DemoFonts.latoBoldFont(withSize: 17),
        ]
        
        UIBarButtonItem.appearance().setTitleTextAttributes([
            NSFontAttributeName : DemoFonts.latoBoldFont(withSize: 16),
            NSForegroundColorAttributeName : appSettings.navBarTintColor
            ],
                                                            for: .normal)
    }
    
    func changeCompany() {
        guard canChangeCompany else { return }
        
        let nextCompany = AppSettings.changeCompany(fromCompany: appSettings.company)
        appSettings = AppSettings.settingsFor(nextCompany)
    }
}

// MARK:- Chat

extension HomeViewController {
    
    func updateBarButtonItems() {
        let userButton = UIBarButtonItem(image: UIImage(named: "icon-user"),
                                         style: .plain,
                                         target: self,
                                         action: #selector(HomeViewController.promptToChangeUser))
        
        let settingsButton = UIBarButtonItem(image: UIImage(named: "icon-gear"),
                                             style: .plain,
                                             target: self,
                                             action: #selector(HomeViewController.showSettings))
        
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
            company: appSettings.companyMarker,
            customerId: appSettings.getUserToken(),
            environment: environment,
            authProvider: authProvider,
            contextProvider: contextProvider,
            callbackHandler: callbackHandler,
            styles: nil,
            presentingViewController: self)
        
        
        if let chatButton = chatButton {
            chatButton.frame = CGRect(x: 0, y: 25, width: 65, height: 65)
            let buttonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 65, height: 88))
            buttonContainerView.addSubview(chatButton)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonContainerView)
        }
    }
}


// MARK:- DemoSettingsViewControllerDelegate

extension HomeViewController: DemoSettingsViewControllerDelegate {
    
    func demoSettingsViewControllerDidUpdateSettings(_ viewController: DemoSettingsViewController) {
        settingsBannerView.updateLabels()
        refreshChatButton()
        updateBarButtonItems()
    }
}

// MARK:- Settings

extension HomeViewController {
    
    func promptToChangeUser() {
        
        let alert = UIAlertController(title: "Create a new user?",
                                      message: "This will delete your existing conversation and replace it with that of a new user.",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "Create New User",
                                      style: .default,
                                      handler: { (action) in
                                        _ = self.appSettings.createNewUserToken()
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
        styleNavigationBar(navBar: navController.navigationBar)
        present(navController, animated: true, completion: nil)
    }
}

// MARK:- HomeTableViewDelegate

extension HomeViewController: HomeTableViewDelegate {
    
    func homeTableViewDidTapBillDetails(homeTableView: HomeTableView) {
        showBillDetails()
    }
    
    func homeTableViewDidTapHelp(homeTableView: HomeTableView) {
        showHelp()
    }
}

// MARK:- Handling ASAPP Actions

extension HomeViewController {
    
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
            showBillDetails()
            handled = true
            break
            
        default:
            handled = false
            break
        }
        
        return handled
    }
    
    func showBillDetails() {
        let billDetailsVC = BillDetailsViewController(appSettings: appSettings)
        billDetailsVC.statusBarStyle = statusBarStyle
        navigationController?.pushViewController(billDetailsVC, animated: true)
    }
    
    func showHelp() {
        let chatViewController = ASAPP.createChatViewController(
            company: appSettings.companyMarker,
            customerId: appSettings.getUserToken(),
            environment: environment,
            authProvider: authProvider,
            contextProvider: contextProvider,
            callbackHandler: callbackHandler,
            styles: nil)
        
        present(chatViewController, animated: true, completion: nil)
    }

}

// MARK:- Action View Controllers

extension HomeViewController {
    
    func showViewController(_ imageName: String, title: String?) -> Bool {
        guard let image = imageForImageName(imageName: imageName) else {
            return false
        }
        
        let viewController = ImageBackgroundViewController(appSettings: appSettings)
        viewController.title = title
        viewController.imageView.image = image
        viewController.statusBarStyle = statusBarStyle
        navigationController?.pushViewController(viewController, animated: true)
        
        return true
    }
    
    // MARK: Utility
    
    private func imageForImageName(imageName: String) -> UIImage? {
        if let image = UIImage(named: "\(appSettings.companyMarker)-\(imageName)") {
            return image
        }
        
        return nil
    }
}
