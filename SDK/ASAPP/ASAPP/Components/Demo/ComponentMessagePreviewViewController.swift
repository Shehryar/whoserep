//
//  ComponentMessagePreviewViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/28/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ComponentMessagePreviewViewController: UIViewController {

    var fileName: String? {
        didSet {
            refresh()
        }
    }
    
    var allFileNames: [String]?
    
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
        
        var top: CGFloat = 0
        if let navBar = navigationController?.navigationBar {
            top = navBar.frame.maxY
        }
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
        if message.isReply {
            quickRepliesView.add(message: message, animated: true)
        }
        updateFrames()
    }
    
    func refresh() {
        guard let fileName = fileName else {
            return
        }
        
        clear()
        
        DemoComponentsAPI.getChatMessage(with: fileName) { [weak self] (message, err) in
            Dispatcher.performOnMainThread {
                self?.addMessage(message)
            }
        }
    }
    
    func getNextMessage(with messageText: String, fileName: String) {
        let userMessage = ChatMessage(text: messageText,
                                      attachment: nil,
                                      quickReplies: nil,
                                      isReply: false,
                                      sendTime: Date(),
                                      eventId: Int(Date().timeIntervalSince1970),
                                      eventType: .textMessage,
                                      issueId: 1)
        addMessage(userMessage)
        
        DemoComponentsAPI.getChatMessage(with: fileName) { [weak self] (message, error) in
            Dispatcher.delay(800, closure: { 
                self?.addMessage(message)
            })
        }
        
        
//        let viewController = ComponentMessagePreviewViewController()
//        viewController.fileName = buttonItem.action.name
//        navigationController?.pushViewController(viewController, animated: true)
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
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didTapImageView imageView: UIImageView, forMessage message: ChatMessage) {}
    func chatMessagesView(_ messagesView: ChatMessagesView, didSelectButtonItem buttonItem: SRSButtonItem, forMessage message: ChatMessage) { }
    func chatMessagesView(_ messagesView: ChatMessagesView, didUpdateButtonItemsForMessage message: ChatMessage) {}
    func chatMessagesViewPerformedKeyboardHidingAction(_ messagesView: ChatMessagesView) {}
    func chatMessagesView(_ messagesView: ChatMessagesView, didTapLastMessage message: ChatMessage) {}
}

extension ComponentMessagePreviewViewController: QuickRepliesActionSheetDelegate {
    
    func quickRepliesActionSheet(_ actionSheet: QuickRepliesActionSheet,
                                 didSelect buttonItem: SRSButtonItem,
                                 for message: ChatMessage) -> Bool {
        var title: String?
        var message: String?
        switch buttonItem.action.type {
        case .link:
            title = "Link"
            break
            
        case .treewalk:
            if let allFileNames = allFileNames,
                allFileNames.contains(buttonItem.action.name) {
                getNextMessage(with: buttonItem.title, fileName: buttonItem.action.name)
                return false
            }
            
            title = "SRS Treewalk"
            message = "Classification: \(buttonItem.action.name)"
            break
            
        case .api:
            title = "API"
            message = buttonItem.action.name
            break
            
        case .action:
            title = "Action"
            message = buttonItem.action.name
            break
            
        case .componentView:
            if let action = buttonItem.action.getComponentViewAction() {
                handleComponentViewAction(action)
                 return false
            }
            title = "Component View"
            message = JSONUtil.stringify(buttonItem.action.context as AnyObject, prettyPrinted: true)
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

        var requestData = component.getData(for: action.dataInputFields)
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
    
    func componentViewController(_ viweController: ComponentViewController,
                                 fetchContentForViewNamed viewName: String,
                                 completion: @escaping ((ComponentViewContainer?, String?) -> Void)) {
        
        shouldLoad = true
        if shouldLoad {
            DemoComponentsAPI.getComponent(with: viewName) { (componentViewContainer, json, error) in
                
                completion(componentViewContainer, error)
            }
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
                                 completion: @escaping ((ComponentAction?, String?) -> Void)) {
        guard let text = data?["Text"] as? String,
            let name = data?["Classification"] as? String else {
                print("DATA IS MISSING: \(data)")
                completion(nil, "Missing data")
                return
        }
        
        Dispatcher.delay(1500) {
            completion(FinishAction(content: nil), nil)
            
            Dispatcher.delay(500, closure: { [weak self] in
                self?.getNextMessage(with: text, fileName: name)
            })
        }
    }
}
