//
//  ChatViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SafariServices

class ChatViewController: ASAPPViewController {
    enum InputState {
        case quickReplies
        case chat
        case both
        case conversationEnd
    }
    
    // MARK: Properties: Public
    
    let config: ASAPPConfig
    
    private(set) var user: ASAPPUser!
    
    let appCallbackHandler: ASAPPAppCallbackHandler
    
    // MARK: Properties: Storage
    
    private(set) var conversationManager: ConversationManager!
    private var quickRepliesMessage: ChatMessage?

    // MARK: Properties: Views / UI

    private let chatMessagesView = ChatMessagesView()
    private let chatInputView = ChatInputView()
    private let connectionStatusView = ChatConnectionStatusView()
    private let quickRepliesActionSheet = QuickRepliesActionSheet()
    private var hapticFeedbackGenerator: Any?
    
    // MARK: Properties: Status

    private var didConnectAtLeastOnce = false
    private var isInitialLayout = true
    private var delayedDisconnectTime: Date?
    private let disconnectedTimeThreshold: TimeInterval = 2
    private var segue: ASAPPSegue = .present
    private var inputState: InputState = .both
    
    // MARK: Properties: Keyboard
    
    private var keyboardObserver = KeyboardObserver()
    private var keyboardOffset: CGFloat = 0
    private var keyboardRenderedHeight: CGFloat = 0
    
    override var inputAccessoryView: UIView {
        return chatInputView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: - Initialization
    
    init(config: ASAPPConfig, user: ASAPPUser, segue: ASAPPSegue, appCallbackHandler: @escaping ASAPPAppCallbackHandler) {
        self.config = config
        self.appCallbackHandler = appCallbackHandler
        self.segue = segue
        super.init(nibName: nil, bundle: nil)
        
        updateUser(user)
        
        //
        // UI Setup
        //
        automaticallyAdjustsScrollViewInsets = false
        
        // Close Button
        let side = ASAPP.styles.closeButtonSide(for: segue)
        let closeButton = NavCloseBarButtonItem(location: .chat, side: .right)
            .configSegue(segue)
            .configTarget(self, action: #selector(ChatViewController.didTapCloseButton))
        
        switch side {
        case .right:
            navigationItem.rightBarButtonItem = closeButton
        case .left:
            navigationItem.leftBarButtonItem = closeButton
        }

        closeButton.accessibilityLabel = ASAPP.strings.accessibilityClose
        
        // Chat Messages View
        chatMessagesView.delegate = self
        chatMessagesView.reloadWithEvents(conversationManager.events)
        
        // Chat Input
        chatInputView.delegate = self
        chatInputView.displayMediaButton = true
        chatInputView.layer.shadowColor = UIColor.black.cgColor
        chatInputView.layer.shadowOffset = CGSize(width: 0, height: 0)
        chatInputView.layer.shadowRadius = 2
        chatInputView.layer.shadowOpacity = 0.1
        
        // Quick Replies
        quickRepliesActionSheet.delegate = self
        
        // Connection Status View
        connectionStatusView.onTapToConnect = { [weak self] in
            self?.reconnect()
        }
        
        // Fonts
        updateDisplay()
        NotificationCenter.default.addObserver(self,
            selector: #selector(ChatViewController.updateDisplay),
            name: Notification.Name.UIContentSizeCategoryDidChange,
            object: nil)
        
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange), name: .UserDidChange, object: nil)

        //
        // Interaction Setup
        //
        
        keyboardObserver.delegate = self
        
        if #available(iOS 10.0, *) {
            hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            if let generator = hapticFeedbackGenerator as? UIImpactFeedbackGenerator {
                generator.prepare()
            }
        }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Deinit
    
