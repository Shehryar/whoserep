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
    
    // MARK: Properties: Public
    
    let config: ASAPPConfig
    
    private(set) var user: ASAPPUser!
    
    let appCallbackHandler: ASAPPAppCallbackHandler
    
    // MARK: Properties: Storage
    
    fileprivate private(set) var conversationManager: ConversationManager!
    fileprivate var quickRepliesMessage: ChatMessage?

    // MARK: Properties: Views / UI
    
    fileprivate var predictiveVC: PredictiveViewController!
    fileprivate let predictiveNavController: UINavigationController!
    fileprivate let chatMessagesView = ChatMessagesView()
    fileprivate let chatInputView = ChatInputView()
    fileprivate let connectionStatusView = ChatConnectionStatusView()
    fileprivate let quickRepliesActionSheet = QuickRepliesActionSheet()
    fileprivate var askTooltipPresenter: TooltipPresenter?
    fileprivate var hapticFeedbackGenerator: Any?
    
    // MARK: Properties: Status
    
    var showPredictiveOnViewAppear = true
    fileprivate var connectedAtLeastOnce = false
    fileprivate var isInitialLayout = true
    fileprivate var didPresentPredictiveView = false
    fileprivate var predictiveVCVisible = false
    fileprivate var delayedDisconnectTime: Date?
    fileprivate var segue: ASAPPSegue = .present
    
    // MARK: Properties: Keyboard
    
    fileprivate var keyboardObserver = KeyboardObserver()
    fileprivate var keyboardOffset: CGFloat = 0
    fileprivate var keyboardRenderedHeight: CGFloat = 0

    // MARK:- Initialization
    
    init(config: ASAPPConfig, user: ASAPPUser, segue: ASAPPSegue, appCallbackHandler: @escaping ASAPPAppCallbackHandler) {
        self.config = config
        self.appCallbackHandler = appCallbackHandler
        self.predictiveVC = PredictiveViewController(segue: segue)
        self.predictiveNavController = UINavigationController(rootViewController: predictiveVC)
        self.segue = segue
        super.init(nibName: nil, bundle: nil)
        
        updateUser(user)
        
        //
        // UI Setup
        //
        automaticallyAdjustsScrollViewInsets = false
  
        // Predictive
        predictiveVC.delegate = self
        predictiveNavController.view.alpha = 0.0
        
        // Close Button
        let side = ASAPP.styles.closeButtonSide(for: segue)
        let closeButton = UIBarButtonItem.asappCloseBarButtonItem(
            location: .chat,
            segue: segue,
            target: self,
            action: #selector(ChatViewController.didTapCloseButton))
        
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
        
        // Live Chat
        if isLiveChat {
            showPredictiveOnViewAppear = false
        } else {
            if let lastMessage = chatMessagesView.lastMessage {
                let secondsSinceLastEvent = Date().timeIntervalSince(lastMessage.metadata.sendTime)
                
                showPredictiveOnViewAppear = secondsSinceLastEvent > (15 * 60)
                if secondsSinceLastEvent < (60 * 15) {
                    showPredictiveOnViewAppear = false
                }
            } else {
                showPredictiveOnViewAppear = true
            }
        }
        
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
        predictiveVC.delegate = nil
        keyboardObserver.delegate = nil
        chatMessagesView.delegate = nil
        chatInputView.delegate = nil
        conversationManager.delegate = nil
        quickRepliesActionSheet.delegate = nil
        
        conversationManager.exitConversation()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Dynamic Properties
    
    fileprivate var isLiveChat = false {
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
            
            if isLiveChat && askTooltipPresenter != nil {
                askTooltipPresenter?.dismiss()
                askTooltipPresenter = nil
            }
        }
    }
    
    fileprivate var connectionStatus: ChatConnectionStatus = .disconnected {
        didSet {
            connectionStatusView.status = connectionStatus
        }
    }
    
    fileprivate var shouldShowConnectionStatusView: Bool {
        if let delayedDisconnectTime = delayedDisconnectTime {
            if connectionStatus != .connected && delayedDisconnectTime.hasPassed() {
                return true
            } else {
                return false
            }
        }
        
        if connectedAtLeastOnce {
            return connectionStatus == .connecting || connectionStatus == .disconnected
        }
        
        return connectionStatus == .connecting || connectionStatus == .disconnected
    }
    
    // MARK: User
    
    // TODO: Separate out initial setup and changes needed after changing user mid-flow
    
    func updateUser(_ user: ASAPPUser, with userLoginAction: UserLoginAction? = nil) {
        DebugLog.d("Updating user. userIdentifier=\(user.userIdentifier)")
        if let userLoginAction = userLoginAction {
            DebugLog.d("Merging Accounts: {\n  mergeCustomerId: \(userLoginAction.mergeCustomerId),\n  mergeCustomerGUID: \(userLoginAction.mergeCustomerGUID)\n}")
        }
        
        if conversationManager != nil {
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
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // View
        
        view.clipsToBounds = true
        view.backgroundColor = ASAPP.styles.colors.messagesListBackground
        updateViewForLiveChat(animated: false)
        
        view.addSubview(chatMessagesView)
        view.addSubview(chatInputView)
        view.addSubview(quickRepliesActionSheet)
        view.addSubview(connectionStatusView)
        
        // Predictive
        if let predictiveView = predictiveNavController?.view {
            if let navView = navigationController?.view {
                navView.addSubview(predictiveView)
            } else {
                view.addSubview(predictiveView)
            }
            predictiveView.alpha = 0.0
        }
        
        let minTimeBetweenSessions: TimeInterval = 60 * 15 // 15 minutes
        if chatMessagesView.lastMessage == nil ||
            chatMessagesView.lastMessage!.metadata.sendTime.timeSinceIsGreaterThan(numberOfSeconds: minTimeBetweenSessions) {
            conversationManager.trackSessionStart()
        }
        
        // Inferred button
        conversationManager.trackButtonTap(buttonName: .openChat)
        
        if showPredictiveOnViewAppear || chatMessagesView.isEmpty {
            showPredictiveOnViewAppear = false
            setPredictiveViewControllerVisible(true, animated: false, completion: nil)
        } else if !isLiveChat {
            showQuickRepliesActionSheetIfNecessary(animated: false)
        }
        
        // Load Events
        if conversationManager.isConnected {
            reloadMessageEvents()
        } else {
            connectionStatus = .connecting
            delayedDisconnectTime = Date(timeIntervalSinceNow: 2) // 2 seconds from now
            conversationManager.enterConversation()
            Dispatcher.delay(2300) { [weak self] in
                self?.updateFramesAnimated()
            }
            
            conversationManager.getAppOpen { [weak self] (appOpenResponse) in
                self?.predictiveVC.setAppOpenResponse(appOpenResponse: appOpenResponse, animated: true)
            }
        }
        
        Dispatcher.delay(500) { [weak self] in
            self?.showAskButtonTooltipIfNecessary()
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.registerForNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.deregisterForNotification()
        
        view.endEditing(true)
        
        conversationManager.saveCurrentEvents()
    }
    
    // MARK:- Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        if (showPredictiveOnViewAppear || predictiveVCVisible) && !isLiveChat {
            if let predictiveNavColor = ASAPP.styles.colors.predictiveNavBarBackground {
                if predictiveNavColor.isDark() {
                    return .lightContent
                } else {
                    return .default
                }
            } else if ASAPP.styles.colors.predictiveGradientTop.isDark() {
                return .lightContent
            } else {
                return .default
            }
        }
        return super.preferredStatusBarStyle
    }
    
    // MARK: View Layout Overrides
    
    override func viewWillLayoutSubviews() {
        super.viewWillLayoutSubviews()
        
        updateFrames()
    }
    
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
    func updateDisplay() {
        if let titleText = ASAPP.strings.chatTitle {
            navigationItem.titleView = createASAPPTitleView(title: titleText)
        } else {
            navigationItem.titleView = nil
        }
        
        updateNavigationActionButton()
        
        chatMessagesView.updateDisplay()
        quickRepliesActionSheet.updateDisplay()
        connectionStatusView.updateDisplay()
        chatInputView.updateDisplay()
        
        if isViewLoaded {
            view.setNeedsLayout()
        }
    }
    
    func updateNavigationActionButton() {
        let side = ASAPP.styles.closeButtonSide(for: segue).opposite()
        let title: String
        let action: Selector
        let customImage: ASAPPNavBarButtonImage?
        
        if isLiveChat {
            title = ASAPP.strings.chatEndChatNavBarButton
            action = #selector(ChatViewController.didTapEndChatButton)
            customImage = ASAPP.styles.navBarButtonImages.end
        } else {
            title = ASAPP.strings.chatAskNavBarButton
            action = #selector(ChatViewController.didTapAskButton)
            customImage = ASAPP.styles.navBarButtonImages.ask
        }
        
        let askButton = UIBarButtonItem.asappBarButtonItem(
            title: title,
            customImage: customImage,
            style: .ask,
            location: .chat,
            side: side,
            target: self,
            action: action)
        
        switch side {
        case .left:
            navigationItem.leftBarButtonItem = askButton
        case .right:
            navigationItem.rightBarButtonItem = askButton
        }
    }
}

