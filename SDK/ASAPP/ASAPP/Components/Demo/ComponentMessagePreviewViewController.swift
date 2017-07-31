//
//  ComponentMessagePreviewViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/28/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentMessagePreviewViewController: ASAPPViewController {
    
    fileprivate(set) var classification: String?
    
    func setMessage(_ message: ChatMessage, with classification: String) {
        self.classification = classification
        addMessage(message)
    }
    
    // MARK:- Private Properties
    
    fileprivate let messagesView = ChatMessagesView()
    
    fileprivate let quickRepliesView = QuickRepliesActionSheet()
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK:- Initialization
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        messagesView.delegate = self
        messagesView.overrideToHideInfoView = true
        
        quickRepliesView.clipsToBounds = true
        quickRepliesView.delegate = self
        
        navigationItem.rightBarButtonItem = UIBarButtonItem(barButtonSystemItem: .refresh, target: self, action: #selector(ComponentMessagePreviewViewController.refresh))
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
        commonInit()
    }
    
    deinit {
        messagesView.delegate = nil
        quickRepliesView.delegate = nil
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()

        view.clipsToBounds = true
        view.backgroundColor = UIColor.white
        view.addSubview(messagesView)
        view.addSubview(quickRepliesView)
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        becomeFirstResponder()
    }
    
    // MARK:- Layout
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateFrames()
    }
    
    func updateFrames() {
        guard isViewLoaded else {
            return
        }
        
        let quickRepliesHeight: CGFloat = quickRepliesView.preferredDisplayHeight()
        var quickRepliesTop = view.bounds.height
        var contentBottom = view.bounds.height
        if quickRepliesView.eventIds.count > 0 {
            quickRepliesTop = view.bounds.height - quickRepliesHeight
            contentBottom = quickRepliesTop + quickRepliesView.transparentInsetTop
        }
        quickRepliesView.frame = CGRect(x: 0, y: quickRepliesTop, width: view.bounds.width, height: quickRepliesHeight)
        
        let top: CGFloat = 0
        let height = contentBottom - top
        messagesView.frame = CGRect(x: 0, y: top, width: view.bounds.width, height: height)
    }
    
    // MARK:- Refresh
    
    fileprivate func clear() {
        messagesView.reloadWithEvents([Event]())
        quickRepliesView.clear()
        updateFrames()
    }
    
    fileprivate func addMessage(_ message: ChatMessage?) {
        guard let message = message else {
            return
        }
        
        messagesView.addMessage(message)
        if message.metadata.isReply {
            quickRepliesView.add(message: message, animated: true)
        }
        updateFrames()
    }
    
    func refresh() {
        guard let classification = classification else {
            return
        }
        
        clear()
        UseCasePreviewAPI.getTreewalk(with: classification, completion: { [weak self] (message, viewContainer, err) in
            if let message = message {
                self?.addMessage(message)
            } else {
                self?.showAlert(with: "Failed to get message: \(err ?? "empty error")")
            }
        })
    }
    
    func getNextMessage(with messageText: String, nextFileName: String) {
        
        let metadata = EventMetadata(isReply: false,
                                     isAutomatedMessage: false,
                                     eventId: Int(Date().timeIntervalSince1970),
                                     eventType: .textMessage,
                                     issueId: 1,
                                     sendTime: Date())
        
        let userMessage = ChatMessage(text: messageText,
                                      attachment: nil,
                                      quickReplies: nil, 
                                      metadata: metadata)
        addMessage(userMessage)
        
        UseCasePreviewAPI.getTreewalk(with: nextFileName, completion: { [weak self] (message, _, err) in
            guard let message = message else {
                self?.showAlert(with: "Unable to fetch message from classification: \(nextFileName)")
                return
            }
            
            Dispatcher.delay(800, closure: {
                self?.addMessage(message)
            })
        })
    }
    
    // MARK: Motion
    
    public override func motionEnded(_ motion: UIEventSubtype,
                                     with event: UIEvent?) {
        if motion == .motionShake {
            refresh()
        }
    }
    
    // MARK: Instance Methods
    
    func showAlert(title: String? = nil, with message: String?) {
        let alert = UIAlertController(title: title ?? "Oops!",
                                      message: message ?? "You messed up, bro",
                                      preferredStyle: .alert)
        
        alert.addAction(UIAlertAction(title: "OK",
                                      style: .cancel,
                                      handler: nil))
        
        present(alert, animated: true, completion: nil)
    }
}

// MARK:- ChatMessagesViewDelegate

extension ComponentMessagePreviewViewController: ChatMessagesViewDelegate {
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTap buttonItem: ButtonItem,
                          from message: ChatMessage) {
        guard let component = message.attachment?.template else {
            return
        }
        
        if let apiAction = buttonItem.action as? APIAction {
            handleAPIAction(apiAction, from: component)
        } else if let componentViewAction = buttonItem.action as? ComponentViewAction {
            handleComponentViewAction(componentViewAction)
        } else if let finishAction = buttonItem.action as? FinishAction {
            handleFinishAction(finishAction)
        }
    }
    
    // Not implemented
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didTapImageView imageView: UIImageView, from message: ChatMessage) {}
    func chatMessagesView(_ messagesView: ChatMessagesView, didUpdateQuickRepliesFrom message: ChatMessage) {
        quickRepliesView.reloadButtons(for: message)
    }
    func chatMessagesViewPerformedKeyboardHidingAction(_ messagesView: ChatMessagesView) {}
    func chatMessagesView(_ messagesView: ChatMessagesView, didTapLastMessage message: ChatMessage) {}
}

