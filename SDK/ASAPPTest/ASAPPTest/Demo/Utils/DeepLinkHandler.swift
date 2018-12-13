//
//  DeepLinkHandler.swift
//  ASAPPTest
//
//  Created by Shehryar Hussain on 12/6/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation
import ASAPP

class DeepLinkHandler {
    
    static let shared = DeepLinkHandler()
    
    func handleDeepLink(url: URL) {
        guard let components = NSURLComponents(url: url, resolvingAgainstBaseURL: true),
            let params = components.queryItems,
            let intent = params[0].value else {
                print("Invalid URL or query items")
                return
        }
        
        let intentCode = params[0].name
        if intentCode != "intentCode" {
            return
        }
        
        let chatViewController = ASAPP.createChatViewControllerForPushing(withIntent: ["Code": intent])
        pushViewController(viewController: chatViewController)
    }
    
    func pushViewController(viewController: UIViewController) {
        guard let rootViewController = UIApplication.shared.keyWindow?.rootViewController as? NavigationController else { return }
        rootViewController.pushViewController(viewController, animated: true)
    }
    
}
