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
    
    var message: ChatMessage? {
        didSet {
            if let message = message {
                messagesView.reloadWithEvents([Event]())
                quickRepliesView.clear()
                updateFrames()
                
                messagesView.addMessage(message)
                quickRepliesView.add(message: message, animated: false)
                Dispatcher.delay(800, closure: updateFramesAnimated)
            }
        }
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
    
    func updateFramesAnimated() {
        UIView.animate(withDuration: 0.3, animations: updateFrames)
    }
    
    // MARK:- Refresh
    
    func refresh() {
        guard let fileName = fileName else {
            return
        }
        
        DemoComponentsAPI.getChatMessage(with: fileName) { [weak self] (message, err) in
            Dispatcher.performOnMainThread {
                self?.message = message
            }
        }
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
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didTap buttonItem: ButtonItem, from message: ChatMessage) {
        guard let action = buttonItem.action, let component = message.attachment?.template else {
            return
        }
        
        if let apiAction = action as? APIAction {
            handleAPIAction(apiAction, from: component)
        } else if let componentViewAction = action as? ComponentViewAction {
            handleComponentViewAction(componentViewAction)
        } else if let finishAction = action as? FinishAction {
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
            message = JSONUtil.stringify(buttonItem.action.context as? AnyObject, prettyPrinted: true)
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
        
        let requestDataString = JSONUtil.stringify(requestData as? AnyObject, prettyPrinted: true)
        let title = action.requestPath
        
        let alert = UIAlertController(title: title,
                                      message: requestDataString,
                                      preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .cancel, handler: nil))
        present(alert, animated: true, completion: nil)
    }
    
    func handleComponentViewAction(_ action: ComponentViewAction) {
        let viewController = ComponentViewController(componentName: action.name)
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
