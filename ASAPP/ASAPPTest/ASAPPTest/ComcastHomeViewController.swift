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

    ///** SRS Dev Server

    //*/
    
//    let credentials = Credentials(withCompany: "vs-dev",
//                                  userToken: "vs-cct-c8",
//                                  isCustomer: true,
//                                  targetCustomerToken: nil)
    
    
    var chatButton: ASAPPButton?
    
    let versionLabel = UILabel()
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = UIImage(named: "home")
        
        refreshChatButton()
        chatButton?.hideUntilAnimateInIsCalled()
        chatButton?.animateIn(afterDelay: 1.0)
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ComcastHomeViewController.showTestViewController))
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: "Create New User",
                                                           style: .Plain, target: self, action: #selector(ComcastHomeViewController.promptToChangeUser))
        
        versionLabel.textColor = UIColor(red:0.226,  green:0.605,  blue:0.852, alpha:1)
        versionLabel.font = UIFont.boldSystemFontOfSize(10)
        let version = NSBundle.mainBundle().objectForInfoDictionaryKey("CFBundleShortVersionString") as! String
        let build = NSBundle.mainBundle().objectForInfoDictionaryKey(kCFBundleVersionKey as String) as! String
        versionLabel.text = "\(version) (\(build))"
        versionLabel.sizeToFit()
        if let navView = navigationController?.view {
            var versionFrame = versionLabel.frame
            versionFrame.origin.x = 110
            versionFrame.origin.y = 0
            versionFrame.size.height = 20
            versionLabel.frame = versionFrame
            navView.addSubview(versionLabel)
        }
    }
    
    func showTestViewController() {
        navigationController?.pushViewController(ChatsListViewController(), animated: true)
    }
    
    // MARK:- Chat Button
    
    func refreshChatButton() {
        chatButton?.removeFromSuperview()
        
        let userToken = existingUserToken() ?? createNewUserToken()
        
        let credentials = Credentials(withCompany: "text-rex",//"srs-api-dev",
            userToken: userToken,
            isCustomer: true,
            targetCustomerToken: nil)
        
        chatButton = ASAPPButton(withCredentials: credentials,
                                 presentingViewController: self,
                                 styles: ASAPPStyles.comcastStyles(),
                                 callback: { [weak self] (action, userInfo) in
                                    self?.handleAction(action, userInfo: userInfo)
            })
        
        if let chatButton = chatButton {
            chatButton.frame = CGRect(x: 0, y: 25, width: 65, height: 65)
            let buttonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 65, height: 88))
            buttonContainerView.addSubview(chatButton)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonContainerView)
        }
    }
    
    // MARK:- User Management
    
    func promptToChangeUser() {
        let alert = UIAlertController(title: "Create a new user?",
                                      message: "This will delete your existing conversation and replace it with that of a new user.",
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Create New User", style: .Default, handler: { (action) in
            self.createNewUserToken()
            self.refreshChatButton()
            self.showNewUserSuccess()
        }))
        
        alert.addAction(UIAlertAction(title: "Cancel", style: .Cancel, handler: { (action) in
            // No action
        }))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    func showNewUserSuccess() {
        let alert = UIAlertController(title: "Ok!",
                                      message: "Your new user is ready.",
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Done", style: .Cancel, handler: nil))
        
        presentViewController(alert, animated: true, completion: nil)
    }
    
    let USER_TOKEN_STORAGE_KEY = "ASAPP_DEMO_USER_TOKEN"
    
    func createNewUserToken() -> String {
        let freshUserToken = "vs-cct-c\(NSDate().timeIntervalSince1970)"
        
        NSUserDefaults.standardUserDefaults().setObject(freshUserToken, forKey: USER_TOKEN_STORAGE_KEY)
        
        return freshUserToken
    }
    
    func existingUserToken() -> String? {
        return NSUserDefaults.standardUserDefaults().stringForKey(USER_TOKEN_STORAGE_KEY)
    }
}

// MARK:- Deep-link

extension ComcastHomeViewController {

    internal func showViewControllerWithImage(imageName: String, title: String?) {
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
        if UIScreen.mainScreen().bounds.size.width > 400 {
            showViewControllerWithImage("payment-screen-6plus", title: "Make Payment")
        } else {
            showViewControllerWithImage("payment-screen-6", title: "Make Payment")
        }
    }
    
    func showTechnicianMap() {
        showViewControllerWithImage("tech-map-screen", title: "Where's my Technician?")
    }
    
    func handleAction(action: String, userInfo: [String : AnyObject]?) {
        
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
                                      preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Cancel, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
    }
}
