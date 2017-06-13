//
//  ActionHandler.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 6/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit
import SafariServices


/// Returns true if the action was performed.
/// If false, a debug message will be returned.
typealias ActionHandlerCompletion = (Bool, String) -> Void


// MARK:- ActionHandler

class ActionHandler: NSObject {
    
    enum ComponentViewPresentationStyle {
        case modal
        case push
    }
    
    // MARK: Properties
    
    weak var viewController: UIViewController?
    
    var conversationManager: ConversationManager
    
    var componentViewPresentationStyle = ComponentViewPresentationStyle.modal
    
    var componentViewControllerDelegate: ComponentViewControllerDelegate?
    
    // MARK: Init
    
    init(viewController: UIViewController, conversationManager: ConversationManager) {
        self.viewController = viewController
        self.conversationManager = conversationManager
        super.init()
    }
}

// MARK:- Action Handling

extension ActionHandler {
    
    func performAction(_ action: Action?,
                       buttonItem: ButtonItem? = nil,
                       quickReply: QuickReply? = nil,
                       message: ChatMessage? = nil,
                       root: Component? = nil,
                       queueNetworkRequestIfNoConnection: Bool = false,
                       completion: ActionHandlerCompletion? = nil) {
        guard let action = action else {
            completion?(false, "Missing action")
            return
        }
        
        if action.performsUIBlockingNetworkRequest &&
            !conversationManager.isConnected(retryConnectionIfNeeded: true) &&
            !queueNetworkRequestIfNoConnection {
            DebugLog.d(caller: self, "No connection to perform action: \(action)")
            completion?(false, "No network connection")
            return
        }
        
        switch action.type {
        case .api:
            performAPIAction(action as? APIAction, root: root, completion: completion)
            break
            
        case .componentView:
            performComponentViewAction(action as? ComponentViewAction, completion: completion)
            break
            
        case .deepLink:
            performDeepLinkAction(action as? DeepLinkAction, completion: completion)
            break
            
        case .finish:
            performFinishAction(action as? FinishAction)
            break
            
        case .http:
            performHTTPAction(action as? HTTPAction, completion: completion)
            break
            
        case .treewalk:
            performTreewalkAction(action as? TreewalkAction, completion: completion)
            break
            
        case .userLogin:
            performUserLoginAction(action as? UserLoginAction, completion: completion)
            break
            
        case .web:
            performWebAction(action as? WebPageAction, completion: completion)
            break
            
        case .unknown: /* No-op */ break
        }
    }
}

// MARK: Specific Action Handling

fileprivate extension ActionHandler {
    
    func performAPIAction(_ action: APIAction?,
                          root: Component?,
                          completion: ActionHandlerCompletion?) {
        guard let action = action else { return }
        
        let data = generateDataForRequest(action: action, root: root)
        conversationManager.sendRequestForAPIAction(action, data: data) { (response) in
            
        }
        
    }
    
    func performComponentViewAction(_ action: ComponentViewAction?,
                                    completion: ActionHandlerCompletion?) {
        guard let action = action else { return }
        
        let componentViewController = ComponentViewController(componentName: action.name)
        componentViewController.delegate = componentViewControllerDelegate
        
        let navigationController = ComponentNavigationController(rootViewController: componentViewController)
        navigationController.displayStyle = action.displayStyle
        viewController?.present(navigationController, animated: true, completion: nil)
    }
    
    func performDeepLinkAction(_ action: DeepLinkAction?,
                               completion: ActionHandlerCompletion?) {
        guard let action = action else { return }
        
    }
    
    func performFinishAction(_ action: FinishAction?) {
        guard let action = action else { return }
        
        
    }
    
    func performHTTPAction(_ action: HTTPAction?,
                           completion: ActionHandlerCompletion?) {
        guard let action = action else { return }
        
    }
    
    func performTreewalkAction(_ action: TreewalkAction?,
                               completion: ActionHandlerCompletion?) {
        guard let action = action else { return }
        
    }
    
    func performUserLoginAction(_ action: UserLoginAction?,
                                completion: ActionHandlerCompletion?) {
        guard let action = action else { return }
        
    }
    
    func performWebAction(_ action: WebPageAction?,
                          completion: ActionHandlerCompletion?) {
        guard let url = action?.url else { return }
        
        // SFSafariViewController
        if #available(iOS 9.0, *) {
            if let urlScheme = url.scheme {
                if ["http", "https"].contains(urlScheme) {
                    let safariVC = SFSafariViewController(url: url)
                    viewController?.present(safariVC, animated: true, completion: nil)
                    return
                } else {
                    DebugLog.w("URL is missing http/https url scheme: \(url)")
                }
            }
        }
        
        // Open in Safari
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
        }
    }
}

// MARK:- Utility Methods

fileprivate extension ActionHandler {
    
    func generateDataForRequest(action: Action, root: Component?) -> [String : Any]? {
        var requestData = [String : Any]()
        requestData.add(action.data)
        if let root = root {
            requestData.add(root.getData())
        }
        
        if requestData.isEmpty {
            return nil
        }
        
        return requestData
    }
}
