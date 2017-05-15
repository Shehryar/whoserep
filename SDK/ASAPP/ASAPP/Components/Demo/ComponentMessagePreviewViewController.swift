//
//  ComponentMessagePreviewViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/28/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentMessagePreviewViewController: ASAPPViewController {
    
    var fileInfo: DemoComponentFileInfo? {
        didSet {
            refresh()
        }
    }
    
    // MARK:- Private Properties
    
    fileprivate let messagesView = ChatMessagesView()
    
    fileprivate let quickRepliesView = QuickRepliesActionSheet()
    
    public override var canBecomeFirstResponder: Bool {
        return true
    }
    
    var shouldLoad = false
    
    // MARK:- Initialization
    
    func commonInit() {
        automaticallyAdjustsScrollViewInsets = false
        
        messagesView.delegate = self
        messagesView.overrideToHideInfoView = true
        
        quickRepliesView.clipsToBounds = true
        quickRepliesView.delegate = self
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
        guard let fileInfo = fileInfo else {
            return
        }
        
        clear()
        
        UseCasePreviewAPI.getChatMessage(fileInfo: fileInfo, completion: { [weak self] (message, err) in
            self?.addMessage(message)
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
        
        let nextFileInfo = DemoComponentFileInfo(fileName: nextFileName,
                                                 fileType: fileInfo?.fileType ?? .useCase)
        UseCasePreviewAPI.getChatMessage(fileInfo: nextFileInfo, completion: { [weak self] (message, err) in
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
        case .deepLink:
            title = "Link"
            break
            
        case .treewalk:
            if let treewalkAction = quickReply.action as? TreewalkAction {
                getNextMessage(with: quickReply.title, nextFileName: treewalkAction.classification)
                return false
            }
            
            title = "SRS Treewalk"
            message = "Classification: \(String(describing: (quickReply.action as? TreewalkAction)?.classification))"
            break
            
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
            
        case .finish:
            title = "Finish"
            break
            
        case .web:
            title = "Web"
            message = (quickReply.action as? WebPageAction)?.url.absoluteString
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
            if let classification = action?.classification {
                let alert = UIAlertController(title: "Classification: \(classification)", message: nil, preferredStyle: .alert)
                alert.addAction(UIAlertAction(title: "OK", style: .cancel, handler: nil))
                self?.present(alert, animated: true, completion: nil)
            }
        }
    }
    
    func componentViewController(_ viweController: ComponentViewController,
                                 fetchContentForViewNamed viewName: String,
                                 completion: @escaping ((ComponentViewContainer?, String?) -> Void)) {
        
        shouldLoad = true
        if shouldLoad {
            let loadFileInfo = DemoComponentFileInfo(fileName: viewName,
                                                     fileType: fileInfo?.fileType ?? .useCase)
            
            UseCasePreviewAPI.getComponentViewContainer(fileInfo: loadFileInfo, completion: { (componentViewContainer, err) in
                completion(componentViewContainer, err?.localizedDescription)
            })
        } else {
            Dispatcher.delay(1000) {
                completion(nil, "whoops!")
            }
        }
        
//        shouldLoad = !shouldLoad
    }
    
    func componentViewController(_ viewController: ComponentViewController,
                                 didTapAPIAction action: APIAction,
                                 with data: [String : Any]?,
                                 completion: @escaping APIActionResponseHandler) {
        if let text = data?["text"] as? String,
            let name = data?["classification"] as? String {
            Dispatcher.delay(1500) {
                completion(APIActionResponse(type: .finish))
                
                Dispatcher.delay(500, closure: { [weak self] in
                    self?.getNextMessage(with: text, nextFileName: name)
                })
            }
            return
        }
        
        if let viewName = data?["name"] as? String {
            let nextFileInfo = DemoComponentFileInfo(fileName: viewName,
                                                     fileType: fileInfo?.fileType ?? .useCase)
            
            UseCasePreviewAPI.getComponentViewContainer(fileInfo: nextFileInfo, completion: { (viewContainer, error) in
                let type: APIActionResponseType
                var actionError: APIActionError?
                if let _ = viewContainer {
                    if data?.bool(for: "refresh") == true {
                        type = .refreshView
                    } else {
                        type = .componentView
                    }
                } else {
                    type = .error
                    actionError = APIActionError(code: 500,
                                                 userMessage: nil,
                                                 debugMessage: error?.localizedDescription ?? "Ooops!",
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
