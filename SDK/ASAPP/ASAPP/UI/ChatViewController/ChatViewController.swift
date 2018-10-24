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
    private var store: Store<UIState>
    
    // MARK: Properties: Public
    
    let config: ASAPPConfig
    
    private(set) var user: ASAPPUser!
    
    // MARK: Properties: Storage
    
    private(set) var conversationManager: ConversationManagerProtocol!
    private var quickRepliesMessage: ChatMessage?

    // MARK: Properties: Views / UI

    private var backgroundLayer: CALayer?
    private let chatMessagesView = ChatMessagesView()
    private var chatInputView: ChatInputView?
    private let connectionStatusView = ChatConnectionStatusView()
    private let quickRepliesView = QuickRepliesView()
    private var gatekeeperView: GatekeeperView?
    private var actionSheet: BaseActionSheet?
    private var notificationBanner: NotificationBanner?
    private var hapticFeedbackGenerator: Any?
    private let spinner = UIActivityIndicatorView(activityIndicatorStyle: .gray)
    
    // MARK: Properties: Status

    var doneTransitioning: Bool {
        return store.state.transitionCoordinator == nil
    }
    private var didConnectAtLeastOnce = false
    private var isInitialLayout = true
    private var previousState: UIState?
    private var delayedDisconnectTime: Date?
    private let disconnectedTimeThreshold: TimeInterval = 2
    private var segue: Segue = .present
    private var shouldHideActionSheetOnNextMessage = false
    private var fetchingBefore: Event?
    private var fetchingAfter: Event?
    private var shouldFetchEarlier = true
    private var shouldReloadOnUserUpdate = false
    private var nextAction: Action?
    private var isAppInForeground = true
    private var scrollingCompletionTime: Date?
    private var insetStateTimer: Timer?
    
    // MARK: Properties: Autosuggest
    
    private var selectedSuggestionMetadata: AutosuggestMetadata?
    private var partialAutosuggestMetadataByResponseId: [AutosuggestMetadata.ResponseId: AutosuggestMetadata] = [:]
    private var keystrokesBeforeSelection = 0
    private var keystrokesAfterSelection = 0
    private let autosuggestThrottler = Throttler(interval: 0.1)
    private var pendingAutosuggestRequestQueries: [String] = []
    private let maxPendingAutosuggestRequests = 10
    
    // MARK: Properties: Keyboard
    
    private var keyboardObserver = KeyboardObserver()
    private var keyboardOffset: CGFloat = 0
    private var keyboardRenderedHeight: CGFloat = 0
    
    override var inputAccessoryView: UIView? {
        return chatInputView
    }
    
    override var canBecomeFirstResponder: Bool {
        return true
    }

    // MARK: - Initialization
    
    init(config: ASAPPConfig, user: ASAPPUser, segue: Segue, conversationManager: ConversationManagerProtocol, pushNotificationPayload: [AnyHashable: Any]? = nil) {
        self.config = config
        self.segue = segue
        self.conversationManager = conversationManager
        self.store = Store<UIState>(reducer: Reducers.reduceUIState, state: nil)
        super.init(nibName: nil, bundle: nil)
        
        self.store.subscribe(self)
        self.user = user
        self.conversationManager.delegate = self
        self.conversationManager.pushNotificationPayload = pushNotificationPayload
        
        automaticallyAdjustsScrollViewInsets = false
        
        let side = closeButtonSide(for: segue)
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
        
        chatMessagesView.delegate = self
        
        chatInputView = createChatInput()
        chatInputView?.alpha = 0
        
        quickRepliesView.delegate = self
        quickRepliesView.isHidden = true
        
        connectionStatusView.onTapToConnect = { [weak self] in
            self?.reconnect()
        }
        
        updateDisplay()
        
        NotificationCenter.default.addObserver(self, selector: #selector(updateDisplay), name: NSNotification.Name.UIContentSizeCategoryDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(userDidChange), name: .UserDidChange, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appDidEnterBackground), name: NSNotification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(appWillEnterForeground), name: NSNotification.Name.UIApplicationWillEnterForeground, object: nil)

        keyboardObserver.delegate = self
        
        if #available(iOS 10.0, *) {
            hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            if let generator = hapticFeedbackGenerator as? UIImpactFeedbackGenerator {
                generator.prepare()
            }
        }
    }
    
    private func createChatInput() -> ChatInputView {
        let input = ChatInputView()
        input.delegate = self
        input.displayMediaButton = false
        input.isRounded = true
        return input
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: Deinit
    
    deinit {
        insetStateTimer?.cancel()
        insetStateTimer = nil
        conversationManager.exitConversation()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK: Dynamic Properties
    
    private var connectionStatus: ChatConnectionStatus = .disconnected {
        didSet {
            connectionStatusView.status = connectionStatus
        }
    }
    
    private var shouldShowConnectionStatusView: Bool {
        guard isAppInForeground else {
            return false
        }
        
        if connectionStatus == .disconnected && shouldReloadOnUserUpdate {
            return false
        }
        
        if !didConnectAtLeastOnce {
            return connectionStatus == .disconnected
        }
        
        if let delayedDisconnectTime = delayedDisconnectTime {
            if connectionStatus != .connected && delayedDisconnectTime.hasPassed() {
                return true
            } else {
                return false
            }
        }
        
        return connectionStatus == .connecting || connectionStatus == .disconnected
    }
    
    // MARK: User
    
    @objc func userDidChange() {
        updateUser(ASAPP.user, with: ASAPP.userLoginAction)
    }
    
    func updateUser(_ user: ASAPPUser, with userLoginAction: UserLoginAction? = nil) {
        DebugLog.d("Updating user. userIdentifier=\(user.userIdentifier)")
        if let previousSession = userLoginAction?.previousSession {
            DebugLog.d("Merging Accounts: {\n  MergeCustomerId: \(previousSession.customer.id),\n  MergeCustomerGUID: \(previousSession.customer.guid ?? "nil"),\n SessionId: \(previousSession.id)}")
        }
        
        if conversationManager != nil {
            clearQuickRepliesView(animated: false)
            conversationManager.delegate = nil
            conversationManager.exitConversation()
        }
        
        self.user = user
        conversationManager = type(of: conversationManager).init(config: config, user: user, userLoginAction: userLoginAction)
        conversationManager.delegate = self
        if conversationManager.isLiveChat != store.state.isLiveChat {
            store.dispatch(DidChangeLiveChatStatus(isLiveChat: conversationManager.isLiveChat, updateInput: false))
        }
        
        func reEnter() {
            shouldReloadOnUserUpdate = false
            chatMessagesView.clear()
            hideGatekeeperView()
            spinner.alpha = 1
            conversationManager.enterConversation()
        }
        
        if let nextAction = userLoginAction?.nextAction {
            self.nextAction = nextAction
            reEnter()
            return
        }
        
        if shouldReloadOnUserUpdate {
            reEnter()
            return
        }
        
        if connectionStatus != .connected {
            gatekeeperView?.showSpinner()
            conversationManager.enterConversation()
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
        
        let background = view.createLinearGradient(degrees: 161, colors: ASAPP.styles.colors.messagesListGradientColors)
        backgroundLayer = background
        view.layer.insertSublayer(background, at: 0)
        
        spinner.startAnimating()
        
        view.addSubview(chatMessagesView)
        view.addSubview(quickRepliesView)
        view.addSubview(connectionStatusView)
        view.addSubview(spinner)
        
        // Load Events
        if conversationManager.isConnected {
            reloadMessageEvents()
            updateFramesAnimated(false)
        } else {
            connectionStatus = .connecting
            updateFramesAnimated(false)
            delayedDisconnectTime = Date(timeIntervalSinceNow: disconnectedTimeThreshold)
            conversationManager.enterConversation()
            Dispatcher.delay(.seconds(disconnectedTimeThreshold) + .defaultAnimationDuration) { [weak self] in
                self?.updateFramesAnimated(false, scrollToBottomIfNearBottom: false)
            }
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        if let rawOrientation = UIDevice.current.value(forKeyPath: "orientation") as? Int,
            let orientation = UIInterfaceOrientation(rawValue: rawOrientation),
            orientation == .portrait {
            store.dispatch(DidTransition())
        } else if UIDevice.current.userInterfaceIdiom == .phone {
            UIDevice.current.setValue(UIInterfaceOrientation.portrait.rawValue, forKeyPath: "orientation")
            UIViewController.attemptRotationToDeviceOrientation()
        } else {
            store.dispatch(DidTransition())
        }
        
        keyboardObserver.registerForNotifications()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.deregisterForNotification()
        
        if isMovingFromParentViewController {
            chatInputView?.resignFirstResponder()
            chatInputView?.alpha = 0
            reloadInputViews()
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        if !isMovingToParentViewController {
            chatMessagesView.focusAccessibilityOnLastMessage(delay: false)
        }
    }
    
    override func viewDidDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        if parent?.isMovingFromParentViewController == true || parent?.isBeingDismissed == true {
            ASAPP.delegate?.chatViewControllerDidDisappear()
        }
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        super.viewWillTransition(to: size, with: coordinator)
        
        store.dispatch(WillTransition(size: size, coordinator: coordinator))
    }
    
    // MARK: - Status Bar
    
    override var preferredStatusBarStyle: UIStatusBarStyle {
        return (ASAPP.styles.colors.navBarBackground?.isDark() == true) ? .lightContent : .default
    }
    
    // MARK: View Layout Overrides
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if isInitialLayout {
            chatMessagesView.scrollToBottom(animated: false)
            isInitialLayout = false
        }
    }
    
    @objc func appWillEnterForeground() {
        isAppInForeground = true
    }
    
    @objc func appDidEnterBackground() {
        isAppInForeground = false
        conversationManager.exitConversation()
    }
}

// MARK: - State Rendering

extension ChatViewController: StoreSubscriber {
    typealias StoreSubscriberStateType = UIState
    
    func newState(state: UIState) {
        guard state.animation != .done else {
            return
        }
        
        let animated = state.animation == .needsToAnimate
        var shouldScroll = false
        
        chatInputView?.update(for: state.queryUI.autosuggest)
        
        if [.newQuestionAlone, .newQuestionAloneLoading, .chatInputWithQuickReplies].contains(state.queryUI.input) {
            shouldScroll = true
        }
        
        if ![.prechat, .chatInput(keyboardIsVisible: true), .liveChat(keyboardIsVisible: true)].contains(state.queryUI.input) {
            chatInputView?.resignFirstResponder()
        }
        
        if [.prechat,
            .chatInput(keyboardIsVisible: true),
            .chatInput(keyboardIsVisible: false),
            .liveChat(keyboardIsVisible: true),
            .liveChat(keyboardIsVisible: false)].contains(state.queryUI.input) {
            if #available(iOS 11.0, *) {
                chatInputView?.prepareForFocus(in: view.safeAreaInsets)
            } else {
                chatInputView?.prepareForFocus()
            }
        }
        
        if (previousState?.isLiveChat ?? false) != state.isLiveChat {
            DebugLog.d("Chat Mode Changed: \(state.isLiveChat ? "LIVE CHAT" : "SRS")")
            conversationManager.currentSRSClassification = state.isLiveChat ? nil : quickRepliesView.currentSRSClassification
            if isViewLoaded {
                updateViewForLiveChat(animated: animated)
            }
        }
        
        if state.queryUI.input != .newQuestionWithInset {
            quickRepliesView.reset()
        }
        
        if [.chatInputWithQuickReplies, .quickRepliesAlone, .quickRepliesWithNewQuestion].contains(state.queryUI.input) {
            if let lastReply = state.lastReply {
                showQuickRepliesView(with: lastReply, animated: animated)
                shouldScroll = true
            }
        } else if [.newQuestionWithInset, .inset].contains(state.queryUI.input) {
            quickRepliesView.fadeOut(showRestartButton: state.queryUI.input == .newQuestionWithInset, animated: animated)
        } else if ![.prechat].contains(state.queryUI.input) {
            let shouldAnimate = state.queryUI.input != .newQuestionAloneLoading
            clearQuickRepliesView(animated: shouldAnimate && animated)
        }
        
        if state.queryUI.input == .newQuestionAloneLoading {
            quickRepliesView.showRestartSpinner()
        } else {
            quickRepliesView.hideRestartSpinner()
        }
        
        if let size = state.transitionSize,
           let coordinator = state.transitionCoordinator {
            transition(to: size, with: coordinator)
        } else {
            updateFramesAnimated(animated, scrollToBottomIfNearBottom: shouldScroll) { [weak self] in
                if animated {
                    self?.store.dispatch(AnimationEnded())
                }
                if [.newQuestionWithInset, .inset].contains(state.queryUI.input) {
                    self?.updateHeightOfQuickRepliesView()
                }
            }
        }
        
        insetStateTimer?.cancel()
        
        if state.queryUI.input == .inset {
            insetStateTimer = Timer(delay: .seconds(3.5)) {
                Dispatcher.performOnMainThread { [weak self] in
                    self?.store.dispatch(DidWaitInInsetState())
                }
            }
            insetStateTimer?.start()
        }
        
        previousState = state
    }
    
    private func transition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        let longest = max(size.width, size.height)
        let newBounds = CGRect(origin: .zero, size: CGSize(width: longest, height: longest))
        view.layer.frame = newBounds
        backgroundLayer?.frame = newBounds
        
        let oldInputAlpha = chatInputView?.alpha ?? 0
        if chatInputView?.alpha == 0 {
            chatInputView = nil
            reloadInputViews()
        }
        quickRepliesView.hideBlur()
        
        coordinator.animate(alongsideTransition: { [weak self] context in
            guard let strongSelf = self else {
                return
            }
            strongSelf.updateFramesAnimated(duration: context.transitionDuration, scrollToBottomIfNearBottom: false, bounds: context.containerView.bounds)
        }, completion: { [weak self] context in
            guard let strongSelf = self else {
                return
            }
            strongSelf.view.layer.frame = context.containerView.bounds
            strongSelf.backgroundLayer?.frame = context.containerView.bounds
            strongSelf.quickRepliesView.showBlur()
            Dispatcher.performOnMainThread {
                if strongSelf.chatInputView == nil {
                    let input = strongSelf.createChatInput()
                    input.alpha = oldInputAlpha
                    strongSelf.chatInputView = input
                } else {
                    strongSelf.chatInputView?.alpha = oldInputAlpha
                }
                
                strongSelf.reloadInputViews()
            }
            strongSelf.updateFrames()
            strongSelf.updateNavigationBar()
            strongSelf.store.dispatch(DidTransition())
        })
    }
}

