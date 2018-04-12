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
    
    fileprivate let homeTableView = HomeTableView()
    
    fileprivate var chatButton: ASAPPButton?
    
    fileprivate var chatBadge = ChatBadge(frame: .zero)
    
    // MARK: - Initialization

    override func commonInit() {
        super.commonInit()
        
        self.callbackHandler = { [weak self] (deepLink, deepLinkData) in
            guard let blockSelf = self else { return }
            
            if !blockSelf.handleAction(deepLink, userInfo: deepLinkData) {
                blockSelf.displayHandleActionAlert(deepLink, userInfo: deepLinkData)
            }
        }
        
        AppSettings.shared.branding = Branding(appearanceConfig: AppSettings.shared.appearanceConfig)
        
        updateASAPPSettings()
        
        homeTableView.delegate = self
        homeTableView.reloadData()
    }
    
    deinit {
        homeTableView.delegate = nil
    }
    
    // MARK: View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.addSubview(homeTableView)
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
            
            homeTableView.contentInset = UIEdgeInsets(top: visibleTop, left: 0, bottom: 0, right: 0)
            return
        }
    }
    
    // MARK: - ASAPPConfig
    
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
            
            demoLog("\n\nUpdated ASAPP Config:\n----------------------------------------\n\(updatesString)\n----------------------------------------")
            refreshChatButton()
        }
    }
    
    func showChat(fromNotificationWith userInfo: [AnyHashable: Any]? = nil) {
        guard presentedViewController == nil else {
            return
        }
        
        let chatViewController = ASAPP.createChatViewControllerForPresenting(
            fromNotificationWith: userInfo,
            appCallbackHandler: callbackHandler)
        
        present(chatViewController, animated: true, completion: nil)
    }
    
    // MARK: - ASAPP Callbacks
    
    func createASAPPUser(customerIdentifier: String?) -> ASAPPUser {
        return ASAPPUser(
            userIdentifier: customerIdentifier,
            requestContextProvider: requestContextProvider)
    }
    
    func requestContextProvider() -> [String: Any] {
        return AppSettings.shared.getContext()
    }
}

extension HomeViewController: ASAPPDelegate {
    func chatViewControllerDidTapUserLoginButton() {
        let loginViewController = LoginViewController()
        
        loginViewController.onUserLogin = { [weak self] (customerId) in
            guard let strongSelf = self, let customerId = customerId else {
                return
            }
            
            let user = strongSelf.createASAPPUser(customerIdentifier: customerId)
            ASAPP.user = user
        }
        
        let navController = NavigationController(rootViewController: loginViewController)
        if let presentedVC = presentedViewController {
            presentedVC.present(navController, animated: true, completion: nil)
        } else {
            present(navController, animated: true, completion: nil)
        }
    }
}

// MARK: - Styling

extension HomeViewController {
    
    override func reloadViewForUpdatedSettings() {
        super.reloadViewForUpdatedSettings()
        
        let logoSize = CGSize(width: 115, height: 34)
        
        let logoImageView = UIImageView(image: AppSettings.shared.branding.appearanceConfig.logoImage)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.frame = CGRect(x: 0, y: 0, width: logoSize.width, height: logoSize.height)
        
        let logoContainerView = UIView(frame: CGRect(x: 0, y: 0, width: logoImageView.frame.maxX, height: logoImageView.frame.height))
        logoContainerView.addSubview(logoImageView)
        
        navigationItem.titleView = logoContainerView
        
        refreshChatButton()
        homeTableView.reloadData()
    }
}

// MARK: - Chat

extension HomeViewController {