// MARK: Connection

extension ChatViewController {
    func reconnect() {
        if connectionStatus == .disconnected {
            connectionStatus = .connecting
            conversationManager.enterConversation()
            conversationManager.getAppOpen()
        }
    }
    
    func updateViewForLiveChat(animated: Bool = true) {
        updateNavigationActionButton()
        
        if isLiveChat {
            clearQuickRepliesActionSheet(true, completion: nil)
            chatInputView.placeholderText = ASAPP.strings.chatInputPlaceholder
        } else {
            view.endEditing(true)
            chatInputView.placeholderText = ASAPP.strings.predictiveInputPlaceholder
        }
        
        if animated {
            updateFramesAnimated()
        } else {
            updateFrames()
        }
    }
    
    func showPredictiveView() {
        setPredictiveViewControllerVisible(true, animated: true, completion: nil)
    }
    
    func dismissChatViewController() {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        } else if let container = navigationController?.parent as? ContainerViewController {
            container.navigationController?.popViewController(animated: true)
        }
    }
}

// MARK:- Button Actions

extension ChatViewController {
    func didTapAskButton() {
        increaseTooltipActionsCount(increaseAmount: 2)
        
        showPredictiveView()
        
        conversationManager.trackButtonTap(buttonName: .showPredictiveFromChat)
    }
    