    deinit {
        keyboardObserver.delegate = nil
        chatMessagesView.delegate = nil
        chatInputView.delegate = nil
        conversationManager.delegate = nil
        quickRepliesActionSheet.delegate = nil
        
        conversationManager.exitConversation()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Dynamic Properties
    
    private var isLiveChat = false {
        didSet {
            if isLiveChat != oldValue {
                DebugLog.d("Chat Mode Changed: \(isLiveChat ? "LIVE CHAT" : "SRS")")
                if isLiveChat {
                    conversationManager.currentSRSClassification = nil
                } else {
                    conversationManager.currentSRSClassification = quickRepliesActionSheet.currentSRSClassification
                }
                
                if isViewLoaded {
                    updateViewForLiveChat()
                }
            }
        }
    }
    
    private var connectionStatus: ChatConnectionStatus = .disconnected {
        didSet {
            connectionStatusView.status = connectionStatus
        }
    }
    
    private var shouldShowConnectionStatusView: Bool {
        if let delayedDisconnectTime = delayedDisconnectTime {
            if connectionStatus != .connected && delayedDisconnectTime.hasPassed() {
                return true
            } else {
                return false
            }
        }
        
        if didConnectAtLeastOnce {
            return connectionStatus == .connecting || connectionStatus == .disconnected
        }
        
        return connectionStatus == .connecting || connectionStatus == .disconnected
    }
    
    // MARK: User
    
    @objc func userDidChange() {
        updateUser(ASAPP.user, with: ASAPP.userLoginAction)
        ASAPP.userLoginAction = nil
    }
    
    func updateUser(_ user: ASAPPUser, with userLoginAction: UserLoginAction? = nil) {
        DebugLog.d("Updating user. userIdentifier=\(user.userIdentifier)")
        if let userLoginAction = userLoginAction {
            DebugLog.d("Merging Accounts: {\n  mergeCustomerId: \(userLoginAction.mergeCustomerId),\n  mergeCustomerGUID: \(userLoginAction.mergeCustomerGUID)\n}")
        }
        
        if conversationManager != nil {
            clearQuickRepliesActionSheet(true, completion: nil)
            conversationManager.delegate = nil
            conversationManager.exitConversation()
        }
        
        self.user = user
        conversationManager = ConversationManager(config: config,
                                                  user: user,
                                                  userLoginAction: userLoginAction)
        conversationManager.delegate = self
        isLiveChat = conversationManager.isLiveChat
        
        if let nextAction = userLoginAction?.nextAction {
            performAction(nextAction, queueRequestIfNoConnection: true)
        }
    }
    
    // MARK: - View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.shadowImage = nil
            navigationBar.shadowImage = UIImage()
        }
        
        // View
        
        view.clipsToBounds = true
        view.backgroundColor = ASAPP.styles.colors.messagesListBackground
        
        if isLiveChat {
            clearQuickRepliesActionSheet(false, completion: nil)
        } else {
            reloadInputViews()
            updateFrames()
        }
        
        view.addSubview(chatMessagesView)
        view.addSubview(quickRepliesActionSheet)
        view.addSubview(connectionStatusView)
        
        let minTimeBetweenSessions: TimeInterval = 60 * 15 // 15 minutes
        if chatMessagesView.lastMessage == nil ||
            chatMessagesView.lastMessage!.metadata.sendTime.timeSinceIsGreaterThan(numberOfSeconds: minTimeBetweenSessions) {
            conversationManager.trackSessionStart()
        }
        
        // Inferred button
        conversationManager.trackButtonTap(buttonName: .openChat)
        
        if !chatMessagesView.isEmpty && !isLiveChat {
            showQuickRepliesActionSheetIfNecessary(animated: false)
        }
        
        // Load Events
        if conversationManager.isConnected {
            reloadMessageEvents()
        } else {
            connectionStatus = .connecting
            delayedDisconnectTime = Date(timeIntervalSinceNow: disconnectedTimeThreshold)
            conversationManager.enterConversation()
            Dispatcher.delay(1000 * disconnectedTimeThreshold + 300) { [weak self] in
                self?.updateFramesAnimated(false, scrollToBottomIfNearBottom: false)
            }
            
            // TODO: clear quick replies that may have been loaded from cache
            conversationManager.sendEnterChatRequest()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.registerForNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.deregisterForNotification()
        
        if isMovingFromParentViewController {
            inputAccessoryView.resignFirstResponder()
            inputAccessoryView.isHidden = true
            reloadInputViews()
        }
        
        conversationManager.saveCurrentEvents()
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return ASAPP.styles.colors.navBarBackground.isDark() ? .lightContent : .default
    }
    