extension ComponentMessagePreviewViewController: QuickRepliesActionSheetDelegate {
    
    
    
    func quickRepliesActionSheet(_ actionSheet: QuickRepliesActionSheet,
                                 didSelect quickReply: QuickReply,
                                 from message: ChatMessage) -> Bool {
        var title: String?
        var message: String?
        
        switch quickReply.action.type {
        case .api:
            title = "API"
            message = (quickReply.action as? APIAction)?.requestPath
            break
            
        case .componentView:
            if let action = quickReply.action as? ComponentViewAction {
                handleComponentViewAction(action)
                return false
            }
            title = "Component View"
            message = "Unknown"
            break
            
        case .deepLink:
            title = "Link"
            break
            
        case .finish:
            title = "Finish"
            break
            
        case .http:
            title = "HTTP"
            // MITCH MITCH MITCH
            break
            
        case .treewalk:
            if let treewalkAction = quickReply.action as? TreewalkAction {
                getNextMessage(with: quickReply.title, nextFileName: treewalkAction.classification)
                return false
            }
            
            title = "SRS Treewalk"
            message = "Classification: \(String(describing: (quickReply.action as? TreewalkAction)?.classification))"
            break
            
        case .userLogin:
            // MITCH MITCH TODO:
            break
    
        case .web:
            title = "Web"
            message = (quickReply.action as? WebPageAction)?.url.absoluteString
            break
            
        case .unknown:
            // No-op
            break
        }
        
        
        let alert = UIAlertController(title: title,
                                      message: message,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
        return false
    }
    
    // Not Handled
    
    func quickRepliesActionSheetDidCancel(_ actionSheet: QuickRepliesActionSheet) {}
    func quickRepliesActionSheetDidTapBack(_ actionSheet: QuickRepliesActionSheet) {}
    func quickRepliesActionSheetWillTapBack(_ actionSheet: QuickRepliesActionSheet) {}
}

extension ComponentMessagePreviewViewController {
    
    func handleAPIAction(_ action: APIAction, from /** root component **/ component: Component) {

        var requestData = component.getData()
        requestData.add(action.data)
        
        let requestDataString = JSONUtil.stringify(requestData as AnyObject, prettyPrinted: true)
        let title = action.requestPath
        
        let alert = UIAlertController(title: title,
                                      message: requestDataString,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func handleComponentViewAction(_ action: ComponentViewAction) {
        let viewController = ComponentViewController(componentName: action.name)
        viewController.delegate = self
        let navigationController = ComponentNavigationController(rootViewController: viewController)
        navigationController.displayStyle = action.displayStyle

        present(navigationController, animated: true, completion: nil)
    }
    
    func handleFinishAction(_ action: FinishAction) {
        let alert = UIAlertController(title: "Finish Action", message: nil, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
}

extension ComponentMessagePreviewViewController: ComponentViewControllerDelegate {
    
    func componentViewControllerDidFinish(with action: FinishAction?) {
        dismiss(animated: true) { [weak self] in
            if let nextAction = action?.nextAction {
                let alert = UIAlertController(title: "Next Action: \(nextAction)", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func componentViewController(_ viweController: ComponentViewController,
                                 fetchContentForViewNamed viewName: String,
                                 completion: @escaping ((ComponentViewContainer?, String?) -> Void)) {
        UseCasePreviewAPI.getTreewalk(with: viewName, completion: { (_, componentViewContainer, err) in
            completion(componentViewContainer, err)
        })
    }
    
    func componentViewController(_ viewController: ComponentViewController,
                                 didTapAPIAction action: APIAction,
                                 withFormData formData: [String : Any]?,
                                 completion: @escaping APIActionResponseHandler) {
        var data = action.data ?? [String : Any]()
        data.add(formData)
        
        if let text = data["text"] as? String,
            let name = data["classification"] as? String {
            Dispatcher.delay(1500) {
                completion(APIActionResponse(type: .finish))
                
                Dispatcher.delay(500, closure: { [weak self] in
                    self?.getNextMessage(with: text, nextFileName: name)
                })
            }
            return
        }
        
        if let viewName = data["name"] as? String {
            UseCasePreviewAPI.getTreewalk(with: viewName, completion: { (_, viewContainer, errorString) in
                let type: APIActionResponseType
                var actionError: APIActionError?
                if let _ = viewContainer {
                    if data.bool(for: "refresh") == true {
                        type = .refreshView
                    } else {
                        type = .componentView
                    }
                } else {
                    type = .error
                    actionError = APIActionError(code: 500,
                                                 userMessage: nil,
                                                 debugMessage: errorString ?? "Ooops!",
                                                 invalidInputs: nil)
                }
                let response = APIActionResponse(type: type,
                                                 view: viewContainer,
                                                 error: actionError)
                
                completion(response)
                
            })
            return
        }
        
        
        let error = APIActionError(code: 400,
                                   userMessage: "For testing purposes, the action should supply a 'text' and 'classification' value, or should supply a 'name' value",
                                   debugMessage: "",
                                   invalidInputs: nil)
        
        completion(APIActionResponse(type: .error,
                                     view: nil,
                                     error: error))
        
    }
}