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
    
    // MARK: Private Properties
    
    fileprivate var callbackHandler: ASAPPAppCallbackHandler!

    // MARK: UI
    
    fileprivate let brandingSwitcherView = BrandingSwitcherView()
    
    fileprivate let homeTableView = HomeTableView()
    
    fileprivate var chatButton: ASAPPButton?
    
    // MARK:- Initialization

    override func commonInit() {
        super.commonInit()
        
        self.callbackHandler = { [weak self] (deepLink, deepLinkData) in
            guard let blockSelf = self else { return }
            
            if !blockSelf.handleAction(deepLink, userInfo: deepLinkData) {
                blockSelf.displayHandleActionAlert(deepLink, userInfo: deepLinkData)
            }
        }
        
        updateASAPPSettings()
        
        homeTableView.delegate = self
        homeTableView.reloadData()
        
        brandingSwitcherView.didSelectBrandingType = { [weak self] (type) in
            self?.changeBranding(brandingType: type)
        }
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
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        updateASAPPSettings()
        homeTableView.reloadData()
    }
    
    // MARK: Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        homeTableView.frame = view.bounds
        
        guard #available(iOS 11, *) else {
            var visibleTop: CGFloat = 0.0
            if let navBar = navigationController?.navigationBar {
                visibleTop = navBar.frame.maxY
            }
            
            let visibleHeight = view.bounds.height - visibleTop
            brandingSwitcherView.frame = CGRect(x: 0, y: visibleTop, width: view.bounds.width, height: visibleHeight)
            
            homeTableView.contentInset = UIEdgeInsets(top: visibleTop, left: 0, bottom: 0, right: 0)
            return
        }
        
        let topInset = view.safeAreaInsets.top
        brandingSwitcherView.frame = CGRect(x: 0, y: topInset, width: view.bounds.width, height: view.bounds.height - topInset)
    }
    
    // MARK:- ASAPPConfig
    
    func updateASAPPSettings() {
        var didUpdateConfig = false
        
        let apiHostName = AppSettings.shared.apiHostName
        let appId = AppSettings.shared.appId
        if ASAPP.config == nil || ASAPP.config.apiHostName != apiHostName || ASAPP.config.appId != appId {
            let config = ASAPPConfig(appId: appId,
                                     apiHostName: apiHostName,
                                     clientSecret: "ASAPP_DEMO_CLIENT_ID")
            ASAPP.initialize(with: config)
            didUpdateConfig = true
        }
        
        var didUpdateUser = false
        let customerId = AppSettings.shared.customerIdentifier
        let shouldBeAnonymous = AppSettings.shared.customerIdentifier == nil
        if ASAPP.user == nil || didUpdateConfig || ASAPP.user.isAnonymous != shouldBeAnonymous
            || (ASAPP.user.userIdentifier != customerId && !ASAPP.user.isAnonymous) {
            ASAPP.user = createASAPPUser(customerIdentifier: customerId)
            didUpdateUser = true
        }
        
        if didUpdateConfig || didUpdateUser {
            let updatesString = [
                "APIHostName:   \(apiHostName)",
                "AppId:         \(appId)",
                "CustomerId:    \(customerId ?? "nil")"
            ].joined(separator: "\n")
            
            DemoLog("\n\nUpdated ASAPP Config:\n----------------------------------------\n\(updatesString)\n----------------------------------------")
            refreshChatButton()
        }
    }
    
    func showChat(fromNotificationWith userInfo: [AnyHashable : Any]? = nil) {
        guard presentedViewController == nil else {
            return
        }
        
        let chatViewController = ASAPP.createChatViewControllerForPresenting(
            fromNotificationWith: userInfo,
            appCallbackHandler: callbackHandler)
        
        present(chatViewController, animated: true, completion: nil)
    }
    
    // MARK:- ASAPP Callbacks
    
    func createASAPPUser(customerIdentifier: String?) -> ASAPPUser {
        let user = ASAPPUser(
            userIdentifier: customerIdentifier,
            requestContextProvider: requestContextProvider,
            userLoginHandler: { [weak self] (_ onUserLogin: @escaping ASAPPUserLoginHandlerCompletion) in
                
            let loginViewController = LoginViewController()
            
            loginViewController.onUserLogin = { [weak self] (customerId) in
                guard let strongSelf = self, let customerId = customerId else {
                    return
                }
                
                let user = strongSelf.createASAPPUser(customerIdentifier: customerId)
                onUserLogin(user)
            }
            
            let navController = NavigationController(rootViewController: loginViewController)
            if let presentedVC = self?.presentedViewController {
                presentedVC.present(navController, animated: true, completion: nil)
            } else {
                self?.present(navController, animated: true, completion: nil)
            }
        })
        
        return user
    }
    
    func requestContextProvider() -> [String : Any] {
        return AppSettings.shared.getContext()
    }
}

// MARK:- Styling

extension HomeViewController {
    
