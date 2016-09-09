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
    
    var userToken = "vs-cct-c0" {
        didSet {
            updateUserButton()
            refreshChatButton()
        }
    }
    
//    let credentials = Credentials(withCompany: "vs-dev",
//                                  userToken: "vs-cct-c8",
//                                  isCustomer: true,
//                                  targetCustomerToken: nil)
    
    
    var chatButton: ASAPPButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        imageView.image = UIImage(named: "home")
        
        refreshChatButton()
        chatButton?.hideUntilAnimateInIsCalled()
        chatButton?.animateIn(afterDelay: 1.0)
        
        updateUserButton()
        
//        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ComcastHomeViewController.showTestViewController))
    }
    
    func showTestViewController() {
        navigationController?.pushViewController(ChatsListViewController(), animated: true)
    }
    
    func changeUser() {
        let changeUserVC = ComcastChangeUserViewController()
        changeUserVC.onUserSelection = { (user) in
            if let user = user {
                self.userToken = user
            }
            self.dismissViewControllerAnimated(true, completion: nil)
        }
        let nc = UINavigationController(rootViewController: changeUserVC)
        if let navBar = navigationController?.navigationBar {
            nc.navigationBar.barTintColor = navBar.barTintColor
            nc.navigationBar.tintColor = navBar.tintColor
            nc.navigationBar.barStyle = navBar.barStyle
        }
        presentViewController(nc, animated: true, completion: nil)
    }
    
    func updateUserButton() {
        navigationItem.leftBarButtonItem = UIBarButtonItem(title: userToken,
                                                           style: .Plain, target: self, action: #selector(ComcastHomeViewController.changeUser))
    }
    
    func refreshChatButton() {
        chatButton?.removeFromSuperview()
        
        let credentials = Credentials(withCompany: "text-rex",//"srs-api-dev",
            userToken: userToken,
            isCustomer: true,
            targetCustomerToken: nil)
        
        chatButton = ASAPPButton(withCredentials: credentials,
                                 presentingViewController: self,
                                 styles: nil,
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
            break
            
        case "troubleshoot":
            if let userInfo = userInfo, let service = userInfo["service"] as? String {
                switch service {
                case "internet":
                    showInternetTroubleshoot()
                    break
                    
                default:
                    showTvTroubleshoot()
                    break
                }
            } else {
                showTvTroubleshoot()
            }
            break
            
        case "internet":
            showInternetHome()
            break
            
        case "internet-troubleshoot":
            showInternetTroubleshoot()
            break
            
        case "restart":
            showRestartDevice()
            break
            
        case "payment":
            showPaymentScreen()
            break
            
        case "showTechMap":
            showTechnicianMap()
            break
            
        default: break
        }
    }
}