    // MARK: View Layout Overrides
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        updateFrames()
        
        if isInitialLayout {
            chatMessagesView.scrollToBottomAnimated(false)
            isInitialLayout = false
        }
    }
}

// MARK: Display Update

extension ChatViewController {
    @objc func updateDisplay() {
        if let titleView = ASAPP.views.chatTitle {
            navigationItem.titleView = titleView
        } else if let titleText = ASAPP.strings.chatTitle {
            navigationItem.titleView = createASAPPTitleView(title: titleText)
        } else {
            navigationItem.titleView = nil
        }
        
        chatMessagesView.updateDisplay()
        quickRepliesActionSheet.updateDisplay()
        connectionStatusView.updateDisplay()
        chatInputView.updateDisplay()
        
        if isViewLoaded {
            view.setNeedsLayout()
        }
    }
}

// MARK: Connection

extension ChatViewController {
    func reconnect() {
        if connectionStatus == .disconnected {
            connectionStatus = .connecting
            conversationManager.enterConversation()
            conversationManager.sendEnterChatRequest()
        }
    }
    
    func updateViewForLiveChat(animated: Bool = true) {
        chatInputView.placeholderText = ASAPP.strings.chatInputPlaceholder
        
        if isLiveChat {
            clearQuickRepliesActionSheet(true, completion: nil)
            inputAccessoryView.becomeFirstResponder()
        } else {
            inputAccessoryView.resignFirstResponder()
        }
        
        reloadInputViews()
        
        if animated {
            updateFramesAnimated()
        } else {
            updateFrames()
        }
    }
    
    func dismissChatViewController() {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        } else if let container = navigationController?.parent as? ContainerViewController {
            container.navigationController?.popViewController(animated: true)
        }
    }
    
    func shakeConnectionStatusView() {
        connectionStatusView.label.transform = CGAffineTransform(translationX: 20, y: 0)
        UIView.animate(withDuration: 0.4, delay: 0, usingSpringWithDamping: 0.2, initialSpringVelocity: 1, options: .curveEaseInOut, animations: { [weak self] in
            self?.connectionStatusView.label.transform = .identity
        }, completion: nil)
    }
}

// MARK: - Button Actions

extension ChatViewController {
    @objc func didTapEndChatButton() {
        let confirmationAlert = UIAlertController(
            title: ASAPP.strings.endChatConfirmationTitle,
            message: ASAPP.strings.endChatConfirmationMessage,
            preferredStyle: .alert)
        confirmationAlert.addAction(UIAlertAction(title: ASAPP.strings.endChatConfirmationCancelButton, style: .cancel, handler: nil))
        confirmationAlert.addAction(UIAlertAction(title: ASAPP.strings.endChatConfirmationEndChatButton, style: .default, handler: { [weak self] _ in
            guard let strongSelf = self else {
                return
            }
            
            if !strongSelf.conversationManager.endLiveChat() {
                strongSelf.shakeConnectionStatusView()
            }
        }))
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    @objc func didTapCloseButton() {
        conversationManager.trackButtonTap(buttonName: .closeChat)
        
        dismissChatViewController()
    }
}

// MARK: - Layout

extension ChatViewController {
    