    func didTapEndChatButton() {
        let confirmationAlert = UIAlertController(title: ASAPP.strings.endChatConfirmationTitle,
                                                  message: ASAPP.strings.endChatConfirmationMessage,
                                                  preferredStyle: .alert)
        confirmationAlert.addAction(UIAlertAction(title: ASAPP.strings.endChatConfirmationCancelButton, style: .cancel, handler: nil))
        confirmationAlert.addAction(UIAlertAction(title: ASAPP.strings.endChatConfirmationEndChatButton, style: .default, handler: { [weak self] _ in
            self?.conversationManager.endLiveChat()
        }))
        present(confirmationAlert, animated: true, completion: nil)
    }
    
    func didTapCloseButton() {
        conversationManager.trackButtonTap(buttonName: .closeChatFromChat)
        
        dismissChatViewController()
    }
}

// MARK:- Tooltip

extension ChatViewController {
    
    func hasShownAskTooltipKey() -> String {
        return config.hashKey(with: user, prefix: "AskTooltipShown")
    }
    
    func numberOfTooltipActions() -> Int {
        return UserDefaults.standard.integer(forKey: hasShownAskTooltipKey())
    }
    
    private static let MAX_TOOLTIP_ACTIONS_COUNT = 3
    
    func increaseTooltipActionsCount(increaseAmount: Int = 1) {
        let numberOfTimesShown = numberOfTooltipActions() + increaseAmount
        UserDefaults.standard.set(numberOfTimesShown, forKey: hasShownAskTooltipKey())
    }
    
    func showAskButtonTooltipIfNecessary(showRegardlessCount: Bool = false) {
        guard !showPredictiveOnViewAppear && !predictiveVCVisible && !isLiveChat else {
            return
        }
        guard showRegardlessCount || numberOfTooltipActions() < ChatViewController.MAX_TOOLTIP_ACTIONS_COUNT else {
            return
        }
        
        if askTooltipPresenter != nil {
            return
        }
        
        let side = ASAPP.styles.closeButtonSide(for: segue).opposite()
        guard let navView = navigationController?.view,
              let buttonItem = side == .left ? navigationItem.leftBarButtonItem : navigationItem.rightBarButtonItem else {
                return
        }
        
        increaseTooltipActionsCount()
        
        askTooltipPresenter = TooltipView.showTooltip(
            withText: ASAPP.strings.chatAskTooltip,
            targetBarButtonItem: buttonItem,
            parentView: navView,
            onDismiss: { [weak self] in
                self?.askTooltipPresenter = nil
            })
    }
}

