//
//  ComponentMessagePreviewViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/28/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentMessagePreviewViewController: ASAPPViewController {
    
    private(set) var classification: String?
    
    func setMessage(_ message: ChatMessage, with classification: String) {
        self.classification = classification
        addMessage(message)
    }
    
    // MARK: - Private Properties
    
    private let messagesView = ChatMessagesView()
    
    private let quickRepliesView = QuickRepliesView()
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    // MARK: - Initialization
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        messagesView.delegate = self
        
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
    
    // MARK: - View
    
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
    
    // MARK: - Layout
    
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
        if quickRepliesView.eventId != nil {
            quickRepliesTop = view.bounds.height - quickRepliesHeight
            contentBottom = quickRepliesTop
        }
        quickRepliesView.frame = CGRect(x: 0, y: quickRepliesTop, width: view.bounds.width, height: quickRepliesHeight)
        
        let top: CGFloat = 0
        let height = contentBottom - top
        messagesView.frame = CGRect(x: 0, y: top, width: view.bounds.width, height: height)
    }
    
    // MARK: - Refresh
    
    private func clear() {
        messagesView.reloadWithEvents([Event]())
        quickRepliesView.clear(animated: false)
        updateFrames()
    }
    
    private func addMessage(_ message: ChatMessage?) {
        guard let message = message else {
            return
        }
        
        messagesView.addMessage(message)
        if message.metadata.isReply {
            quickRepliesView.show(message: message, animated: true)
        }
        updateFrames()
    }
    
    @objc func refresh() {
        guard let classification = classification else {
            return
        }
        
        clear()
        UseCasePreviewAPI.getTreewalk(with: classification, completion: { [weak self] (message, _, err) in
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
                                      notification: nil,
                                      attachment: nil,
                                      quickReplies: nil, 
                                      metadata: metadata)
        addMessage(userMessage)
        
        UseCasePreviewAPI.getTreewalk(with: nextFileName, completion: { [weak self] (message, _, _) in
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

// MARK: - ChatMessagesViewDelegate

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
    func chatMessagesView(_ messagesView: ChatMessagesView, didTapButtonWith action: Action) {}
    func chatMessagesViewDidScrollNearBeginning(_ messagesView: ChatMessagesView) {}
}

extension ComponentMessagePreviewViewController: QuickRepliesViewDelegate {
    func quickRepliesView(_ quickRepliesView: QuickRepliesView, didSelect quickReply: QuickReply, from message: ChatMessage) -> Bool {
        var title: String?
        var message: String?
        
        switch quickReply.action.type {
        case .api:
            title = "API"
            message = (quickReply.action as? APIAction)?.requestPath
            
        case .componentView:
            if let action = quickReply.action as? ComponentViewAction {
                handleComponentViewAction(action)
                return false
            }
            title = "Component View"
            message = "Unknown"
            
        case .deepLink:
            title = "Link"
            
        case .finish:
            title = "Finish"
            
        case .http:
            title = "HTTP"
            
        case .treewalk:
            if let treewalkAction = quickReply.action as? TreewalkAction {
                getNextMessage(with: quickReply.title, nextFileName: treewalkAction.classification)
                return false
            }
            
            title = "SRS Treewalk"
            message = "Classification: \(String(describing: (quickReply.action as? TreewalkAction)?.classification))"
            
        case .userLogin:
            title = "User Login"
    
        case .web:
            title = "Web"
            message = (quickReply.action as? WebPageAction)?.url.absoluteString
            
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
    
    func quickRepliesViewDidTapRestart(_ quickRepliesView: QuickRepliesView) {}
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
        let viewController = ComponentViewController(viewName: action.name, viewData: action.data, isInset: action.displayStyle == .inset)
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
    
    func componentViewController(_ viewController: ComponentViewController,
                                 fetchContentForViewNamed viewName: String,
                                 withData data: [String: Any]?,
                                 completion: @escaping ((ComponentViewContainer?, String?) -> Void)) {
        UseCasePreviewAPI.getTreewalk(with: viewName, completion: { (_, componentViewContainer, err) in
            completion(componentViewContainer, err)
        })
    }
    
    func componentViewController(_ viewController: ComponentViewController,
                                 didTapHTTPAction action: HTTPAction,
                                 withFormData formData: [String: Any]?,
                                 completion: @escaping APIActionResponseHandler) {
        
        showAlert(title: "HTTP Action", with: "Data: \(String(describing: formData))")
    }
    
    func componentViewController(_ viewController: ComponentViewController,
                                 didTapAPIAction action: APIAction,
                                 withFormData formData: [String: Any]?,
                                 completion: @escaping APIActionResponseHandler) {
        var data = action.data ?? [String: Any]()
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
                if viewContainer != nil {
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