    func updateFrames() {
        var minVisibleY: CGFloat = 0
        if let navigationBar = navigationController?.navigationBar {
            if let navBarFrame = navigationBar.superview?.convert(navigationBar.frame, to: view) {
                let intersection = chatMessagesView.frame.intersection(navBarFrame)
                if !intersection.isNull {
                    minVisibleY = intersection.maxY
                }
            }
        }
        
        let viewWidth = view.bounds.width
        
        let connectionStatusHeight: CGFloat = 40
        var connectionStatusTop = -connectionStatusHeight
        if shouldShowConnectionStatusView {
            connectionStatusTop = minVisibleY
        }
        connectionStatusView.frame = CGRect(x: 0, y: connectionStatusTop, width: viewWidth, height: connectionStatusHeight)
        
        chatMessagesView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: view.bounds.height)
        chatMessagesView.layoutSubviews()
        chatMessagesView.contentInsetTop = minVisibleY
        
        let quickRepliesHeight: CGFloat = quickRepliesActionSheet.preferredDisplayHeight()
        var quickRepliesTop = view.bounds.height
        
        switch inputState {
        case .chat:
            chatInputView.isHidden = false
            chatInputView.becomeFirstResponder()
            chatMessagesView.contentInsetBottom = keyboardRenderedHeight
        case .both, .quickReplies, .conversationEnd:
            chatInputView.isHidden = (inputState != .both)
            chatInputView.resignFirstResponder()
            quickRepliesTop -= quickRepliesHeight
            let inputHeight = (inputState == .both) ? chatInputView.frame.height : 0
            quickRepliesTop -= inputHeight
            chatMessagesView.contentInsetBottom = quickRepliesActionSheet.frame.height + inputHeight
        }
        
        quickRepliesActionSheet.isRestartButtonVisible = (inputState == .quickReplies)
        quickRepliesActionSheet.frame = CGRect(x: 0, y: quickRepliesTop, width: viewWidth, height: quickRepliesHeight)
    }
    
    func updateFramesAnimated(_ animated: Bool = true, scrollToBottomIfNearBottom: Bool = true, completion: (() -> Void)? = nil) {
        let wasNearBottom = chatMessagesView.isNearBottom()
        if animated {
            UIView.animate(withDuration: 0.35, animations: { [weak self] in
                self?.updateFrames()
                if wasNearBottom && scrollToBottomIfNearBottom {
                    self?.chatMessagesView.scrollToBottomAnimated(false)
                }
            }, completion: { _ in
                completion?()
            })
        } else {
            updateFrames()
            if wasNearBottom && scrollToBottomIfNearBottom {
                chatMessagesView.scrollToBottomAnimated(false)
            }
            completion?()
        }
    }
}

// MARK: - KeyboardObserver

extension ChatViewController: KeyboardObserverDelegate {
    
    func keyboardWillUpdateVisibleHeight(_ height: CGFloat, withDuration duration: TimeInterval, animationCurve: UIViewAnimationOptions) {
        guard keyboardOffset != height else {
            return
        }
        
        keyboardOffset = height
        if height > 0 {
            keyboardRenderedHeight = height
        }
        
        updateFramesAnimated(!isInitialLayout)
    }
}

// MARK: - Handling Actions

extension ChatViewController {
    
