//
//  ActionHandler.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 6/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit
import SafariServices

// MARK:- ActionHandler

class ActionHandler: NSObject {
    
    class func actionCanBeHandled(_ action: Action?,
                                  conversationManager: ConversationManager,
                                  queueNetworkRequestIfNoConnection: Bool = false) -> Bool {
        guard let action = action else {
            return false
        }
        
        if action.performsUIBlockingNetworkRequest &&
            !conversationManager.isConnected(retryConnectionIfNeeded: true) &&
            !queueNetworkRequestIfNoConnection {
            DebugLog.d(caller: self, "No connection to perform action: \(action)")
            return false
        }
        
        return true
    }
}

// MARK:- APIAction

extension ActionHandler {
    
    class func handleAPIAction(_ action: Action?,
                               root: Component?,
                               conversationManager: ConversationManager,
                               completion: @escaping APIActionResponseHandler) {
        guard let action = action as? APIAction else { return }
                
        conversationManager.sendRequestForAPIAction(action, formData: root?.getData(), completion: completion)
    }
}

// MARK:- Component View Action

extension ActionHandler {
    
    class func handleComponentViewAction(_ action: Action?,
                                         delegate: ComponentViewControllerDelegate?,
                                         from viewController: UIViewController) {
        guard let action = action as? ComponentViewAction else { return }
        
        let componentViewController = ComponentViewController(componentName: action.name)
        componentViewController.delegate = delegate
        
        let navigationController = ComponentNavigationController(rootViewController: componentViewController)
        navigationController.displayStyle = action.displayStyle
        viewController.present(navigationController, animated: true, completion: nil)
    }
}

// MARK:- Deep Link Action

extension ActionHandler {
    
    class func sendRequestForDeepLinkAction(_ action: Action?,
                                            button: Any? = nil,
                                            conversationManager: ConversationManager) {
        guard let action = action as? DeepLinkAction else { return }
        
        conversationManager.sendRequestForDeepLinkAction(action, with: getTitleFrom(button) ?? "")
    }
}

// MARK:- HTTP Action

extension ActionHandler {
    
    class func handleHTTPAction(_ action: Action?) {
        guard let action = action as? HTTPAction else { return }
        
        // MITCH MITCH TODO
        
    }
}

// MARK:- Treewalk

extension ActionHandler {
    
    typealias TreewalkCompletionBlock = (_ success: Bool) -> Void
    
    class func handleTreewalkAction(_ action: Action?,
                                    from button: Any?,
                                    message: ChatMessage?,
                                    simpleStore: ChatSimpleStore,
                                    conversationManager: ConversationManager,
                                    completion: TreewalkCompletionBlock?) {
        guard let action = action as? TreewalkAction else { return }
        
        conversationManager.sendRequestForTreewalkAction(action,
                                                         with: getTitleFrom(button) ?? action.messageText ?? "",
                                                         parentMessage: message,
                                                         originalSearchQuery: simpleStore.getSRSOriginalSearchQuery(),
                                                         completion: { (message, _, _) in
                                                            completion?(message.type == .Response)
        })
        
    }
}

// MARK:- WebPageAction

extension ActionHandler {
    
    class func handleWebPageAction(_ action: Action?, from viewController: UIViewController?) {
        guard let action = action as? WebPageAction else { return }
        
        // SFSafariViewController
        if #available(iOS 9.0, *) {
            if let viewController = viewController, let urlScheme = action.url.scheme {
                if ["http", "https"].contains(urlScheme) {
                    let safariVC = SFSafariViewController(url: action.url)
                    viewController.present(safariVC, animated: true, completion: nil)
                    return
                } else {
                    DebugLog.w("URL is missing http/https url scheme: \(action.url)")
                }
            }
        }
        
        // Open in Safari
        if UIApplication.shared.canOpenURL(action.url) {
            UIApplication.shared.openURL(action.url)
        }
    }
}

// MARK:- Utility

fileprivate extension ActionHandler {
    
    class func getTitleFrom(_ button: Any?) -> String? {
        let title: String?
        if let button = button as? ButtonItem {
            title = button.title
        } else if let quickReply = button as? QuickReply {
            title = quickReply.title
        } else {
            title = nil
        }
        return title
    }
    
    class func getDataFrom(action: Action, root: Component?) -> [String : Any]? {
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

// MARK:- Errors

extension ActionHandler {
    
    class func showAlert(title: String? = nil,
                         message: String? = nil,
                         presenter: UIViewController?) {
        if !Thread.isMainThread {
            Dispatcher.performOnMainThread {
                showAlert(title: title, message: message, presenter: presenter)
            }
            return
        }
        
        let alert = UIAlertController(title: title ?? ASAPP.strings.requestErrorGenericFailureTitle,
                                      message: message ?? ASAPP.strings.requestErrorGenericFailure,
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: ASAPP.strings.alertDismissButton,
                                      style: .cancel,
                                      handler: { (action) in
                                        
        }))
        
        presenter?.present(alert, animated: true, completion: nil)
    }
}

