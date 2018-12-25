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
    // MARK: UI
    
    fileprivate let homeTableView = HomeTableView()
    
    fileprivate var chatButton: HelpButton?
    
    fileprivate var chatBadge = ChatBadge(frame: .zero)
    
    // MARK: - Initialization

    override func commonInit() {
        super.commonInit()
        
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
        switch chatButton?.segue {
        case .some(.push):
            guard navigationController?.topViewController is BaseViewController else {
                return
            }
            let chatViewController = ASAPP.createChatViewControllerForPushing(fromNotificationWith: userInfo)
            navigationController?.pushViewController(chatViewController, animated: true)
        case .some(.present):
            guard presentedViewController == nil else {
                return
            }
            let chatViewController = ASAPP.createChatViewControllerForPresenting(fromNotificationWith: userInfo)
            present(chatViewController, animated: true, completion: nil)
        case .none:
            return
        }
    }
    
    // MARK: - ASAPP Callbacks
    
    func createASAPPUser(customerIdentifier: String?) -> ASAPPUser {
        return ASAPPUser(
            userIdentifier: customerIdentifier,
            requestContextProvider: requestContextProvider)
    }
    
    func requestContextProvider(needsRefresh: Bool) -> [String: Any] {
        return AppSettings.shared.getContext()
    }

    // MARK: - Styling

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

extension HomeViewController: ASAPPDelegate {
    func chatViewControllerDidTapUserLoginButton() {
        let authViewController = AuthenticationViewController()
        let navController = NavigationController(rootViewController: authViewController)
        authViewController.showLogInButton = true
        authViewController.onSuccess = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            let user = strongSelf.createASAPPUser(customerIdentifier: AppSettings.shared.customerIdentifier)
            ASAPP.user = user
            authViewController.dismiss(animated: true, completion: nil)
        }
        
        (presentedViewController ?? self).present(navController, animated: true, completion: nil)
    }
    
    func chatViewControllerDidDisappear() {}
    
    func chatViewControlledDidTapDeepLink(name: String, data: [String: Any]?) {
        let completion = { [weak self] in
            if false == self?.handleAction(name, userInfo: data) {
                self?.displayHandleActionAlert(name, userInfo: data)
            }
        }
        
        switch AppSettings.shared.branding.appearanceConfig.segue {
        case .present:
            presentedViewController?.dismiss(animated: true, completion: completion)
        case .push:
            CATransaction.begin()
            CATransaction.setCompletionBlock(completion)
            navigationController?.popViewController(animated: true)
            CATransaction.commit()
        }
    }
    
    func chatViewControllerShouldHandleWebLink(url: URL) -> Bool {
        return true
    }
    
    func chatViewControllerDidReceiveChatEvent(name: String, data: [String: Any]?) {
        demoLog("Received chat event named", name, "with data:", data?.debugDescription ?? "nil")
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
        
        chatButton = HelpButton(
            config: ASAPP.config,
            user: ASAPP.user,
            presentingViewController: self)
        
        if let chatButton = chatButton {
            chatButton.segue = AppSettings.shared.branding.appearanceConfig.segue
            chatButton.title = AppSettings.shared.branding.appearanceConfig.strings[.helpButton] ?? "HELP"
            chatButton.frame = CGRect(origin: .zero, size: chatButton.intrinsicContentSize)
            let buttonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: chatButton.intrinsicContentSize.width, height: 34))
            buttonContainerView.addSubview(chatButton)
            let badgeSize: CGFloat = 18
            let chatBadge = ChatBadge(frame: CGRect(x: buttonContainerView.bounds.width - badgeSize * 0.75, y: -4, width: badgeSize, height: badgeSize))
            self.chatBadge = chatBadge
            buttonContainerView.addSubview(chatBadge)
            refreshChatBadge()
            let barButtonItem = UIBarButtonItem(customView: buttonContainerView)
            navigationItem.rightBarButtonItems = [barButtonItem]
        }
        
        demoLog("Chat Button Updated")
    }
    
    func refreshChatBadge() {
        ASAPP.getChatStatus(success: { [weak self] (unread, isLive) in
            DispatchQueue.main.async { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.updateBadge(unreadCount: unread, isLiveChat: isLive)
            }
        }, failure: { error in
            demoLog("Could not get chat status: \(error)")
        })
    }
    
    func updateBadge(unreadCount: Int, isLiveChat: Bool) {
        chatBadge.update(unread: unreadCount, isLiveChat: isLiveChat)
        let badgeSize = chatBadge.sizeThatFits(CGSize(width: .greatestFiniteMagnitude, height: chatBadge.bounds.height))
        let x = (chatBadge.superview?.bounds.width ?? 0) - badgeSize.width / 2
        chatBadge.frame = CGRect(x: x, y: chatBadge.frame.minY, width: badgeSize.width, height: chatBadge.frame.height)
    }
}