    func canPerformAction(_ action: Action?, queueNetworkRequestIfNoConnection: Bool) -> Bool {
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
    
    /// Returns true if the button should be disabled
    @discardableResult
    func performAction(_ action: Action,
                       fromMessage message: ChatMessage? = nil,
                       quickReply: QuickReply? = nil,
                       buttonItem: ButtonItem? = nil,
                       queueRequestIfNoConnection: Bool = false) -> Bool {
        
        if !canPerformAction(action, queueNetworkRequestIfNoConnection: queueRequestIfNoConnection) {
            return false
        }
        
        ASAPP.userLoginAction = nil
        PushNotificationsManager.shared.requestAuthorizationIfNeeded(after: 3)
        
        let formData = message?.attachment?.template?.getData()
        
        switch action.type {
        case .api:
            conversationManager.sendRequestForAPIAction(action as! APIAction, formData: formData, completion: { [weak self] (response) in
                guard let response = response else {
                    self?.quickRepliesActionSheet.deselectCurrentSelection(animated: true)
                    return
                }
                
                switch response.type {
                case .finish:
                    if let nextAction = response.finishAction {
                        self?.performAction(nextAction)
                    }
                    
                case .error:
                    self?.showRequestErrorAlert(message: response.error?.userMessage)
                    if quickReply != nil {
                        self?.quickRepliesActionSheet.deselectCurrentSelection(animated: true)
                    }
                    
                case .componentView:
                    // Show view
                    break
                    
                case .refreshView:
                    // No meaning in this context
                    break
                }
            })
            
        case .componentView:
            showComponentView(fromAction: action, delegate: self)
            
        case .deepLink:
            if let deepLinkAction = action as? DeepLinkAction {
                // NOTE: We need the title. Will it always be a quick reply? No
                conversationManager.sendRequestForDeepLinkAction(deepLinkAction, with: quickReply?.title ?? buttonItem?.title ?? "")
                
                let completion: (() -> Void) = { [weak self] in
                    self?.appCallbackHandler(deepLinkAction.name, deepLinkAction.data)
                }
                
                switch segue {
                case .present:
                    dismiss(animated: true, completion: completion)
                case .push:
                    if let container = navigationController?.parent as? ContainerViewController {
                        container.navigationController?.popViewController(animated: true, completion: completion)
                    }
                }
            }
            
        case .finish:
            if let finishAction = action as? FinishAction, let nextAction = finishAction.nextAction {
                performAction(nextAction)
            }
            
        case .http:
            if let httpAction = action as? HTTPAction {
                conversationManager.sendRequestForHTTPAction(action, formData: formData, completion: { [weak self] (response, _, error) in
                    if let onResponseAction = httpAction.onResponseAction {
                        if let response = response {
                            onResponseAction.injectData(key: "success", value: error == nil)
                            onResponseAction.injectData(key: "response", value: response)
                        }
                        self?.performAction(onResponseAction)
                    }
                })
            }
            
        case .treewalk:
            chatMessagesView.scrollToBottomAnimated(true)
                        
            conversationManager.sendRequestForTreewalkAction(
                action as! TreewalkAction,
                messageText: quickReply?.title,
                parentMessage: message,
                completion: { [weak self] (success) in
                if !success {
                    self?.quickRepliesActionSheet.deselectCurrentSelection(animated: true)
                }
            })
            
        case .userLogin:
            if let userLoginAction = action as? UserLoginAction {
                ASAPP.userLoginAction = userLoginAction
                ASAPP.delegate?.chatViewControllerDidTapUserLoginButton()
            }
            
        case .web:
            showWebPage(fromAction: action)
            
        case .unknown:
            // No-op
            break
        }
        
        conversationManager.trackAction(action)
        
        return action.performsUIBlockingNetworkRequest
    }
}

// MARK: - ChatMessagesViewDelegate

extension ChatViewController: ChatMessagesViewDelegate {
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTapImageView imageView: UIImageView,
                          from message: ChatMessage) {
        guard let image = imageView.image else {
            return
        }
        
        inputAccessoryView.resignFirstResponder()
        
        let imageViewerImage = ImageViewerImage(image: image)
        let imageViewer = ImageViewer(withImages: [imageViewerImage], initialIndex: 0)
        imageViewer.preparePresentationFromImageView(imageView)
        imageViewer.presentationImageCornerRadius = 10
        present(imageViewer, animated: true, completion: nil)
    }
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTapLastMessage message: ChatMessage) {
        if !isLiveChat {
            showQuickRepliesActionSheetIfNecessary()
        }
    }
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didUpdateQuickRepliesFrom message: ChatMessage) {
        if message == chatMessagesView.lastMessage {
            quickRepliesActionSheet.reloadButtons(for: message)
        }
    }
    
    func chatMessagesViewPerformedKeyboardHidingAction(_ messagesView: ChatMessagesView) {
        inputAccessoryView.resignFirstResponder()
    }
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTap buttonItem: ButtonItem,
                          from message: ChatMessage) {
        performAction(buttonItem.action, fromMessage: message, buttonItem: buttonItem)
    }
}