    func refreshChatButton() {
        chatButton?.removeFromSuperview()
        chatBadge.removeFromSuperview()

        ASAPP.styles = AppSettings.shared.branding.styles
        ASAPP.strings = AppSettings.shared.branding.strings
        ASAPP.views = AppSettings.shared.branding.views
        
        chatButton = ASAPP.createChatButton(appCallbackHandler: callbackHandler,
                                            presentingViewController: self)
        
        if let chatButton = chatButton {
            chatButton.frame = CGRect(x: 0, y: 0, width: 72, height: 34)
            let buttonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 72, height: 34))
            buttonContainerView.addSubview(chatButton)
            let badgeSize: CGFloat = 18
            let chatBadge = ChatBadge(frame: CGRect(x: buttonContainerView.bounds.width - badgeSize * 0.75, y: -4, width: badgeSize, height: badgeSize))
            self.chatBadge = chatBadge
            buttonContainerView.addSubview(chatBadge)
            refreshChatBadge()
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonContainerView)
        }
        
        demoLog("Chat Button Updated")
    }
    
    func refreshChatBadge() {
        ASAPP.getChatStatus { [weak self] (unread, isLive) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.chatBadge.update(unread: unread, isLiveChat: isLive)
                let badgeSize = strongSelf.chatBadge.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: strongSelf.chatBadge.bounds.height))
                let x = (strongSelf.chatBadge.superview?.bounds.width ?? 0) - badgeSize.width / 2
                strongSelf.chatBadge.frame = CGRect(x: x, y: strongSelf.chatBadge.frame.minY, width: badgeSize.width, height: strongSelf.chatBadge.frame.height)
            }
        }
    }
}

// MARK: - HomeTableViewDelegate

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
            ASAPP.clearSavedSession()
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
            ASAPP.clearSavedSession()
            if let strongSelf = self {
                strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
            }
        }
        
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    func homeTableViewDidTapRegionCode(_ homeTableView: HomeTableView) {
        let optionsVC = OptionsForKeyViewController()
        optionsVC.title = "Region Code"
        optionsVC.update(selectedOptionKey: AppSettings.Key.regionCode,
                         optionsListKey: AppSettings.Key.regionCodeList)
        optionsVC.onSelection = { [weak self] (_) in
            ASAPP.clearSavedSession()
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
        customerIdVC.onTapClearSavedSession = {
            ASAPP.clearSavedSession()
        }
        navigationController?.pushViewController(customerIdVC, animated: true)
    }
    
    func homeTableViewDidTapAuthToken(_ homeTableView: HomeTableView) {
        let viewController = AuthTokenViewController()
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func homeTableViewDidTapAppearance(_ homeTableView: HomeTableView) {
        let viewController = AppearanceViewController()
        viewController.onSelection = { [weak self] config in
            if let strongSelf = self {
                AppSettings.shared.branding = Branding(appearanceConfig: config)
                strongSelf.reloadViewForUpdatedSettings()
                strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
            }
        }
        navigationController?.pushViewController(viewController, animated: true)
    }
    
    func homeTableViewDidTapBillDetails(homeTableView: HomeTableView) {
        showBillDetails()
    }
    
    func homeTableViewDidTapHelp(homeTableView: HomeTableView) {
        showChat()
    }
    
    func homeTableViewDidUpdateDemoSettings(homeTableView: HomeTableView) {
        refreshChatButton()
    }
    
    func homeTableViewDidTapDemoComponentsUI(homeTableView: HomeTableView) {
        showUseCasePreview()
    }
}

// MARK: - Handling ASAPP Actions

extension HomeViewController {
    
    func displayHandleActionAlert(_ action: String, userInfo: [String: Any]?) {
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
    
    func handleAction(_ action: String, userInfo: [String: Any]?) -> Bool {
        
        var handled: Bool
        
        switch action {
        case "tv":
            handled = showViewController("tv", title: "Television")
            
        case "troubleshoot", "internet-troubleshoot":
            handled = showViewController("troubleshoot", title: "Troubleshooter")
            
        case "internet":
            handled = showViewController("internet", title: "Internet")
            
        case "restart":
            handled = showViewController("restart", title: "Device Restart")
            
        case "payment":
            handled = showViewController("payment", title: "Payments")
            
        case "showTechMap":
            handled = showViewController("tech-map", title: "Location")
            
        case "understandBill":
            showBillDetails()
            handled = true
            
        default:
            handled = false
        }
        
        return handled
    }
}

// MARK: - Navigation to View Controllers

extension HomeViewController {
    func showBillDetails() {
        let billDetailsVC = BillDetailsViewController()
        navigationController?.pushViewController(billDetailsVC, animated: true)
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
