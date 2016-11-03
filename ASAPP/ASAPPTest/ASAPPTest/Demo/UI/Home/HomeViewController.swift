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
    
    var currentAccount: UserAccount {
        didSet {
            appSettings.setCurrentAccount(account: currentAccount)
            homeTableView.currentAccount = currentAccount
            refreshChatButton()
        }
    }
    
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
    
    // MARK:- Initialization

    required init(appSettings: AppSettings, canChangeCompany: Bool) {
        self.canChangeCompany = canChangeCompany
        self.homeTableView = HomeTableView(appSettings: appSettings)
        self.currentAccount = appSettings.getCurrentAccount()
        super.init(appSettings: appSettings)
        
        self.homeTableView.currentAccount = currentAccount
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
        
        view.addSubview(homeTableView)
        view.addSubview(backgroundImageView)
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        var visibleTop: CGFloat = 0.0
        if let navBar = navigationController?.navigationBar {
            visibleTop = navBar.frame.maxY
        }
        
        homeTableView.frame = view.bounds
        homeTableView.contentInset = UIEdgeInsets(top: visibleTop, left: 0, bottom: 0, right: 0)
        
        backgroundImageView.frame = CGRect(x: 0, y: visibleTop, width: view.bounds.width, height: view.bounds.height - visibleTop)
    }
}

// MARK:- Styling 

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
        
        // Chat Button
        refreshChatButton()
    }
    
    func changeCompany() {
        guard canChangeCompany else { return }
        
        let nextCompany = AppSettings.changeCompany(fromCompany: appSettings.company)
        let nextAppSettings = AppSettings.settingsFor(nextCompany)
        
        if !nextAppSettings.supportsLiveChatDemo() {
            DemoSettings.setDemoLiveChat(false)
        }
        nextAppSettings.updateDemoEnvironment()
        
        self.appSettings = nextAppSettings
    }
}

// MARK:- Chat

extension HomeViewController {
    
    func refreshChatButton() {
        chatButton?.removeFromSuperview()
        
//        print("Company: \(userManager.companyMarker)\nuserToken: \(userManager.getUserToken())\nEnvironment: \(environment.rawValue)")
        
        chatButton = ASAPP.createChatButton(
            company: appSettings.companyMarker,
            customerId: currentAccount.userToken,
            environment: environment,
            authProvider: authProvider,
            contextProvider: contextProvider,
            callbackHandler: callbackHandler,
            styles: appSettings.styles,
            presentingViewController: self)
        
        
        if let chatButton = chatButton {
            chatButton.frame = CGRect(x: 0, y: 25, width: 65, height: 65)
            let buttonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 65, height: 88))
            buttonContainerView.addSubview(chatButton)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonContainerView)
        }
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
    
    func homeTableViewDidTapSwitchAccount(homeTableView: HomeTableView) {
        showAccountsPage()
    }
    
    func homeTableViewDidUpdateDemoSettings(homeTableView: HomeTableView) {
        refreshChatButton()
    }
    
    func homeTableViewDidTapEnvironmentSettings(homeTableView: HomeTableView) {
        showEnvironmentSettings()
    }
}

// MARK:- AccountsViewControllerDelegate

extension HomeViewController: AccountsViewControllerDelegate {
    
    func accountsViewController(viewController: AccountsViewController, didSelectAccount account: UserAccount) {
        currentAccount = account
        _ = navigationController?.popToViewController(self, animated: true)
    }
}

// MARK:- DemoEnvironmentViewControllerDelegate

extension HomeViewController: DemoEnvironmentViewControllerDelegate {
    
    func demoEnvironmentViewControllerDidUpdateEnvironment(_ viewController: DemoEnvironmentViewController) {
        homeTableView.appSettings = appSettings
        refreshChatButton()
    }
    
    func demoEnvironmentViewController(_ viewController: DemoEnvironmentViewController, didUpdateAppSettings appSettings: AppSettings) {
        self.appSettings = appSettings
        refreshChatButton()
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
}

// MARK:- Navigation to View Controllers

extension HomeViewController {
    
    func showBillDetails() {
        let billDetailsVC = BillDetailsViewController(appSettings: appSettings)
        navigationController?.pushViewController(billDetailsVC, animated: true)
    }
    
    func showHelp() {
        let chatViewController = ASAPP.createChatViewController(
            company: appSettings.companyMarker,
            customerId: currentAccount.userToken,
            environment: environment,
            authProvider: authProvider,
            contextProvider: contextProvider,
            callbackHandler: callbackHandler,
            styles: appSettings.styles)
        
        present(chatViewController, animated: true, completion: nil)
    }
    
    func showAccountsPage() {
        let accountsVC = AccountsViewController(appSettings: appSettings)
        accountsVC.currentAccount = currentAccount
        accountsVC.delegate = self
        navigationController?.pushViewController(accountsVC, animated: true)
    }
    
    func showEnvironmentSettings() {
        let environmentVC = DemoEnvironmentViewController(appSettings: appSettings)
        environmentVC.delegate = self
        navigationController?.pushViewController(environmentVC, animated: true)
    }
    
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