// MARK: - ComponentViewControllerDelegate

extension ChatViewController: ComponentViewControllerDelegate {
    
    func componentViewControllerDidFinish(with action: FinishAction?) {
        if let nextAction = action?.nextAction {
            quickRepliesActionSheet.disableCurrentButtons()
            performAction(nextAction)
        }
        
        dismiss(animated: true, completion: nil)
    }

    func componentViewController(_ viewController: ComponentViewController,
                                 fetchContentForViewNamed viewName: String,
                                 withData data: [String: Any]?,
                                 completion: @escaping ((ComponentViewContainer?, String?) -> Void)) {
        conversationManager.getComponentView(named: viewName, data: data) { (componentViewContainer) in
            completion(componentViewContainer, nil)
        }
    }
    
    func componentViewController(_ viewController: ComponentViewController,
                                 didTapAPIAction action: APIAction,
                                 withFormData formData: [String: Any]?,
                                 completion: @escaping APIActionResponseHandler) {
        conversationManager.sendRequestForAPIAction(action, formData: formData, completion: { (response) in
            completion(response)
        })
    }
    
    func componentViewController(_ viewController: ComponentViewController,
                                 didTapHTTPAction action: HTTPAction,
                                 withFormData formData: [String: Any]?,
                                 completion: @escaping APIActionResponseHandler) {
        conversationManager.sendRequestForHTTPAction(action, formData: formData) { [weak self] (data, _, error) in
            if let apiAction = action.onResponseAction {
                let success = data != nil && error == nil
                var formData: [String: Any] = ["success": success]
                if let data = data {
                    formData["response"] = data
                }
                self?.conversationManager.sendRequestForAPIAction(apiAction, formData: data, completion: completion)
            }
        }
    }
}

// MARK: - ChatInputViewDelegate

extension ChatViewController: ChatInputViewDelegate {
    func chatInputView(_ chatInputView: ChatInputView, didTypeMessageText text: String?) {
        if isLiveChat && conversationManager.isConnected {
            let isTyping = text != nil && !text!.isEmpty
            conversationManager.sendUserTypingStatus(isTyping: isTyping, withText: text)
        }
    }
    
    func chatInputView(_ chatInputView: ChatInputView, didTapSendMessage message: String) {
        if conversationManager.isConnected(retryConnectionIfNeeded: true) {
            chatInputView.clear()
            sendMessage(withText: message)
        }
    }
    
    func chatInputView(_ chatInputView: ChatInputView, didTapMediaButton mediaButton: UIButton) {
        presentImageUploadOptions(fromView: mediaButton)
    }
    
    func chatInputViewDidChangeContentSize(_ chatInputView: ChatInputView) {
        updateFramesAnimated()
    }
    
    func chatInputViewDidBeginEditing(_ chatInputView: ChatInputView) {
        updateInputState(.chat, animated: true)
    }
}

// MARK: - Showing/Hiding QuickRepliesActionSheet

extension ChatViewController {
    func updateInputState(_ state: InputState, animated: Bool = false) {
        inputState = state
        updateFramesAnimated(animated)
    }
    
    // MARK: Showing
    
    func showQuickRepliesActionSheetIfNecessary(animated: Bool = true, completion: (() -> Void)? = nil) {
        if let quickReplyMessages = conversationManager.getQuickReplyMessages() {
            showQuickRepliesActionSheetIfNecessary(with: quickReplyMessages, animated: animated, completion: completion)
        }
    }
    
    private func showQuickRepliesActionSheetIfNecessary(with messages: [ChatMessage], animated: Bool = true, completion: (() -> Void)? = nil) {
        quickRepliesMessage = messages.last
        
        quickRepliesActionSheet.reload(with: messages)
        conversationManager.currentSRSClassification = quickRepliesActionSheet.currentSRSClassification
        updateFramesAnimated(animated, scrollToBottomIfNearBottom: true, completion: completion)
    }
    