    override func reloadViewForUpdatedSettings() {
        super.reloadViewForUpdatedSettings()
        
        // Nav Logo
        let logoImageView = UIImageView(image: AppSettings.shared.branding.logoImage)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.frame = CGRect(x: 0, y: 0, width: AppSettings.shared.branding.logoImageSize.width, height: AppSettings.shared.branding.logoImageSize.height)
        logoImageView.isUserInteractionEnabled = true
        
        let logoContainerView = UIView(frame: CGRect(x: 0, y: 0, width: logoImageView.frame.width, height: logoImageView.frame.height))
        logoContainerView.addSubview(logoImageView)
        logoContainerView.isUserInteractionEnabled = true

        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.toggleBrandingViewExpanded(gesture:)))
        singleTapGesture.numberOfTapsRequired = 1
        logoImageView.addGestureRecognizer(singleTapGesture)
        
        navigationItem.titleView = logoContainerView
        
        refreshChatButton()
        homeTableView.reloadData()
    }
    
    func changeBranding(brandingType: BrandingType) {
        AppSettings.shared.branding = Branding(brandingType: brandingType)
        
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

        ASAPP.styles = AppSettings.shared.branding.styles
        ASAPP.strings = AppSettings.shared.branding.strings
        ASAPP.views = AppSettings.shared.branding.views
        
        chatButton = ASAPP.createChatButton(appCallbackHandler: callbackHandler,
                                            presentingViewController: self)
        
        if let chatButton = chatButton {
            chatButton.frame = CGRect(x: 0, y: 0, width: 72, height: 34)
            let buttonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 72, height: 34))
            buttonContainerView.addSubview(chatButton)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonContainerView)
        }
        
        DemoLog("Chat Button Updated")
    }
}

// MARK:- HomeTableViewDelegate

extension HomeViewController: HomeTableViewDelegate {
    
    func homeTableViewDidTapUserName(_ homeTableView: HomeTableView) {
        let viewController = AccountViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func homeTableViewDidTapAppId(_ homeTableView: HomeTableView) {
        let optionsVC = OptionsForKeyViewController()
        optionsVC.title = "App Id"
        optionsVC.update(selectedOptionKey: AppSettings.Key.appId,
                         optionsListKey: AppSettings.Key.appIdList)
        optionsVC.onSelection = { [weak self] (_) in
            if let strongSelf = self {
                strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
            }
        }
        
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    func homeTableViewDidTapAPIHostName(_ homeTableView: HomeTableView) {
        let optionsVC = OptionsForKeyViewController()
        optionsVC.title = "API Host Name"
        optionsVC.update(selectedOptionKey: AppSettings.Key.apiHostName,
                         optionsListKey: AppSettings.Key.apiHostNameList)
        optionsVC.onSelection = { [weak self] (_) in
            if let strongSelf = self {
                strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
            }
        }
        
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    func homeTableViewDidTapCustomerIdentifier(_ homeTableView: HomeTableView) {
        let customerIdVC = CustomerIdViewController()
        customerIdVC.onSelection = { [weak self] (customerIdentifier) in
            if let strongSelf = self {
                strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
            }
        }
        navigationController?.pushViewController(customerIdVC, animated: true)
    }
    
    func homeTableViewDidTapAuthToken(_ homeTableView: HomeTableView) {
        let viewController = AuthTokenViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func homeTableViewDidTapBillDetails(homeTableView: HomeTableView) {
        showBillDetails()
    }
    
    func homeTableViewDidTapHelp(homeTableView: HomeTableView) {
        showChat()
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
        showUseCasePreview()
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
    
    func showSpeechToTextViewController() {
        
        if #available(iOS 10.0, *) {
            let vc = SpeechToTextViewController()
            navigationController?.pushViewController(vc, animated: true)
        } else {
            let alert = UIAlertController(title: "Only Available on iOS 10",
                                          message: "You must update your operating system to use this feature.",
                                          preferredStyle: .alert)
            present(alert, animated: true, completion: nil)
        }
        
    }
    
    func showBillDetails() {
        let billDetailsVC = BillDetailsViewController()
        navigationController?.pushViewController(billDetailsVC, animated: true)
    }
    
    func showAccountsPage() {
//        let accountsVC = AccountsViewController(appSettings: appSettings)
//        accountsVC.currentAccount = currentAccount
//        accountsVC.delegate = self
//        navigationController?.pushViewController(accountsVC, animated: true)
    }
    
    func showEnvironmentSettings() {
//        let environmentVC = DemoEnvironmentViewController(appSettings: appSettings)
//        environmentVC.delegate = self
//        navigationController?.pushViewController(environmentVC, animated: true)
    }
    
    func showUseCasePreview() {
        let useCasePreviewVC = TemplateServerPreviewViewController()
        useCasePreviewVC.navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .done, target: self, action: #selector(HomeViewController.dismissAnimated))
        let nc = UINavigationController(rootViewController: useCasePreviewVC)
        present(nc, animated: true, completion: nil)
    }
    
    func dismissAnimated() {
        dismiss(animated: true, completion: nil)
    }
    
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
        if let image = UIImage(named: "\(AppSettings.shared.appId)-\(imageName)") {
            return image
        }
        return nil
    }
}
