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
    
    fileprivate var contextBlock: ASAPPRequestContextProvider!
    fileprivate var callbackHandler: ASAPPAppCallbackHandler!

    // MARK: UI
    
    fileprivate let brandingSwitcherView = BrandingSwitcherView()
    
    fileprivate let homeTableView = HomeTableView()
    
    fileprivate var chatButton: ASAPPButton?
    
    // MARK:- Initialization

    override func commonInit() {
        super.commonInit()
        
        self.contextBlock = {
            return AppSettings.shared.getContext()
        }
        self.callbackHandler = { [weak self] (deepLink, deepLinkData) in
            guard let blockSelf = self else { return }
            
            if !blockSelf.handleAction(deepLink, userInfo: deepLinkData) {
                blockSelf.displayHandleActionAlert(deepLink, userInfo: deepLinkData)
            }
        }
        
        updateASAPPSettings(updateConfig: true, updateUser: true)
        
        homeTableView.delegate = self
        homeTableView.reloadData()
        
        brandingSwitcherView.didSelectBrandingType = { [weak self] (type) in
            self?.changeBranding(brandingType: type)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .play, target: self, action: #selector(HomeViewController.showSpeechToTextViewController))
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
        
        updateASAPPSettings(updateConfig: true, updateUser: false)
        homeTableView.reloadData()
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
    
    func updateASAPPSettings(updateConfig: Bool, updateUser: Bool) {
        if updateConfig {
            let config = ASAPPConfig(appId: AppSettings.shared.appId,
                                     apiHostName: AppSettings.shared.apiHostName,
                                     clientSecret: "ASAPP_DEMO_CLIENT_ID")
            
            ASAPP.initialize(with: config)
        }
        
        if updateUser {
            let user = ASAPPUser(userIdentifier: AppSettings.shared.customerIdentifier,
                                 requestContextProvider: contextBlock)
            
            ASAPP.user = user
        }
        
        var updates = [String]()
        if updateConfig { updates.append("config") }
        if updateUser { updates.append("user") }
        
        DemoLog("Updates for: \(updates.joined(separator: ", ")):\n----------------------------\nAPI Host Name: \(AppSettings.shared.apiHostName)\nApp Id:        \(AppSettings.shared.appId)\nCustomer Id:   \(AppSettings.shared.customerIdentifier ?? "nil")\n----------------------------")
        
        refreshChatButton()
    }
    
    func showChat(fromNotificationWith userInfo: [AnyHashable : Any]? = nil) {
        guard presentedViewController == nil else {
            return
        }
        
        let chatViewController = ASAPP.createChatViewController(fromNotificationWith: userInfo,
                                                                appCallbackHandler: callbackHandler)
        
        present(chatViewController, animated: true, completion: nil)
    }
}

// MARK:- Styling 

extension HomeViewController {
    
    override func reloadViewForUpdatedSettings() {
        super.reloadViewForUpdatedSettings()
        
        // Nav Logo
        let logoImageView = UIImageView(image: AppSettings.shared.branding.logoImage)
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.frame = CGRect(x: 0, y: 0,
                                     width: AppSettings.shared.branding.logoImageSize.width,
                                     height: AppSettings.shared.branding.logoImageSize.height)
        logoImageView.isUserInteractionEnabled = true

        let singleTapGesture = UITapGestureRecognizer(target: self, action: #selector(HomeViewController.toggleBrandingViewExpanded(gesture:)))
        singleTapGesture.numberOfTapsRequired = 1
        logoImageView.addGestureRecognizer(singleTapGesture)
        
        navigationItem.titleView = logoImageView
        
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
        ASAPP.debugLogLevel = .info
        
        chatButton = ASAPP.createChatButton(appCallbackHandler: callbackHandler,
                                            presentingViewController: self)
        
        if let chatButton = chatButton {
            chatButton.frame = CGRect(x: 0, y: 25, width: 65, height: 65)
            let buttonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 65, height: 88))
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
        
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    func homeTableViewDidTapAPIHostName(_ homeTableView: HomeTableView) {
        let optionsVC = OptionsForKeyViewController()
        optionsVC.title = "API Host Name"
        optionsVC.update(selectedOptionKey: AppSettings.Key.apiHostName,
                         optionsListKey: AppSettings.Key.apiHostNameList)
        
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    func homeTableViewDidTapCustomerIdentifier(_ homeTableView: HomeTableView) {
        let optionsVC = OptionsForKeyViewController()
        optionsVC.title = "Customer Id"
        optionsVC.randomEntryPrefix = "test-user-"
        optionsVC.update(selectedOptionKey: AppSettings.Key.customerIdentifier,
                         optionsListKey: AppSettings.Key.customerIdentifierList)
        optionsVC.rightBarButtonItemTitle = "Anonymous"
        optionsVC.onRightBarButtonItemTap = { [weak self] in
            guard let strongSelf = self else {
                return
            }
            
            AppSettings.deleteObject(forKey: AppSettings.Key.customerIdentifier)
            strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
            strongSelf.updateASAPPSettings(updateConfig: false, updateUser: true)
        }
        optionsVC.onSelection = { [weak self] (customerIdentifier) in
            self?.updateASAPPSettings(updateConfig: false, updateUser: true)
        }
        
        navigationController?.pushViewController(optionsVC, animated: true)
    }
    
    func homeTableViewDidTapAuthToken(_ homeTableView: HomeTableView) {
        let viewController = TextInputViewController()
        viewController.title = "Auth Token"
        viewController.instructionText = "Set Auth Token"
        viewController.onFinish = { [weak self] (text) in
            guard !text.isEmpty, let strongSelf = self else {
                    return
            }
            
            AppSettings.saveObject(text, forKey: AppSettings.Key.authToken)
            strongSelf.navigationController?.popToViewController(strongSelf, animated: true)
        }
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