    func showQuickRepliesActionSheet(with message: ChatMessage,
                                     animated: Bool = true,
                                     completion: (() -> Void)? = nil) {
        guard message.quickReplies != nil && !isLiveChat else { return }
        
        quickRepliesMessage = message
        quickRepliesActionSheet.add(message: message, animated: animated)
        conversationManager.currentSRSClassification = quickRepliesActionSheet.currentSRSClassification
        updateFramesAnimated(animated, scrollToBottomIfNearBottom: true, completion: completion)
    }
    
    // MARK: Hiding
    
    func clearQuickRepliesActionSheet(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        quickRepliesMessage = nil
        
        updateFramesAnimated(animated, scrollToBottomIfNearBottom: true, completion: { [weak self] in
            self?.quickRepliesActionSheet.clear()
            completion?()
        })
    }
    
    func showRestartActionButton() {
        updateInputState(.conversationEnd, animated: true)
        quickRepliesActionSheet.showRestartActionButton(animated: false)
        updateFramesAnimated()
    }
}

// MARK: - QuickRepliesActionSheetDelegate

extension ChatViewController: QuickRepliesActionSheetDelegate {
    func quickRepliesActionSheetDidTapRestartActionButton(_ actionSheet: QuickRepliesActionSheet) {
        conversationManager.sendAskRequest()
    }
    
    func quickRepliesActionSheetDidTapRestart(_ actionSheet: QuickRepliesActionSheet) {
        // TODO: show confirmation Action Sheet
        quickRepliesActionSheet.clear()
        conversationManager.sendAskRequest()
    }
    
    func quickRepliesActionSheetWillTapBack(_ actionSheet: QuickRepliesActionSheet) {
        conversationManager.trackButtonTap(buttonName: .srsBack)
    }
    
    func quickRepliesActionSheetDidTapBack(_ actionSheet: QuickRepliesActionSheet) {
        conversationManager.currentSRSClassification = actionSheet.currentSRSClassification
    }
    
    func quickRepliesActionSheet(_ actionSheet: QuickRepliesActionSheet,
                                 didSelect quickReply: QuickReply,
                                 from message: ChatMessage) -> Bool {
        updateInputState(.quickReplies, animated: true)
        return performAction(quickReply.action, fromMessage: message, quickReply: quickReply)
    }
}

// MARK: - ConversationManagerDelegate

extension ChatViewController: ConversationManagerDelegate {
    
    // New Messages
    func conversationManager(_ manager: ConversationManager, didReceive message: ChatMessage) {
        provideHapticFeedbackForMessageIfNecessary(message)
        if message.metadata.eventType == .newRep {
            ASAPP.soundEffectPlayer.playSound(.liveChatNotification)
        }
    
        chatMessagesView.addMessage(message) { [weak self] in
            guard let strongSelf = self else { return }
            
            let showChatInput = strongSelf.isLiveChat || message.userCanTypeResponse
            
            if showChatInput && message.hasQuickReplies {
                strongSelf.updateInputState(.both, animated: true)
            } else if message.hasQuickReplies {
                strongSelf.updateInputState(.quickReplies, animated: true)
            } else if showChatInput {
                strongSelf.updateInputState(.chat, animated: true)
            }
            
            if [EventType.conversationEnd, .conversationTimedOut].contains(message.metadata.eventType) {
                strongSelf.showRestartActionButton()
            } else if message.hasQuickReplies {
                strongSelf.didReceiveMessageWithQuickReplies(message)
            } else if message.metadata.isReply {
                strongSelf.clearQuickRepliesActionSheet(true, completion: nil)
            }
        }
    }
    
    // Updated Messages
    func conversationManager(_ manager: ConversationManager, didUpdate message: ChatMessage) {
        chatMessagesView.updateMessage(message)
    }
    
    // Typing Status
    func conversationManager(_ manager: ConversationManager, didChangeTypingStatus isTyping: Bool) {
        chatMessagesView.updateTypingStatus(isTyping)
    }
    