// MARK: - HomeTableViewDelegate

extension HomeViewController: HomeTableViewDelegate {
    fileprivate func updateAuth(completion: (() -> Void)? = nil) {
        guard let account = AppSettings.getMostRecentAccount(appId: AppSettings.shared.appId, apiHostName: AppSettings.shared.apiHostName) else {
            return
        }
        
        AppSettings.saveObject(account.username, forKey: .customerIdentifier)
        
        func flashAuthRow() {
            let indexPath = IndexPath(row: HomeTableView.SettingsRow.authentication.rawValue, section: HomeTableView.Section.settings.rawValue)
            DispatchQueue.main.asyncAfter(deadline: .now() + .milliseconds(300)) { [homeTableView] in
                homeTableView.tableView.selectRow(at: indexPath, animated: false, scrollPosition: .none)
                homeTableView.tableView.deselectRow(at: indexPath, animated: true)
            }
        }
        
        func showAuthTokenFetchError() {
            let alert = UIAlertController(title: "Could not fetch auth token for most recently used account",
                                          message: "Please check that the API Host and App Id are still correct.",
                                          preferredStyle: .alert)
            alert.addAction(UIAlertAction(title: "OK",
                                          style: .cancel,
                                          handler: nil))
            present(alert, animated: true, completion: nil)
        }
        
        guard let password = account.password else {
            AppSettings.deleteObject(forKey: .authToken)
            flashAuthRow()
            completion?()
            return
        }
        
        UIApplication.shared.isNetworkActivityIndicatorVisible = true
        AuthenticationAPI.requestAuthToken(apiHostName: AppSettings.shared.apiHostName, appId: AppSettings.shared.appId, userId: account.username, password: password) { (customerId, authToken, _) in
            UIApplication.shared.isNetworkActivityIndicatorVisible = false
            guard let authToken = authToken else {
                showAuthTokenFetchError()
                return
            }
            
            AppSettings.saveObject(authToken, forKey: .authToken)
            
            if let customerId = customerId {
                AppSettings.saveObject(customerId, forKey: .customerIdentifier)
            }
            
            flashAuthRow()
            completion?()
        }
    }
    
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
            self?.updateAuth(completion: self?.reloadViewForUpdatedSettings)
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
            self?.updateAuth(completion: self?.reloadViewForUpdatedSettings)
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
    
    func homeTableViewDidTapPushService(_ homeTableView: HomeTableView) {
        let pushServiceVC = PushServiceSelectionViewController()
        
        pushServiceVC.onFinish = { [weak self] (pushService) in
            if pushService == "APNS" {
                UIApplication.shared.registerForRemoteNotifications()
            } else {
                ASAPP.enablePushNotifications(with: pushService ?? "")
            }
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
        }
        
        navigationController?.pushViewController(pushServiceVC, animated: true)
    }
    
    func homeTableViewDidTapAuthentication(_ homeTableView: HomeTableView) {
        let authVC = AuthenticationViewController()
        authVC.onSuccess = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
        }
        authVC.onTapClearSavedSession = {
            ASAPP.clearSavedSession()
        }
        navigationController?.pushViewController(authVC, animated: true)
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
    
    @objc func dismissAnimated() {
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