// MARK:- Layout

extension ChatViewController {
    
    func updateFrames() {
        // Predictive
        if let predictiveView = predictiveNavController?.view {
            if let navView = navigationController?.view {
                predictiveView.frame = navView.bounds
            } else {
                predictiveView.frame = view.bounds
            }
        }
        
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
        
        let inputHeight = ceil(chatInputView.sizeThatFits(CGSize(width: viewWidth, height: 300)).height)
        var inputTop = view.bounds.height
        if isLiveChat {
            inputTop = view.bounds.height - keyboardOffset - inputHeight
        }
        chatInputView.frame = CGRect(x: 0, y: inputTop, width: viewWidth, height: inputHeight)
        chatInputView.layoutSubviews()
        
        let repliesHeight: CGFloat = quickRepliesActionSheet.preferredDisplayHeight()
        var repliesTop = view.bounds.height
        if quickRepliesMessage != nil && !isLiveChat {
            repliesTop -= repliesHeight
        }
        quickRepliesActionSheet.frame = CGRect(x: 0.0, y: repliesTop, width: viewWidth, height: repliesHeight)
        
        let messagesHeight = min(chatInputView.frame.minY,
                                 quickRepliesActionSheet.frame.minY + quickRepliesActionSheet.transparentInsetTop)
        chatMessagesView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: messagesHeight)
        chatMessagesView.layoutSubviews()
        chatMessagesView.contentInsetTop = minVisibleY
        
        if quickRepliesMessage != nil {
            chatInputView.endEditing(true)
        }
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

// MARK:- KeyboardObserver

extension ChatViewController: KeyboardObserverDelegate {
    
    func keyboardWillUpdateVisibleHeight(_ height: CGFloat, withDuration duration: TimeInterval, animationCurve: UIViewAnimationOptions) {
        keyboardOffset = height
        if height > 0 {
            keyboardRenderedHeight = height
        }
        
        updateFramesAnimated()
    }
}

// MARK:- Handling Actions

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
        
        let formData = message?.attachment?.template?.getData()
        
        switch action.type {
        case .api:
            conversationManager.sendRequestForAPIAction(action as! APIAction, formData: formData, completion: { [weak self] (response) in
                guard let response = response else {
                    self?.quickRepliesActionSheet.deselectCurrentSelection(animated: true)
                    return
                }
                
                switch response.type {
                case .error:
                    self?.showRequestErrorAlert(message: response.error?.userMessage)
                    if quickReply != nil {
                        self?.quickRepliesActionSheet.deselectCurrentSelection(animated: true)
                    }
                    
                case .componentView:
                    // Show view
                    break
                    
                case .refreshView,
                     .finish:
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
                
                dismiss(animated: true, completion: { [weak self] in
                    self?.appCallbackHandler(deepLinkAction.name, deepLinkAction.data)
                })
            }
            
        case .finish:
            // No meaning in this context
            break
            
        case .http:
            if let httpAction = action as? HTTPAction {
                conversationManager.sendRequestForHTTPAction(action, formData: formData, completion: { [weak self] (response) in
                    if let onResponseAction = httpAction.onResponseAction {
                        if let response = response {
                            onResponseAction.injectData(key: "response", value: response)
                        }
                        self?.performAction(onResponseAction)
                    }
                })
            }
            
        case .legacyAppAction:
            if let appAction = action as? AppAction {
                let leaveFeedbackViewController = LeaveFeedbackViewController()
                leaveFeedbackViewController.issueId = appAction.eventMetadata.issueId
                leaveFeedbackViewController.delegate = self
                present(leaveFeedbackViewController, animated: true, completion: nil)
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
                let completionBlock: ASAPPUserLoginHandlerCompletion = { [weak self] (_ user: ASAPPUser) in
                    self?.clearQuickRepliesActionSheet(true, completion: nil)
                    self?.updateUser(user, with: userLoginAction)
                }
                
                user.userLoginHandler(completionBlock)
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

// MARK:- ChatMessagesViewDelegate

extension ChatViewController: ChatMessagesViewDelegate {
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTapImageView imageView: UIImageView,
                          from message: ChatMessage) {
        guard let image = imageView.image else {
            return
        }
        
        view.endEditing(true)
        
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
        view.endEditing(true)
    }
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTap buttonItem: ButtonItem,
                          from message: ChatMessage) {
        performAction(buttonItem.action, fromMessage: message, buttonItem: buttonItem)
        
        /// TODO: MITCH MITCH MITCH Disable this button until request is performed, if necessary
    }
}

// MARK:- ComponentViewControllerDelegate

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
                                 withFormData formData: [String : Any]?,
                                 completion: @escaping APIActionResponseHandler) {
        conversationManager.sendRequestForAPIAction(action, formData: formData, completion: { (response) in
            completion(response)
        })
    }
}

// MARK:- PredictiveViewController

extension ChatViewController: PredictiveViewControllerDelegate {
    