    // Live Chat Status
    func conversationManager(_ manager: ConversationManager, didChangeLiveChatStatus isLiveChat: Bool, with event: Event) {
        let wasLiveChat = self.isLiveChat
        self.isLiveChat = isLiveChat
        
        if !wasLiveChat && self.isLiveChat {
            conversationManager.trackLiveChatBegan(issueId: event.issueId)
        } else if wasLiveChat && !self.isLiveChat {
            conversationManager.trackLiveChatEnded(issueId: event.issueId)
        }
        
        conversationManager.saveCurrentEvents(async: true)
    }
    
    // Connection Status
    func conversationManager(_ manager: ConversationManager, didChangeConnectionStatus isConnected: Bool) {
        if isConnected {
            didConnectAtLeastOnce = true
            delayedDisconnectTime = nil
        } else if delayedDisconnectTime == nil {
            delayedDisconnectTime = Date(timeIntervalSinceNow: disconnectedTimeThreshold)
            Dispatcher.delay(1000 * disconnectedTimeThreshold + 300) { [weak self] in
                self?.updateFramesAnimated(true, scrollToBottomIfNearBottom: false)
            }
        }
        
        connectionStatus = isConnected ? .connected : .disconnected
        updateFramesAnimated(scrollToBottomIfNearBottom: false)
        
        if isConnected {
            // Fetch events
            reloadMessageEvents()
        } else if inputState == .conversationEnd {
            // show the restart action button again in case the spinner is visible
            showRestartActionButton()
        }
        
        DebugLog.d("ChatViewController: Connection -> \(isConnected ? "connected" : "not connected")")
    }
    
    // MARK: Handling Received Messages
    
    func provideHapticFeedbackForMessageIfNecessary(_ message: ChatMessage) {
        if message.metadata.isReply, #available(iOS 10.0, *) {
            if let generator = hapticFeedbackGenerator as? UIImpactFeedbackGenerator {
                generator.impactOccurred()
            }
        }
    }
    
    func didReceiveMessageWithQuickReplies(_ message: ChatMessage) {
        guard message.quickReplies != nil else {
            return
        }
        
        if quickRepliesActionSheet.frame.minY < view.bounds.height {
            // already visible
            Dispatcher.delay(200) { [weak self] in
                self?.showQuickRepliesActionSheet(with: message)
            }
        } else {
            // not yet visible
            Dispatcher.delay(1000) { [weak self] in
                self?.showQuickRepliesActionSheet(with: message)
            }
        }
    }
}

// MARK: - UIImagePickerControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String: Any]) {
        if let image = info[UIImagePickerControllerEditedImage] as? UIImage {
            conversationManager.sendPictureMessage(image)
        } else if let image = info[UIImagePickerControllerOriginalImage] as? UIImage {
            conversationManager.sendPictureMessage(image)
        }
        
        dismiss(animated: true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
}

// MARK: - Actions

extension ChatViewController {
    
    func sendMessage(withText text: String, fromPrediction: Bool = false) {
        if conversationManager.isConnected {
            chatMessagesView.scrollToBottomAnimated(true)
        }
        
        if isLiveChat {
            conversationManager.sendTextMessage(text)
        } else {
            conversationManager.sendSRSQuery(text, isRequestFromPrediction: fromPrediction)
        }
        
        PushNotificationsManager.shared.requestAuthorizationIfNeeded(after: 3)
    }
    
    func reloadMessageEvents() {
        conversationManager.getEvents { [weak self] (fetchedEvents, _) in
            if let strongSelf = self, let fetchedEvents = fetchedEvents {
                strongSelf.clearQuickRepliesActionSheet(false, completion: nil)
                strongSelf.showQuickRepliesActionSheetIfNecessary(animated: true)
                strongSelf.chatMessagesView.reloadWithEvents(fetchedEvents)
                strongSelf.isLiveChat = strongSelf.conversationManager.isLiveChat
            }
        }
    }
}
