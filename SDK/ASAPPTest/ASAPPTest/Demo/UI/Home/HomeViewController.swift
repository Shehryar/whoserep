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
    
    var currentAccount: UserAccount {
        didSet {
            appSettings.setCurrentAccount(account: currentAccount)
            homeTableView.currentAccount = currentAccount
            refreshChatButton()
        }
    }
    
    // MARK: Private Properties
    
    fileprivate var authenticationBlock: ASAPPRequestAuthenticationBlock!
    fileprivate var contextBlock: ASAPPRequestContextBlock!
    fileprivate var callbackHandler: ASAPPAppCallbackHandler!

    // MARK: UI
    
    fileprivate let brandingSwitcherView = BrandingSwitcherView()
    
    fileprivate let homeTableView: HomeTableView
    
    fileprivate var chatButton: ASAPPButton?
    
    // MARK:- Initialization

    required init(appSettings: AppSettings) {
        self.homeTableView = HomeTableView(appSettings: appSettings)
        self.currentAccount = appSettings.getCurrentAccount()
        super.init(appSettings: appSettings)
        
        self.authenticationBlock = { [weak self] in
            return self?.appSettings.getAuthData() ?? ["" : ""]
        }
        self.contextBlock = { [weak self] in
            return self?.appSettings.getContext() ?? ["" : ""]
        }
        self.callbackHandler = { [weak self] (deepLink, deepLinkData) in
            guard let blockSelf = self else { return }
            
            if !blockSelf.handleAction(deepLink, userInfo: deepLinkData) {
                blockSelf.displayHandleActionAlert(deepLink, userInfo: deepLinkData)
            }
        }
        updateConfig()
        
        homeTableView.currentAccount = currentAccount
        homeTableView.delegate = self
        homeTableView.reloadData()
        
        brandingSwitcherView.didSelectBrandingType = { [weak self] (type) in
            self?.changeBranding(brandingType: type)
        }
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
        view.addSubview(brandingSwitcherView)
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()

        var visibleTop: CGFloat = 0.0
        if let navBar = navigationController?.navigationBar {
            visibleTop = navBar.frame.maxY
        }
        
        let visibleHeight = view.bounds.height - visibleTop
        brandingSwitcherView.frame = CGRect(x: 0, y: visibleTop, width: view.bounds.width, height: visibleHeight)
        
        homeTableView.frame = view.bounds
        homeTableView.contentInset = UIEdgeInsets(top: visibleTop, left: 0, bottom: 0, right: 0)
    }
    
    // MARK:- ASAPPConfig
    
    func updateConfig() {
         DemoLog("\nUpdating Demo Config:\n--------------------\nAppId: \(currentAccount.company)\nAPI:   \(appSettings.apiHostName)\nUser:  \(currentAccount.userToken)\n")
        
        let config = ASAPPConfig(appId: currentAccount.company,
                                 apiHostName: appSettings.apiHostName,
                                 clientId: "ASAPP_DEMO_CLIENT_ID")
        
        let user = ASAPPUser(userIdentifier: currentAccount.userToken,
                             requestAuthenticationBlock: authenticationBlock,
                             requestContextBlock: contextBlock)
        
        ASAPP.initialize(with: config)
        ASAPP.user = user
    }
}

// MARK:- Styling 

extension HomeViewController {
    
    override func reloadViewForUpdatedSettings() {
        super.reloadViewForUpdatedSettings()
        
        homeTableView.appSettings = appSettings
        
        // Nav Logo
        let logoImageView = UIImageView(image: appSettings.branding.logoImage)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.frame = CGRect(x: 0, y: 0, width: appSettings.branding.logoImageSize.width, height: appSettings.branding.logoImageSize.height)
        logoImageView.isUserInteractionEnabled = true

        
        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.toggleBrandingViewExpanded(gesture:)))
        singleTapGesture.numberOfTapsRequired = 1
        logoImageView.addGestureRecognizer(singleTapGesture)
        
        navigationItem.titleView = logoImageView
        
        // Chat Button
        refreshChatButton()
    }
    
    func changeBranding(brandingType: BrandingType) {
        appSettings.branding = Branding(brandingType: brandingType)
        AppSettings.saveBranding(appSettings.branding)
        
        reloadViewForUpdatedSettings()
    }
    
    func toggleBrandingViewExpanded(gesture: UITapGestureRecognizer?) {
        brandingSwitcherView.setSwitcherViewHidden(!brandingSwitcherView.switcherViewHidden, animated: true)
    }
}

// MARK:- Chat

extension HomeViewController {

    func refreshChatButton() {
        chatButton?.removeFromSuperview()

        updateConfig()
        
        ASAPP.styles = appSettings.branding.styles
        ASAPP.debugLogLevel = .info
        
        chatButton = ASAPP.createChatButton(appCallbackHandler: callbackHandler,
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
    
    func homeTableViewDidTapDemoComponentsUI(homeTableView: HomeTableView) {
        showDemoComponents()
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
    
    func demoEnvironmentViewController(_ viewController: DemoEnvironmentViewController,
                                       didUpdateAppSettings appSettings: AppSettings) {
        self.appSettings = appSettings
    }
}

// MARK:- Handling ASAPP Actions

extension HomeViewController {
    
    func displayHandleActionAlert(_ action: String, userInfo: [String : Any]?) {
        var message = "The host app is responsible for handling this action appropriately."
        
        let userInfo = userInfo ?? [:]
        if !userInfo.isEmpty {
            if let jsonData = try? JSONSerialization.data(withJSONObject: userInfo, options: .prettyPrinted),
                let prettyJSON = NSString(data: jsonData, encoding: String.Encoding.utf8.rawValue) {
                message = "Data: \(prettyJSON)"
            }
        }
        
        let alert = UIAlertController(title: "Deep Link: \(action)",
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
        let chatViewController = ASAPP.createChatViewController(appCallbackHandler: callbackHandler)

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
    
    func showDemoComponents() {
        let demoComponentsVC = ComponentsDemoViewController()
        navigationController?.pushViewController(demoComponentsVC, animated: true)
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
        if let image = UIImage(named: "\(appSettings.defaultCompany)-\(imageName)") {
            return image
        }
        return nil
    }
}