    func setPredictiveViewControllerVisible(_ visible: Bool, animated: Bool, completion: (() -> Void)?) {
        if visible == predictiveVCVisible {
            return
        }
        
        predictiveVCVisible = visible
        predictiveVC.view.endEditing(true)
        view.endEditing(true)
        
        if visible {
            clearQuickRepliesActionSheet(true)
            keyboardObserver.deregisterForNotification()
        } else {
            keyboardObserver.registerForNotifications()
        }
        
        guard let welcomeView = predictiveNavController?.view else { return }
        let alpha: CGFloat = visible ? 1 : 0
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                welcomeView.alpha = alpha
                self?.updateStatusBar(false)
            }, completion: { [weak self] _ in
                self?.predictiveVC.presentingViewUpdatedVisibility(visible)
                completion?()
                
                if !visible {
                    Dispatcher.delay(4000) {
                        self?.showAskButtonTooltipIfNecessary()
                    }
                }
            })
        } else {
            welcomeView.alpha = alpha
            predictiveVC.presentingViewUpdatedVisibility(visible)
            updateStatusBar(false)
            completion?()
        }
        
    }
    
    // MARK: Delegate
    
    func predictiveViewController(_ viewController: PredictiveViewController,
                                  didFinishWithText queryText: String,
                                  fromPrediction: Bool) {
        
        conversationManager.originalSearchQuery = queryText
        
        keyboardObserver.registerForNotifications()
        chatMessagesView.overrideToHideInfoView = true
        chatMessagesView.scrollToBottomAnimated(false)
        
        clearQuickRepliesActionSheet()
        setPredictiveViewControllerVisible(false, animated: true) { [weak self] in
            Dispatcher.delay(250, closure: {
                self?.sendMessage(withText: queryText, fromPrediction: fromPrediction)
            })
        }
    }
    
    func predictiveViewControllerDidTapViewChat(_ viewController: PredictiveViewController) {
        setPredictiveViewControllerVisible(false, animated: true) { [weak self] in
            self?.showQuickRepliesActionSheetIfNecessary()
        }
        
        conversationManager.trackButtonTap(buttonName: .showChatFromPredictive)
    }
    
    func predictiveViewControllerDidTapX(_ viewController: PredictiveViewController) {
        conversationManager.trackButtonTap(buttonName: .closeChatFromPredictive)
        
        dismissChatViewController()
    }
    
    func predictiveViewControllerIsConnected(_ viewController: PredictiveViewController) -> Bool {
        if connectionStatus == .connected {
            return true
        }
        
        reconnect()
        
        return false
    }
}

// MARK:- ChatInputViewDelegate

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
}

// MARK:- Showing/Hiding ChatquickRepliesActionSheet

extension ChatViewController {
    
    // MARK: Showing
    
    func showQuickRepliesActionSheetIfNecessary(animated: Bool = true, completion: (() -> Void)? = nil) {
        if let quickReplyMessages = conversationManager.getQuickReplyMessages() {
            showQuickRepliesActionSheetIfNecessary(with: quickReplyMessages, animated: animated, completion: completion)
        }
    }
    
    private func showQuickRepliesActionSheetIfNecessary(with messages: [ChatMessage]?,
                                                        animated: Bool = true,
                                                        completion: (() -> Void)? = nil) {
        guard let messages = messages else { return }
            
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
}

// MARK:- QuickRepliesActionSheetDelegate

extension ChatViewController: QuickRepliesActionSheetDelegate {
    