// MARK: - Display Update

extension ChatViewController {
    @objc func updateDisplay() {
        if let titleView = ASAPP.views.chatTitle {
            navigationItem.titleView = titleView
        } else if let titleText = ASAPP.strings.chatTitle {
            navigationItem.titleView = createASAPPTitleView(title: titleText)
        } else {
            navigationItem.titleView = nil
        }
        
        notificationBanner?.updateDisplay()
        chatMessagesView.updateDisplay()
        quickRepliesView.updateDisplay()
        connectionStatusView.updateDisplay()
        chatInputView?.updateDisplay()
        
        if isViewLoaded {
            updateFrames()
            view.setNeedsLayout()
        }
    }
    
    func updateShadows() {
        if shouldShowConnectionStatusView || notificationBanner == nil {
            navigationController?.navigationBar.applyASAPPStyles()
        } else {
            navigationController?.navigationBar.removeShadow()
        }
        
        if let banner = notificationBanner {
            banner.layer.shadowOffset = CGSize(width: 0, height: 2)
            banner.layer.shadowColor = UIColor(red: 0, green: 0, blue: 0, alpha: 0.01).cgColor
            banner.layer.shadowOpacity = 1
            banner.layer.shadowRadius = 10
        }
    }
    
    func updateMoreButton() {
        let side = closeButtonSide(for: segue).opposite()
        
        func setBarButtonItem(_ item: NavBarButtonItem?) {
            switch side {
            case .left:
                navigationItem.leftBarButtonItem = item
            case .right:
                navigationItem.rightBarButtonItem = item
            }
        }
        
        guard store.state.isLiveChat else {
            setBarButtonItem(nil)
            return
        }
        
        let moreIcon = ASAPP.styles.navBarStyles.buttonImages.more
        let moreButton = NavBarButtonItem(location: .chat, side: side)
        if let moreIcon = moreIcon {
            moreButton.configImage(moreIcon)
        }
        moreButton.configTarget(self, action: #selector(ChatViewController.didTapMoreButton))
        moreButton.accessibilityLabel = ASAPPLocalizedString("Menu")
        setBarButtonItem(moreButton)
    }
    
    func closeButtonSide(for segue: Segue) -> NavBarButtonSide {
        return segue == .present ? .right : .left
    }
}

// MARK: Connection

extension ChatViewController {
    func reconnect() {
        if connectionStatus == .disconnected {
            connectionStatus = .connecting
            conversationManager.enterConversation()
        }
    }
    
