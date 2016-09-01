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
    
    let credentials = Credentials(withCompany: "text-rex",//"srs-api-dev",
                                  userToken: "vs-cct-c8",
                                  isCustomer: true,
                                  targetCustomerToken: nil)
    
    //*/
     
//    let credentials = Credentials(withCompany: "vs-dev",
//                                  userToken: "vs-cct-c8",
//                                  isCustomer: true,
//                                  targetCustomerToken: nil)
    
    
    var chatButton: ASAPPButton?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "Home"
        imageView.image = UIImage(named: "home")
        
        chatButton = ASAPPButton(withCredentials: credentials,
                                 presentingViewController: self,
                                 styles: nil,
                                 callback: { [weak self] (action, userInfo) in
                                    self?.handleAction(action, userInfo: userInfo)
                                })
        chatButton?.hideUntilAnimateInIsCalled()
        
        if let chatButton = chatButton {
            chatButton.frame = CGRect(x: 0, y: 18, width: 50, height: 50)
            let buttonContainerView = UIView(frame: CGRect(x: 0, y: 0, width: 50, height: 70))
            buttonContainerView.addSubview(chatButton)
            navigationItem.rightBarButtonItem = UIBarButtonItem(customView: buttonContainerView)
            
            chatButton.animateIn(afterDelay: 1.5)
        }
        
        navigationItem.leftBarButtonItem = UIBarButtonItem(barButtonSystemItem: .Add, target: self, action: #selector(ComcastHomeViewController.showTestViewController))
    }
    
    func showTestViewController() {
        navigationController?.pushViewController(ChatsListViewController(), animated: true)
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
            
        default: break
        }
    }
}