    func quickRepliesActionSheetDidCancel(_ actionSheet: QuickRepliesActionSheet) {
        if isLiveChat {
            _ = chatInputView.becomeFirstResponder()
        }
        clearQuickRepliesActionSheet()
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
        return performAction(quickReply.action, fromMessage: message, quickReply: quickReply)
    }
}

// MARK:- ConversationManagerDelegate

extension ChatViewController: ConversationManagerDelegate {
    
    // New Messages
    func conversationManager(_ manager: ConversationManager, didReceive message: ChatMessage) {
        provideHapticFeedbackForMessageIfNecessary(message)
        if message.metadata.eventType == .newRep {
            ASAPP.soundEffectPlayer.playSound(.liveChatNotification)
        }
        
        if message.metadata.eventType == .conversationEnd {
            Dispatcher.delay(1000, closure: { [weak self] in
                self?.showAskButtonTooltipIfNecessary(showRegardlessCount: true)
            })
        }
    
        chatMessagesView.addMessage(message) { [weak self] in
            if message.quickReplies != nil {
                self?.didReceiveMessageWithQuickReplies(message)
            } else if message.metadata.isReply {
                self?.clearQuickRepliesActionSheet(true, completion: nil)
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
            connectedAtLeastOnce = true
            delayedDisconnectTime = nil
        } else if delayedDisconnectTime == nil {
            delayedDisconnectTime = Date(timeIntervalSinceNow: 2) // 2 seconds from now
            Dispatcher.delay(2300) { [weak self] in
                self?.updateFramesAnimated()
            }
        }
        
        connectionStatus = isConnected ? .connected : .disconnected
        updateFramesAnimated(scrollToBottomIfNearBottom: false)
        
        if isConnected {
            // Fetch events
            reloadMessageEvents()
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
        
        // Immediate Action
        if let autoSelectQuickReply = message.getAutoSelectQuickReply() {
            Dispatcher.delay(1200) { [weak self] in
                self?.performAction(autoSelectQuickReply.action, fromMessage: message, quickReply: autoSelectQuickReply)
            }
        }
        
        // Show Suggested Replies View
        else {
            // Already Visible
            if quickRepliesActionSheet.frame.minY < view.bounds.height {
                Dispatcher.delay(200) { [weak self] in
                    self?.showQuickRepliesActionSheet(with: message)
                }
            } else {
                // Not visible yet
                Dispatcher.delay(1000) { [weak self] in
                    self?.showQuickRepliesActionSheet(with: message)
                }
            }
        }
    }
}

// MARK:- UIImagePickerControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : Any]) {
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

// MARK:- Actions

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
    }
    
    func reloadMessageEvents() {
        conversationManager.getEvents { [weak self] (fetchedEvents, _) in
            if let strongSelf = self, let fetchedEvents = fetchedEvents {
                strongSelf.quickRepliesMessage = nil
                strongSelf.showQuickRepliesActionSheetIfNecessary(animated: true)
                strongSelf.chatMessagesView.reloadWithEvents(fetchedEvents)
                strongSelf.isLiveChat = strongSelf.conversationManager.isLiveChat
                
                if fetchedEvents.last?.eventType == .conversationEnd {
                    Dispatcher.delay(1000, closure: { [weak self] in
                        self?.showAskButtonTooltipIfNecessary(showRegardlessCount: true)
                    })
                }
            }
        }
    }
}

// MARK:- CreditCardAPIDelegate

extension ChatViewController: CreditCardAPIDelegate {
    
    func uploadCreditCard(creditCard: CreditCard, completion: @escaping ((CreditCardResponse) -> Void)) -> Bool {
        guard conversationManager.isConnected(retryConnectionIfNeeded: true) else {
            return false
        }
        
        conversationManager.sendCreditCard(creditCard, completion: completion)
        
        return true
    }
}

// MARK:- RatingAPIDelegate

extension ChatViewController: RatingAPIDelegate {
    
    func sendRating(_ rating: Int, forIssueId issueId: Int, withFeedback feedback: String?, completion: @escaping ((Bool) -> Void)) -> Bool {
        guard conversationManager.isConnected(retryConnectionIfNeeded: true) else {
            return false
        }
        
        conversationManager.sendRating(rating, forIssueId: issueId, withFeedback: feedback, completion: completion)
        
        return true
    }
}