    func updateViewForLiveChat(animated: Bool = true) {
        chatInputView?.placeholderText = ASAPP.strings.chatInputPlaceholder
        
        updateMoreButton()
        
        if store.state.queryUI.input.isLiveChat {
            chatInputView?.needsToBecomeFirstResponder = true
        } else {
            chatInputView?.resignFirstResponder()
        }
        
        chatInputView?.displayMediaButton = store.state.queryUI.input.isLiveChat
        
        let selected = chatInputView?.textView.selectedTextRange ?? .init()
        let wasFirstResponder = chatInputView?.isFirstResponder ?? false
        keyboardObserver.deregisterForNotification()
        chatInputView?.resignFirstResponder()
        chatInputView?.textView.autocorrectionType = store.state.queryUI.input.isLiveChat ? .default : .no
        chatInputView?.textView.selectedTextRange = selected
        keyboardObserver.registerForNotifications()
        if wasFirstResponder {
            chatInputView?.alpha = 1
            chatInputView?.becomeFirstResponder()
        }
        
        reloadInputViews()
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
    @objc func didTapCloseButton() {
        dismissChatViewController()
    }
    
    @objc func didTapMoreButton() {
        chatInputView?.resignFirstResponder()
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        
        let endAction = UIAlertAction(title: ASAPP.strings.endChatTitle, style: .destructive, handler: { [weak self] _ in
            if self?.conversationManager.endLiveChat() != true {
                self?.shakeConnectionStatusView()
            } else {
                self?.scrollToBottomBeforeAddingNextMessage()
            }
        })
        endAction.accessibilityTraits += UIAccessibilityTraitStartsMediaSession
        alertController.addAction(endAction)
        
        alertController.addAction(UIAlertAction(title: ASAPPLocalizedString("Cancel"), style: .cancel, handler: { [weak self] _ in
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, self?.chatInputView)
        }))
        
        let side = closeButtonSide(for: segue).opposite()
        guard
            let barButtonItem = side == .left ? navigationItem.leftBarButtonItem : navigationItem.rightBarButtonItem,
            let button = barButtonItem.customView as? UIButton
        else {
            return
        }
        
        alertController.popoverPresentationController?.sourceView = button
        alertController.popoverPresentationController?.sourceRect = button.imageView?.frame ?? .zero
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK: - Layout

extension ChatViewController {
    
    func updateFrames(in bounds: CGRect? = nil) {
        let inputState = store.state.queryUI.input
        let bounds = bounds ?? view.frame
        let viewWidth = bounds.width
        var minVisibleY: CGFloat = navigationController?.navigationBar.frame.maxY ?? 0
        
        let connectionStatusViewSize = connectionStatusView.sizeThatFits(CGSize(width: viewWidth, height: .greatestFiniteMagnitude))
        let connectionStatusTop = shouldShowConnectionStatusView ? minVisibleY - view.frame.minY : -connectionStatusViewSize.height
        connectionStatusView.isHidden = !shouldShowConnectionStatusView
        
        func updateConnectionStatusView() {
            connectionStatusView.frame = CGRect(origin: CGPoint(x: 0, y: connectionStatusTop), size: connectionStatusViewSize)
            connectionStatusView.updateFrames(in: CGRect(origin: .zero, size: connectionStatusViewSize))
            connectionStatusView.layoutIfNeeded()
        }
        
        if let banner = notificationBanner {
            let bannerSize = banner.sizeThatFits(bounds.size)
            banner.frame = CGRect(x: 0, y: banner.shouldHide ? -bannerSize.height : minVisibleY, width: viewWidth, height: bannerSize.height)
            banner.updateFrames(in: CGRect(origin: .zero, size: bannerSize))
            banner.layoutIfNeeded()
            
            if !banner.shouldHide {
                minVisibleY += banner.bannerContainerHeight
            }
        }
        
        chatMessagesView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: bounds.height)
        chatMessagesView.setNeedsLayout()
        chatMessagesView.layoutIfNeeded()
        chatMessagesView.contentInsetTop = minVisibleY
        
        spinner.alpha = chatMessagesView.isEmpty && gatekeeperView == nil && connectionStatusView.isHidden && actionSheet == nil ? 1 : 0
        spinner.center = view.center
        
        let quickRepliesHeight: CGFloat
        
        quickRepliesView.contentInsetBottom = 0
        
        func hideChatInput() {
            chatInputView?.prepareForNormalState()
            chatInputView?.hideBlur()
            chatInputView?.alpha = 0
        }
        
        switch inputState {
        case .prechat, .chatInput, .liveChat:
            chatInputView?.alpha = 1
            quickRepliesHeight = 0
            quickRepliesView.isHidden = true
            quickRepliesView.isRestartButtonVisible = false
            chatMessagesView.contentInsetBottom = ceil(keyboardRenderedHeight)
            
        case .chatInputWithQuickReplies:
            chatInputView?.prepareForNormalState()
            quickRepliesView.isHidden = false
            quickRepliesView.isRestartButtonVisible = false
            let fittedHeight = quickRepliesView.sizeThatFits(bounds.size).height
            let inputHeight = chatInputView?.frame.height ?? 0
            if inputHeight > 0 && quickRepliesView.contentHeight >= fittedHeight {
                quickRepliesView.contentInsetBottom = inputHeight
                chatInputView?.showBlur()
            }
            chatInputView?.alpha = 1
            quickRepliesHeight = fittedHeight + inputHeight
            chatMessagesView.contentInsetBottom = ceil(quickRepliesHeight)
            
        case .quickRepliesAlone:
            hideChatInput()
            quickRepliesView.isHidden = false
            quickRepliesView.isRestartButtonVisible = false
            quickRepliesHeight = quickRepliesView.sizeThatFits(bounds.size).height
            chatMessagesView.contentInsetBottom = ceil(quickRepliesHeight)
            
        case .quickRepliesWithNewQuestion:
            hideChatInput()
            quickRepliesView.isHidden = false
            quickRepliesView.isRestartButtonVisible = true
            quickRepliesHeight = quickRepliesView.sizeThatFits(bounds.size).height
            chatMessagesView.contentInsetBottom = ceil(quickRepliesHeight)
            
        case .newQuestionAlone, .newQuestionAloneLoading:
            hideChatInput()
            quickRepliesView.isHidden = false
            quickRepliesView.isRestartButtonVisible = true
            quickRepliesHeight = quickRepliesView.sizeThatFits(bounds.size).height
            chatMessagesView.contentInsetBottom = ceil(quickRepliesHeight)
            
        case .newQuestionWithInset:
            hideChatInput()
            quickRepliesView.isHidden = false
            quickRepliesView.isRestartButtonVisible = true
            let inset = quickRepliesView.sizeThatFills(bounds.size).height
            quickRepliesHeight = inset
            chatMessagesView.contentInsetBottom = ceil(inset)
            
        case .inset:
            hideChatInput()
            quickRepliesView.isHidden = false
            quickRepliesView.isRestartButtonVisible = false
            let inset = quickRepliesView.sizeThatFills(bounds.size).height
            quickRepliesHeight = inset
            chatMessagesView.contentInsetBottom = ceil(inset)
            
        case .empty:
            hideChatInput()
            quickRepliesView.isHidden = true
            quickRepliesView.isRestartButtonVisible = false
            quickRepliesHeight = quickRepliesView.sizeThatFits(bounds.size).height
            chatMessagesView.contentInsetBottom = ceil(quickRepliesHeight)
        }
        
        quickRepliesView.frame = CGRect(x: 0, y: bounds.maxY - quickRepliesHeight, width: viewWidth, height: quickRepliesHeight)
        quickRepliesView.updateFrames(in: bounds)
        quickRepliesView.layoutIfNeeded()
        
        if (chatInputView?.alpha ?? 0) == 1 && (chatInputView?.needsToBecomeFirstResponder ?? false) {
            chatInputView?.alpha = 1
            chatInputView?.becomeFirstResponder()
            chatInputView?.needsToBecomeFirstResponder = false
        }
        
        actionSheet?.frame = bounds
        actionSheet?.updateFrames(in: bounds)
        actionSheet?.layoutIfNeeded()
        
        if store.state.transitionCoordinator != nil {
            updateConnectionStatusView()
        } else {
            UIView.performWithoutAnimation {
                updateConnectionStatusView()
            }
        }
    }
    
    private func updateHeightOfQuickRepliesView() {
        let bounds = view.frame
        let quickRepliesHeight = quickRepliesView.sizeThatFits(bounds.size).height
        quickRepliesView.frame = CGRect(x: 0, y: bounds.maxY - quickRepliesHeight, width: bounds.width, height: quickRepliesHeight)
        quickRepliesView.updateFrames(in: bounds)
        quickRepliesView.layoutIfNeeded()
    }
    
    func updateFramesAnimated(_ animated: Bool = true, duration: TimeInterval = 0.3, scrollToBottomIfNearBottom: Bool = true, bounds: CGRect? = nil, completion: (() -> Void)? = nil) {
        let wasNearBottom = chatMessagesView.isNearBottom() || chatMessagesView.isHidden
        if animated {
            if wasNearBottom && scrollToBottomIfNearBottom {
                chatMessagesView.scrollToBottom(animated: true)
            }
            
            UIView.animate(withDuration: duration, delay: 0, options: .curveEaseIn, animations: { [weak self] in
                self?.updateFrames(in: bounds)
            }, completion: { [weak self] _ in
                if wasNearBottom && scrollToBottomIfNearBottom {
                    self?.chatMessagesView.scrollToBottom(animated: true)
                }
                
                completion?()
            })
        } else {
            updateFrames(in: bounds)
            
            if wasNearBottom && scrollToBottomIfNearBottom {
                chatMessagesView.scrollToBottom(animated: false)
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
        
        let height = height - (chatInputView?.suggestionsViewSize() ?? .zero).height
        
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
        PushNotificationsManager.shared.requestAuthorizationIfNeeded(after: .seconds(3))
        
        let formData = message?.attachment?.template?.getData()
        
        switch action.type {
        case .api:
            conversationManager.sendRequestForAPIAction(action as! APIAction, formData: formData, completion: { [weak self] (response) in
                guard let response = response else {
                    Dispatcher.performOnMainThread { [weak self] in
                        self?.quickRepliesView.showPrevious()
                    }
                    return
                }
                
                switch response.type {
                case .finish:
                    if let nextAction = response.finishAction {
                        self?.performAction(nextAction)
                    }
                    
                case .error:
                    Dispatcher.performOnMainThread { [weak self] in
                        self?.showRequestErrorAlert(message: response.error?.userMessage)
                        if quickReply != nil {
                            self?.quickRepliesView.showPrevious()
                        }
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
            Dispatcher.performOnMainThread { [weak self] in
                guard let strongSelf = self else { return }
                strongSelf.showComponentView(fromAction: action, delegate: strongSelf)
            }
            
        case .deepLink:
            if let deepLinkAction = action as? DeepLinkAction {
                // NOTE: We need the title. Will it always be a quick reply? No
                conversationManager.sendRequestForDeepLinkAction(deepLinkAction, with: quickReply?.title ?? buttonItem?.title ?? "")
                
                Dispatcher.performOnMainThread {
                    ASAPP.delegate?.chatViewControlledDidTapDeepLink(name: deepLinkAction.name, data: deepLinkAction.data)
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
            
        case .link:
            if let linkAction = action as? LinkAction {
                conversationManager.resolve(linkAction: linkAction) { [weak self] resolvedAction in
                    guard let action = resolvedAction else {
                        return
                    }
                    self?.performAction(action)
                }
            }
            
        case .treewalk:
            Dispatcher.performOnMainThread { [weak self] in
                self?.scrollToBottomBeforeAddingNextMessage()
            }
            
            conversationManager.sendRequestForTreewalkAction(
                action as! TreewalkAction,
                messageText: quickReply?.title ?? buttonItem?.title,
                parentMessage: message,
                completion: { [weak self] success in
                    Dispatcher.performOnMainThread { [weak self] in
                        guard !success else {
                            return
                        }
                        self?.quickRepliesView.showPrevious()
                        self?.actionSheet?.hideSpinner()
                    }
            })
            
        case .userLogin:
            if let userLoginAction = action as? UserLoginAction {
                ASAPP.userLoginAction = userLoginAction
                Dispatcher.performOnMainThread {
                    ASAPP.delegate?.chatViewControllerDidTapUserLoginButton()
                }
            }
            
        case .web:
            if let webAction = action as? WebPageAction {
                Dispatcher.performOnMainThread { [weak self] in
                    let url = webAction.url
                    guard true == ASAPP.delegate?.chatViewControllerShouldHandleWebLink(url: url) else {
                        return
                    }
                    
                    if let urlScheme = url.scheme,
                       ["http", "https"].contains(urlScheme) {
                        let safariVC = SFSafariViewController(url: url)
                        self?.present(safariVC, animated: true, completion: nil)
                        return
                    }
                    
                    if UIApplication.shared.canOpenURL(url) {
                        UIApplication.shared.openURL(url)
                    }
                }
            }
            
        case .unknown:
            // No-op
            break
        }
        
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
        
        chatInputView?.resignFirstResponder()
        
        let imageViewerImage = ImageViewerImage(image: image)
        let imageViewer = ImageViewer(withImages: [imageViewerImage], initialIndex: 0)
        imageViewer.preparePresentationFromImageView(imageView)
        imageViewer.presentationImageCornerRadius = 10
        present(imageViewer, animated: true, completion: nil)
    }
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didUpdateQuickRepliesFrom message: ChatMessage) {
        if message == chatMessagesView.lastMessage {
            quickRepliesView.reloadButtons(for: message)
        }
    }
    
    func chatMessagesViewPerformedKeyboardHidingAction(_ messagesView: ChatMessagesView) {
        didHideKeyboard()
    }
    
    private func recordLinkActionSelected(action: LinkAction, title: String) {
        recordEvent(AnalyticsEvent(
            name: .actionLinkSelected,
            attributes: [
                "link": AnyEncodable(action.link),
                "linkText": AnyEncodable(title)
            ],
            metadata: action.metadata
        ))
    }
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTap buttonItem: ButtonItem,
                          from message: ChatMessage) {
        if let linkAction = buttonItem.action as? LinkAction {
            recordLinkActionSelected(action: linkAction, title: buttonItem.title ?? "")
        }
        
        performAction(buttonItem.action, fromMessage: message, buttonItem: buttonItem)
    }
    
    func chatMessagesView(_ messagesView: ChatMessagesView,
                          didTap button: QuickReply) {
        if let linkAction = button.action as? LinkAction {
            recordLinkActionSelected(action: linkAction, title: button.title)
        }
        
        performAction(button.action)
    }
    
    private func fetchEarlierIfNeeded() {
        guard let firstEvent = conversationManager.events.first,
              fetchingBefore != firstEvent,
              shouldFetchEarlier else {
            return
        }
        
        fetchingBefore = firstEvent
        let numberToFetch = chatMessagesView.pageSize
        conversationManager.getEvents(before: firstEvent, limit: numberToFetch) { [weak self] (fetchedEvents, _) in
            guard let strongSelf = self,
                  let fetchedEvents = fetchedEvents else {
                return
            }
            
            if fetchedEvents.count < numberToFetch || fetchedEvents.first?.eventLogSeq == 1 {
                strongSelf.shouldFetchEarlier = false
                strongSelf.chatMessagesView.shouldShowLoadingHeader = false
            }
            
            strongSelf.chatMessagesView.insertEvents(fetchedEvents)
            strongSelf.fetchingBefore = nil
        }
    }
    
    func chatMessagesViewDidScrollNearBeginning(_ messagesView: ChatMessagesView) {
        fetchEarlierIfNeeded()
    }
    
    private func fetchLater() {
        guard let lastEvent = conversationManager.events.last,
              fetchingAfter != lastEvent else {
            return
        }
        
        fetchingAfter = lastEvent
        conversationManager.getEvents(after: lastEvent) { [weak self] (fetchedEvents, _) in
            guard let strongSelf = self,
                  let fetchedEvents = fetchedEvents else {
                return
            }
            
            strongSelf.chatMessagesView.appendEvents(fetchedEvents)
            let newStatus = strongSelf.conversationManager.isLiveChat
            if newStatus != strongSelf.store.state.isLiveChat {
                strongSelf.store.dispatch(DidChangeLiveChatStatus(isLiveChat: newStatus, updateInput: true))
            }
            
            if let lastChatMessage = fetchedEvents.reversed().first(where: { $0.chatMessage != nil })?.chatMessage {
                strongSelf.handle(message: lastChatMessage, shouldAdd: false)
            }
            
            strongSelf.fetchingAfter = nil
        }
    }
    
    func scrollToBottomBeforeAddingNextMessage() {
        if !chatMessagesView.isNearBottom() {
            scrollingCompletionTime = Date().addingTimeInterval(DispatchTimeInterval.defaultAnimationDuration.seconds * 2)
            Dispatcher.performOnMainThread { [weak self] in
                self?.chatMessagesView.scrollToBottom(animated: true)
            }
        }
    }
    
    func chatMessagesViewShouldChangeAccessibilityFocus(_ messagesView: ChatMessagesView) -> Bool {
        return actionSheet == nil
    }
}

// MARK: - ComponentViewControllerDelegate

extension ChatViewController: ComponentViewControllerDelegate {
    
    func componentViewControllerDidFinish(with action: FinishAction?, container: ComponentViewContainer?) {
        recordEvent(AnalyticsEvent(
            name: .viewDismissed,
            attributes: [:],
            metadata: container?.metadata
        ))
        
        if let nextAction = action?.nextAction {
            quickRepliesView.disableAndClear()
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
    func chatInputView(_ chatInputView: ChatInputView, didSelectSuggestion suggestion: String, at index: Int, count: Int, responseId: AutosuggestMetadata.ResponseId) {
        autosuggestThrottler.cancel()
        
        store.dispatch(DidSelectSuggestion())
        
        selectedSuggestionMetadata = AutosuggestMetadata()
        selectedSuggestionMetadata?.suggestion = suggestion
        selectedSuggestionMetadata?.index = index
        selectedSuggestionMetadata?.displayedCount = count
        if let partial = partialAutosuggestMetadataByResponseId[responseId] {
            selectedSuggestionMetadata?.responseId = partial.responseId
            selectedSuggestionMetadata?.returnedCount = partial.returnedCount
            selectedSuggestionMetadata?.original = partial.original
        }
    }
    
    func chatInputView(_ chatInputView: ChatInputView, didTypeMessageText text: String?) {
        guard conversationManager.isConnected else {
            return
        }
        
        if store.state.queryUI.input.isLiveChat {
            let isTyping = text != nil && !text!.isEmpty
            conversationManager.sendUserTypingStatus(isTyping: isTyping, with: text)
        } else {
            if let text = text, !text.isEmpty {
                autosuggestThrottler.throttle { [weak self] in
                    self?.fetchSuggestions(for: text)
                }
                store.dispatch(DidUpdateChatInputText(text: text))
            } else {
                autosuggestThrottler.cancel()
                store.dispatch(DidUpdateChatInputText(text: ""))
            }
        }
    }
    
    func fetchSuggestions(for text: String) {
        pendingAutosuggestRequestQueries.append(text)
        let difference = pendingAutosuggestRequestQueries.count - maxPendingAutosuggestRequests
        if difference > 0 {
            pendingAutosuggestRequestQueries.removeFirst(difference)
        }
        
        conversationManager.getSuggestions(for: text) { [weak self] (suggestions, responseId, error) in
            guard error == nil else {
                DebugLog.d(caller: self, error ?? "")
                return
            }
            
            self?.didFetchSuggestions(suggestions, responseId, query: text)
        }
    }
    
    func chatInputView(_ chatInputView: ChatInputView, willChangeTextWithKeystrokes keystrokes: Int) {
        if let selected = selectedSuggestionMetadata, !selected.suggestion.isEmpty {
            keystrokesAfterSelection += keystrokes
        } else {
            keystrokesBeforeSelection += keystrokes
        }
    }
    
    func chatInputView(_ chatInputView: ChatInputView, didTapSendMessage message: String) {
        if conversationManager.isConnected(retryConnectionIfNeeded: true) {
            quickRepliesView.disableAndClear()
            selectedSuggestionMetadata?.keystrokesBeforeSelection = keystrokesBeforeSelection
            selectedSuggestionMetadata?.keystrokesAfterSelection = keystrokesAfterSelection
            chatInputView.clear()
            sendMessage(with: message, autosuggestMetadata: selectedSuggestionMetadata)
            keystrokesBeforeSelection = 0
            keystrokesAfterSelection = 0
            selectedSuggestionMetadata = nil
            partialAutosuggestMetadataByResponseId = [:]
        }
    }
    
    func chatInputView(_ chatInputView: ChatInputView, didTapMediaButton mediaButton: UIButton) {
        presentImageUploadOptions(fromView: mediaButton)
    }
    
    func chatInputViewDidChangeContentSize(_ chatInputView: ChatInputView) {
        updateFramesAnimated()
    }
    
    func chatInputViewDidBeginEditing(_ chatInputView: ChatInputView) {
        Dispatcher.performOnMainThread { [weak self] in
            self?.store.dispatch(DidBeginEditing())
        }
    }
    
    func chatInputViewDidEndEditing(_ chatInputView: ChatInputView) {
        didHideKeyboard()
    }
}

// MARK: - Showing/Hiding QuickRepliesView

extension ChatViewController {
    // MARK: Showing
    
    func showQuickRepliesView(with message: ChatMessage, animated: Bool) {
        guard message.quickReplies != nil,
              message != quickRepliesMessage else {
            return
        }
        
        quickRepliesMessage = message
        quickRepliesView.show(message: message, animated: animated)
        conversationManager.currentSRSClassification = quickRepliesView.currentSRSClassification
    }
    
    // MARK: Hiding
    
    func clearQuickRepliesView(animated: Bool) {
        quickRepliesMessage = nil
        
        quickRepliesView.clear(animated: animated)
    }
}

// MARK: - QuickRepliesViewDelegate

extension ChatViewController: QuickRepliesViewDelegate {
    func recordEventWithLastReply(_ name: AnalyticsEvent.Name, buttonTitle: String?) {
        var attributes: AnalyticsEvent.Attributes = [:]
        
        if let buttonTitle = buttonTitle {
            attributes["buttonText"] = AnyEncodable(buttonTitle)
        }
        
        if let messageMetadata = chatMessagesView.lastReply?.messageMetadata {
            attributes["messageMetadata"] = AnyEncodable(messageMetadata.mapValues { AnyEncodable($0.value) })
        }
        
        recordEvent(AnalyticsEvent(
            name: name,
            attributes: attributes,
            metadata: nil
        ))
    }
    
    func recordEvent(_ event: AnalyticsEvent) {
        conversationManager.getRequestParameters { params in
            AnalyticsClient.shared.record(event: event, params: params)
        }
    }
    
    func quickRepliesViewDidTapRestart(_ quickRepliesView: QuickRepliesView) {
        guard store.state.queryUI.shouldConfirmRestart else {
            scrollToBottomBeforeAddingNextMessage()
            store.dispatch(WillRestart())
            
            recordEventWithLastReply(.newQuestionButtonTapped, buttonTitle: quickRepliesView.restartButton.title)
            
            conversationManager.sendAskRequest { success in
                guard !success else { return }
                Dispatcher.performOnMainThread { [weak self] in
                    self?.reconnect()
                    self?.store.dispatch(DidFailToRestart())
                }
            }
            return
        }
        
        let restartSheet = RestartConfirmationActionSheet()
        restartSheet.delegate = self
        actionSheet = restartSheet
        guard let actionSheet = actionSheet else {
            return
        }
        
        recordEventWithLastReply(.newQuestionWithConfirmationButtonTapped, buttonTitle: quickRepliesView.restartButton.title)
        
        self.actionSheet = actionSheet
        store.dispatch(ActionSheetChange(isVisible: true))
        actionSheet.show(in: view, below: connectionStatusView)
    }
    
    func quickRepliesView(_ quickRepliesView: QuickRepliesView, didSelect quickReply: QuickReply, from message: ChatMessage) -> Bool {
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, ASAPPLocalizedString("Sent. Waiting for reply."))
        store.dispatch(DidSelectQuickReply())
        
        let attributes = [
            "quickReplyText": AnyEncodable(quickReply.title),
            "messageMetadata": AnyEncodable(message.messageMetadata?.mapValues { AnyEncodable($0.value) })
        ]
        recordEvent(AnalyticsEvent(
            name: .quickReplySelected,
            attributes: attributes,
            metadata: quickReply.action.metadata))
        
        return performAction(quickReply.action, fromMessage: message, quickReply: quickReply)
    }
}

extension ChatViewController: ActionSheetDelegate {
    private func hideActionSheet(_ actionSheet: BaseActionSheet, completion: (() -> Void)? = nil) {
        shouldHideActionSheetOnNextMessage = false
        actionSheet.hide { [weak self] in
            self?.actionSheet = nil
            self?.store.dispatch(ActionSheetChange(isVisible: false))
            completion?()
        }
    }
    
    func actionSheetDidTapHide(_ actionSheet: BaseActionSheet) {
        reconnect()
        
        let eventName: AnalyticsEvent.Name = (actionSheet is WelcomeBackActionSheet) ? .continueSheetHideButtonTapped : .restartSheetHideButtonTapped
        recordEventWithLastReply(eventName, buttonTitle: actionSheet.hideButton.titleLabel?.text)
        
        hideActionSheet(actionSheet) { [weak self] in
            if self?.conversationManager.events.isEmpty == false {
                self?.updateStateForLastEvent()
            } else {
                self?.updateFrames()
            }
        }
    }
    
    func actionSheetDidTapConfirm(_ actionSheet: BaseActionSheet) {
        shouldHideActionSheetOnNextMessage = true
        actionSheet.showSpinner()
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, ASAPPLocalizedString("Loading."))
        
        let eventName: AnalyticsEvent.Name = (actionSheet is WelcomeBackActionSheet) ? .continueSheetConfirmButtonTapped : .restartSheetConfirmButtonTapped
        recordEventWithLastReply(eventName, buttonTitle: actionSheet.confirmButton.titleLabel?.text)
        
        conversationManager.sendAskRequest { success in
            Dispatcher.performOnMainThread { [weak self] in
                self?.store.dispatch(WillRestart())
            }
            
            guard !success else { return }
            Dispatcher.performOnMainThread { [weak self] in
                self?.reconnect()
                actionSheet.hideSpinner()
                self?.store.dispatch(DidFailToRestart())
            }
        }
    }
    
    func actionSheetWillShow(_ actionSheet: BaseActionSheet) {
        chatInputView?.alpha = 0
    }
}

extension ChatViewController: ProactiveMessageConfirmationActionSheetDelegate {
    func actionSheetDidTapConfirmWithButton(_ actionSheet: ProactiveMessageConfirmationActionSheet, button: QuickReply) {
        shouldHideActionSheetOnNextMessage = true
        actionSheet.showSpinner()
        hideNotificationBanner(animated: false)
        performAction(button.action, quickReply: button)
        conversationManager.sendAcceptRequest(action: button.action)
    }
}

extension ChatViewController: NotificationBannerDelegate {
    func notificationBannerDidTapActionButton(_ notificationBanner: NotificationBanner, button: QuickReply) {
        guard button.action.type == .treewalk else {
            performAction(button.action, quickReply: button)
            return
        }
        
        let confirmationSheet = ProactiveMessageConfirmationActionSheet(button: button)
        confirmationSheet.delegate = self
        confirmationSheet.proactiveMessageDelegate = self
        actionSheet = confirmationSheet
        guard let actionSheet = actionSheet else {
            return
        }
        
        self.actionSheet = actionSheet
        store.dispatch(ActionSheetChange(isVisible: true))
        actionSheet.show(in: view, below: connectionStatusView)
    }
    
    func notificationBannerDidTapCollapse(_ notificationBanner: NotificationBanner) {
        notificationBanner.layoutIfNeeded()
        updateFramesAnimated()
    }
    
    func notificationBannerDidTapExpand(_ notificationBanner: NotificationBanner) {
        notificationBanner.layoutIfNeeded()
        updateFramesAnimated()
    }
    
    func notificationBannerDidTapDismiss(_ notificationBanner: NotificationBanner, button: QuickReply) {
        hideNotificationBanner()
        conversationManager.sendDismissRequest(action: button.action)
    }
    
    func showNotificationBanner(_ notification: ChatNotification, animated: Bool = false, completion: (() -> Void)? = nil) {
        let banner = NotificationBanner(notification: notification)
        banner.delegate = self
        notificationBanner?.removeFromSuperview()
        notificationBanner = banner
        if let actionSheet = actionSheet {
            view.insertSubview(banner, belowSubview: actionSheet)
        } else {
            view.insertSubview(banner, belowSubview: connectionStatusView)
        }
        banner.shouldHide = true
        updateFrames()
        updateShadows()
        banner.shouldHide = false
        
        if notification.showExpanded {
            banner.expand()
            banner.layoutIfNeeded()
        }
        
        updateFramesAnimated(animated) {
            completion?()
        }
    }
    
    func hideNotificationBanner(animated: Bool = true, completion: (() -> Void)? = nil) {
        notificationBanner?.shouldHide = true
        
        updateFramesAnimated(animated, scrollToBottomIfNearBottom: true) { [weak self] in
            self?.notificationBanner?.removeFromSuperview()
            self?.notificationBanner = nil
            self?.updateShadows()
            completion?()
        }
    }
}

// MARK: - ConversationManagerDelegate

extension ChatViewController: ConversationManagerDelegate {
    private func handle(message: ChatMessage, shouldAdd: Bool = true) {
        provideHapticFeedbackForMessageIfNecessary(message)
        
        if message.metadata.isReply {
            chatMessagesView.updateTypingStatus(false, immediately: false)
        }
        
        if message.metadata.eventType == .newRep {
            ASAPP.soundEffectPlayer.playSound(.liveChatNotification)
        }
        
        func completion() {
            if shouldAdd {
                func add() {
                    chatMessagesView.addMessage(message) { [weak self] in
                        self?.messageCompletionHandler(message)
                    }
                }
                
                if message.metadata.isAutomatedMessage {
                    Dispatcher.delay(.defaultAnimationDuration * 2) {
                        add()
                    }
                } else {
                    add()
                }
            } else {
                messageCompletionHandler(message)
            }
        }
        
        func scrollIfNeededBeforeCompleting() {
            if let remaining = scrollingCompletionTime?.timeIntervalSinceNow,
                remaining > 0 {
                let delay = max(remaining, DispatchTimeInterval.defaultAnimationDuration.seconds)
                scrollingCompletionTime = Date().addingTimeInterval(delay + DispatchTimeInterval.defaultAnimationDuration.seconds * 3)
                Dispatcher.delay(.seconds(delay), closure: completion)
            } else {
                completion()
                scrollingCompletionTime = nil
            }
        }
        
        if let actionSheet = actionSheet, shouldHideActionSheetOnNextMessage {
            clearQuickRepliesView(animated: false)
            scrollToBottomBeforeAddingNextMessage()
            hideActionSheet(actionSheet, completion: scrollIfNeededBeforeCompleting)
        } else {
            scrollIfNeededBeforeCompleting()
        }
    }
    
    // New Messages
    func conversationManager(_ manager: ConversationManagerProtocol, didReceive message: ChatMessage) {
        handle(message: message)
    }
    
    private func showNotificationBannerIfNecessary(_ notification: ChatNotification?) {
        guard let notification = notification else {
            updateFrames()
            return
        }
        
        showNotificationBanner(notification)
    }
    
    private func didHideKeyboard() {
        store.dispatch(KeyboardDidDisappear())
    }
    
    private func updateStateForLastEvent() {
        if let message = conversationManager.events
            .reversed()
            .prefix(while: { $0.eventType != .accountMerge })
            .first(where: { $0.isReplyMessageEvent })?
            .chatMessage {
            updateState(for: message)
        } else {
            store.dispatch(NoReplies())
        }
    }
    
    private func updateState(for message: ChatMessage, animated: Bool = false) {
        store.dispatch(MessageReceived(
            message: message,
            animated: animated))
    }
    
    private func messageCompletionHandler(_ message: ChatMessage) {
        updateState(for: message, animated: true)
    }
    
    // Welcome Back Action Sheet
    func conversationManager(_ manager: ConversationManagerProtocol, didReturnAfterInactivityWith event: Event) {
        guard let continuePrompt = event.continuePrompt else {
            return
        }
        
        let continueSheet = WelcomeBackActionSheet(for: continuePrompt)
        continueSheet.delegate = self
        actionSheet = continueSheet
        guard let actionSheet = actionSheet else {
            return
        }
        
        chatInputView?.resignFirstResponder()
        chatInputView?.alpha = 0
        
        self.actionSheet = actionSheet
        store.dispatch(ActionSheetChange(isVisible: true))
        actionSheet.show(in: view, below: connectionStatusView)
    }
    
    func conversationManager(_ manager: ConversationManagerProtocol, didReceiveEventOutOfOrder event: Event) {
        fetchLater()
    }
    
    // Updated Messages
    func conversationManager(_ manager: ConversationManagerProtocol, didUpdate message: ChatMessage) {
        chatMessagesView.updateMessage(message)
    }
    
    // Typing Status
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeTypingStatus isTyping: Bool) {
        chatMessagesView.updateTypingStatus(isTyping, shouldScrollToBottom: manager.isLiveChat)
    }
    
    func conversationManager(_ manager: ConversationManagerProtocol, didReceiveNotificationWith event: Event) {
        guard let notification = event.notification else {
            return
        }
        
        showNotificationBannerIfNecessary(notification)
    }
    
    // Live Chat Status
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeLiveChatStatus isLiveChat: Bool, with event: Event) {
        store.dispatch(DidChangeLiveChatStatus(isLiveChat: isLiveChat, updateInput: true))
    }
    
    func showGatekeeperViewIfNecessary(_ type: GatekeeperView.ContentType) {
        guard connectionStatus != .connected else {
            return
        }
        
        gatekeeperView = GatekeeperView(contentType: type)
        if let gatekeeper = gatekeeperView {
            gatekeeper.delegate = self
            gatekeeper.frame = view.bounds
            view.insertSubview(gatekeeper, aboveSubview: connectionStatusView)
            view.accessibilityElements = [gatekeeper]
            UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, gatekeeper)
            spinner.alpha = 0
            store.dispatch(GatekeeperViewDidAppear())
            shouldReloadOnUserUpdate = true
        }
    }
    
    func hideGatekeeperView() {
        guard gatekeeperView != nil else {
            return
        }
        
        gatekeeperView?.removeFromSuperview()
        gatekeeperView = nil
        view.accessibilityElements = nil
        UIAccessibilityPostNotification(UIAccessibilityScreenChangedNotification, view)
    }
    
    // Connection Status
    func conversationManager(_ manager: ConversationManagerProtocol, didChangeConnectionStatus isConnected: Bool, authError: SocketConnection.AuthError?) {
        if let authError = authError,
           isAppInForeground {
            connectionStatus = .disconnected
            hideGatekeeperView()
            // delay in case we reconnect immediately
            Dispatcher.delay { [weak self] in
                switch authError {
                case .invalidAuth:
                    self?.showGatekeeperViewIfNecessary(.unauthenticated)
                case .tokenExpired:
                    self?.showGatekeeperViewIfNecessary(.connectionTrouble)
                }
            }
            return
        }
        
        if !didConnectAtLeastOnce && isConnected {
            conversationManager.sendEnterChatRequest()
        }
        
        if isConnected {
            shouldReloadOnUserUpdate = false
            didConnectAtLeastOnce = true
            delayedDisconnectTime = nil
        } else if delayedDisconnectTime == nil {
            delayedDisconnectTime = Date(timeIntervalSinceNow: disconnectedTimeThreshold)
            Dispatcher.delay(.seconds(disconnectedTimeThreshold) + .defaultAnimationDuration) { [weak self] in
                self?.updateFramesAnimated(true, scrollToBottomIfNearBottom: false)
            }
        }
        
        connectionStatus = isConnected ? .connected : .disconnected
        updateShadows()
        updateFramesAnimated(scrollToBottomIfNearBottom: false)
        
        if isConnected {
            hideGatekeeperView()
            
            if chatMessagesView.isEmpty {
                reloadMessageEvents()
            } else {
                fetchLater()
            }
        } else {
            if chatMessagesView.isEmpty {
                chatMessagesView.reloadWithEvents(conversationManager.events)
                spinner.alpha = 0
            }
            
            if !didConnectAtLeastOnce {
                hideGatekeeperView()
                showGatekeeperViewIfNecessary(.notConnected)
            }
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
}

// MARK: - GatekeeperViewDelegate

extension ChatViewController: GatekeeperViewDelegate {
    func gatekeeperViewDidTapLogIn(_ gatekeeperView: GatekeeperView) {
        shouldReloadOnUserUpdate = true
        didConnectAtLeastOnce = false
        ASAPP.delegate?.chatViewControllerDidTapUserLoginButton()
    }
    
    func gatekeeperViewDidTapReconnect(_ gatekeeperView: GatekeeperView) {
        reconnect()
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
    
    func sendMessage(with text: String, fromPrediction: Bool = false, autosuggestMetadata: AutosuggestMetadata? = nil) {
        if conversationManager.isConnected {
            scrollToBottomBeforeAddingNextMessage()
        }
        
        if store.state.queryUI.input.isLiveChat {
            store.dispatch(DidSendMessage())
            conversationManager.sendTextMessage(text)
        } else {
            store.dispatch(DidSelectQuickReply())
            conversationManager.sendSRSQuery(text, isRequestFromPrediction: fromPrediction, autosuggestMetadata: autosuggestMetadata)
        }
        
        PushNotificationsManager.shared.requestAuthorizationIfNeeded(after: .seconds(3))
    }
    
    func didFetchSuggestions(_ suggestions: [String], _ responseId: AutosuggestMetadata.ResponseId, query: String) {
        if let index = pendingAutosuggestRequestQueries.index(of: query) {
            pendingAutosuggestRequestQueries.removeFirst(index + 1)
        } else {
            return
        }
        
        store.dispatch(FetchedSuggestions(suggestions: suggestions, responseId: responseId))
        
        guard
            !suggestions.isEmpty,
            chatInputView?.textView.text.isEmpty == false,
            store.state.queryUI.autosuggest.shouldShow
        else {
            return
        }
        
        var partialMetadata = AutosuggestMetadata()
        partialMetadata.responseId = responseId
        partialMetadata.original = query
        partialMetadata.returnedCount = suggestions.count
        partialAutosuggestMetadataByResponseId[responseId] = partialMetadata
    }
    
    func reloadMessageEvents() {
        let numberToFetch = chatMessagesView.pageSize

        conversationManager.getSettings()
        chatMessagesView.isHidden = true

        conversationManager.getEvents(limit: numberToFetch) { [weak self] (fetchedEvents, _) in
            guard let strongSelf = self, let fetchedEvents = fetchedEvents else {
                return
            }
            
            strongSelf.shouldFetchEarlier = fetchedEvents.count == numberToFetch
            strongSelf.clearQuickRepliesView(animated: false)
            
            Dispatcher.delay { [weak self] in
                guard let strongSelf = self else {
                    return
                }
                
                strongSelf.chatMessagesView.shouldShowLoadingHeader = strongSelf.shouldFetchEarlier
                strongSelf.chatMessagesView.reloadWithEvents(fetchedEvents)
                strongSelf.updateStateForLastEvent()
                
                if strongSelf.conversationManager.isLiveChat && !strongSelf.store.state.isLiveChat {
                    strongSelf.store.dispatch(DidChangeLiveChatStatus(isLiveChat: true, updateInput: true))
                }
                
                Dispatcher.delay { [weak self] in
                    self?.spinner.alpha = self?.chatMessagesView.isEmpty == true ? 1 : 0
                    self?.chatMessagesView.isHidden = false
                }
                
                if let nextAction = strongSelf.nextAction {
                    strongSelf.performAction(nextAction, queueRequestIfNoConnection: true)
                    strongSelf.nextAction = nil
                }
            }
        }
    }
}
