//
//  ActionHandler.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 6/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit
import SafariServices


protocol ActionHandlerDelegate: class {
    func actionHandlerFinish()
    func actionHandlerDeepLink(name: String, data: [String : Any]?)
    func actionHandlerUserLogin(_ action: UserLoginAction)
}


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
    
    weak var delegate: ActionHandlerDelegate?
    
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
        
        conversationManager.trackAction(action)
    }
}

// MARK: Specific Action Handling

fileprivate extension ActionHandler {
    
    func performAPIAction(_ action: APIAction?,
                          root: Component?,
                          completion: ActionHandlerCompletion?) {
        guard let action = action else { return }
        
        let data = generateDataForRequest(action: action, root: root)
        conversationManager.sendRequestForAPIAction(action, data: data) { [weak self] (response) in
            guard let response = response else {
                return
            }
            
            switch response.type {
            case .componentView:
                
                break
                
            case .refreshView:
                
                break
                
            case .error:
                
                
                break
                
            case .finish:
                if let finishAction = response.finishAction {
                    self?.performFinishAction(finishAction)
                }
                break
            }
            
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
            if let viewController = viewController, let urlScheme = url.scheme {
                if ["http", "https"].contains(urlScheme) {
                    let safariVC = SFSafariViewController(url: url)
                    viewController.present(safariVC, animated: true, completion: nil)
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
    
    func showAlert(message: String) {
        
    }
}










/**
 *
 * other files
 *
 */


class FromChatViewController: UIViewController {
    /// Returns true if the button should be disabled
    func performAction(_ action: Action,
                       from button: Any?,
                       message: ChatMessage?,
                       queueRequestIfNoConnection: Bool = false) -> Bool {
        
        let isConnected = conversationManager.isConnected(retryConnectionIfNeeded: true)
        var title: String? = nil
        if let buttonItem = button as? ButtonItem {
            title = buttonItem.title
        } else if let quickReply = button as? QuickReply {
            title = quickReply.title
        }
        
        conversationManager.trackAction(action)
        
        switch action.type {
        case .api:
            if isConnected || queueRequestIfNoConnection {
                handleAPIAction(action, with: nil, rootComponent: message?.attachment?.template)
                return true
            }
            break
            
        case .componentView:
            if isConnected || queueRequestIfNoConnection {
                handleComponentViewAction(action)
            }
            break
            
        case .deepLink:
            handleDeepLinkAction(action, from: button)
            break
            
        case .finish:
            // This action  has no meaning in this context
            break
            
        case .http:
            // MITCH MITCH MITCH
            break;
            
        case .treewalk:
            if isConnected || queueRequestIfNoConnection {
                handleTreewalkAction(action, with: title, from: message)
                return true
            }
            break
            
        case .userLogin:
            // MITCH MITCH TODO:
            break
            
        case .web:
            handleWebPageAction(action)
            break
            
        case .unknown:
            // No-op
            break
        }
        return false
    }
    
    // MARK:- Handling Actions
    
    func handleAPIAction(_ action: Action, with params: [String : Any]?, rootComponent: Component?) {
        guard let action = action as? APIAction else {
            return
        }
        
        var requestData = [String : Any]()
        requestData.add(action.data)
        if let params = params {
            requestData.add(params)
        }
        if let rootComponent = rootComponent {
            requestData.add(rootComponent.getData())
        }
        
        let requestDataString = JSONUtil.stringify(requestData as AnyObject,
                                                   prettyPrinted: true)
        
        let title = action.requestPath
        
        let alert = UIAlertController(title: title,
                                      message: requestDataString,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func handleComponentViewAction(_ action: Action) {
        guard let action = action as? ComponentViewAction else {
            return
        }
        
        let viewController = ComponentViewController(componentName: action.name)
        viewController.delegate = self
        let navigationController = ComponentNavigationController(rootViewController: viewController)
        navigationController.displayStyle = action.displayStyle
        present(navigationController, animated: true, completion: nil)
    }
    
    func handleDeepLinkAction(_ action: Action, from button: Any?) {
        guard let action = action as? DeepLinkAction else {
            return
        }
        
        var title: String?
        if let button = button as? ButtonItem {
            title = button.title
        } else if let quickReply = button as? QuickReply {
            title = quickReply.title
        }
        
        DebugLog.d("\nDid select action: \(action.name) w/ context: \(String(describing: action.data))")
        
        conversationManager.sendRequestForDeepLinkAction(action, with: title ?? "")
        
        dismiss(animated: true, completion: { [weak self] in
            self?.appCallbackHandler(action.name, action.data)
        })
    }
    
    func handleTreewalkAction(_ action: Action, with title: String?, from message: ChatMessage?) {
        guard let action = action as? TreewalkAction else {
            return
        }
        
        simpleStore.updateQuickReplyEventIds(quickRepliesActionSheet.eventIds)
        chatMessagesView.scrollToBottomAnimated(true)
        
        conversationManager.sendRequestForTreewalkAction(action,
                                                         with: title ?? action.messageText ?? "",
                                                         parentMessage: message,
                                                         originalSearchQuery: simpleStore.getSRSOriginalSearchQuery(),
                                                         completion: { [weak self] (message, _, _) in
                                                            if message.type != .Response {
                                                                self?.quickRepliesActionSheet.deselectCurrentSelection(animated: true)
                                                            }
        })
    }

}




