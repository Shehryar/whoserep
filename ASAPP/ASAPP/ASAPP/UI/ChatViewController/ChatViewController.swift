//
//  ChatViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import SafariServices

class ChatViewController: UIViewController {
    
    // MARK: Properties: Public
    
    let credentials: Credentials
    
    let callback: ASAPPCallbackHandler
    
    // MARK: Properties: Views / UI
    
    fileprivate let predictiveVC = PredictiveViewController()
    fileprivate let predictiveNavController: UINavigationController!
    
    fileprivate let chatMessagesView: ChatMessagesView
    fileprivate let chatInputView = ChatInputView()
    fileprivate let connectionStatusView = ChatConnectionStatusView()
    fileprivate let suggestedRepliesView = ChatSuggestedRepliesView()
    fileprivate var askTooltipPresenter: TooltipPresenter?
    fileprivate var hapticFeedbackGenerator: Any?
    
    // MARK: Properties: Storage
    
    fileprivate let simpleStore: ChatSimpleStore
    fileprivate let conversationManager: ConversationManager
    fileprivate var actionableMessage: SRSResponse?
    
    // MARK: Properties: Status
    
    fileprivate var isLiveChat = false {
        didSet {
            if isLiveChat != oldValue {
                DebugLog("Chat Mode Changed: \(isLiveChat ? "LIVE CHAT" : "SRS")")
                if isLiveChat {
                    conversationManager.currentSRSClassification = nil
                } else {
                    conversationManager.currentSRSClassification = suggestedRepliesView.currentSRSClassification
                }
                
                updateViewForLiveChat()
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
    
    
    
    fileprivate var connectedAtLeastOnce = false
    fileprivate var showPredictiveOnViewAppear = true
    fileprivate var isInitialLayout = true
    fileprivate var didPresentPredictiveView = false
    fileprivate var predictiveVCVisible = false
    fileprivate var delayedDisconnectTime: Date?
    
    
    // MARK: Properties: Keyboard
    
    fileprivate var keyboardObserver = KeyboardObserver()
    fileprivate var keyboardOffset: CGFloat = 0
    fileprivate var keyboardRenderedHeight: CGFloat = 0

    // MARK:- Initialization
    
    init(withCredentials credentials: Credentials, callback: @escaping ASAPPCallbackHandler) {
        self.credentials = credentials
        self.callback = callback
        self.simpleStore = ChatSimpleStore(credentials: credentials)
        self.conversationManager = ConversationManager(withCredentials: credentials)
        self.chatMessagesView = ChatMessagesView(withCredentials: self.credentials)
        self.predictiveNavController = UINavigationController(rootViewController: predictiveVC)
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false
        
        conversationManager.delegate = self
        
    
        // Predictive View Controller
        
        predictiveVC.delegate = self
        predictiveNavController.view.alpha = 0.0
        
        // Buttons
        
        let closeButton = UIBarButtonItem.circleCloseBarButtonItem(foregroundColor: ASAPP.styles.navBarButtonForegroundColor,
                                                                   backgroundColor: ASAPP.styles.navBarButtonBackgroundColor,
                                                                   target: self,
                                                                   action: #selector(ChatViewController.didTapCloseButton))
        closeButton.accessibilityLabel = ASAPP.strings.accessibilityClose
        navigationItem.rightBarButtonItem = closeButton
        
        // Subviews
        
        chatMessagesView.delegate = self
        chatMessagesView.replaceMessageEventsWithEvents(conversationManager.storedMessages)
        
        if let mostRecentEvent = chatMessagesView.mostRecentEvent {
            let secondsSinceLastEvent = Date().timeIntervalSince(mostRecentEvent.eventDate)
            
            showPredictiveOnViewAppear = secondsSinceLastEvent > (15 * 60)
            if secondsSinceLastEvent < (60 * 15) {
                showPredictiveOnViewAppear = false
            }
        } else {
            showPredictiveOnViewAppear = true
        }
        
        chatInputView.delegate = self
        chatInputView.displayMediaButton = true
        chatInputView.layer.shadowColor = UIColor.black.cgColor
        chatInputView.layer.shadowOffset = CGSize(width: 0, height: 0)
        chatInputView.layer.shadowRadius = 2
        chatInputView.layer.shadowOpacity = 0.1
        
        suggestedRepliesView.delegate = self
        
        connectionStatusView.onTapToConnect = { [weak self] in
            self?.reconnect()
        }
        


        // Keyboard
        
        keyboardObserver.delegate = self
        
        // Haptic Feedback
        
        if #available(iOS 10.0, *) {
            //                let generator = UINotificationFeedbackGenerator()
            //                generator.prepare()
            //                generator.notificationOccurred(.success)
            
            hapticFeedbackGenerator = UIImpactFeedbackGenerator(style: .medium)
            if let hapticFeedbackGenerator = hapticFeedbackGenerator as? UIImpactFeedbackGenerator {
                hapticFeedbackGenerator.prepare()
            }
        }
        
        // Fonts (+ Accessibility Font Sizes Support)
        
        updateFonts()
        
        NotificationCenter.default.addObserver(self, selector: #selector(ChatViewController.updateFonts),
                                               name: Notification.Name.UIContentSizeCategoryDidChange,
                                               object: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        predictiveVC.delegate = nil
        keyboardObserver.delegate = nil
        chatMessagesView.delegate = nil
        chatInputView.delegate = nil
        conversationManager.delegate = nil
        suggestedRepliesView.delegate = nil
        
        conversationManager.exitConversation()
        
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Nav Bar
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.isTranslucent = true
            navigationBar.shadowImage = nil
            navigationBar.setBackgroundImage(nil, for: .default)
            navigationBar.setBackgroundImage(nil, for: .compact)
            navigationBar.backgroundColor = nil
            if ASAPP.styles.navBarBackgroundColor.isDark() {
                navigationBar.barStyle = .black
                if ASAPP.styles.navBarBackgroundColor != UIColor.black {
                    navigationBar.barTintColor = ASAPP.styles.navBarBackgroundColor
                }
            } else {
                navigationBar.barStyle = .default
                if ASAPP.styles.navBarBackgroundColor != UIColor.white {
                    navigationBar.barTintColor = ASAPP.styles.navBarBackgroundColor
                }
            }
            navigationBar.tintColor = ASAPP.styles.navBarButtonColor
            setNeedsStatusBarAppearanceUpdate()
        }
        
        // View
        
        view.clipsToBounds = true
        view.backgroundColor = ASAPP.styles.backgroundColor1
        updateViewForLiveChat(animated: false)
        
        view.addSubview(chatMessagesView)
        view.addSubview(chatInputView)
        view.addSubview(suggestedRepliesView)
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
        
        updateIsLiveChat(withEvents: conversationManager.storedMessages)
        
        
        let minTimeBetweenSessions: TimeInterval = 60 * 15 // 15 minutes
        if chatMessagesView.mostRecentEvent == nil ||
            chatMessagesView.mostRecentEvent!.eventDate.timeSinceIsGreaterThan(numberOfSeconds: minTimeBetweenSessions) {
            conversationManager.trackSessionStart()
        }
        
        // Inferred button
        conversationManager.trackButtonTap(buttonName: .openChat)
        
        
        if showPredictiveOnViewAppear || chatMessagesView.isEmpty {
            showPredictiveOnViewAppear = false
            setPredictiveViewControllerVisible(true, animated: false, completion: nil)
        } else if !isLiveChat {
            showSuggestedRepliesViewIfNecessary(animated: false)
        }
        
        
        // Load Events
        if conversationManager.isConnected {
            reloadMessageEvents()
        } else {
            connectionStatus = .connecting
            delayedDisconnectTime = Date(timeIntervalSinceNow: 2) // 2 seconds from now
            conversationManager.enterConversation()
            Dispatcher.delay(2300, closure: { [weak self] in
                self?.updateFramesAnimated()
            })
            
            conversationManager.startSRS(completion: { [weak self] (appOpenResponse) in
                self?.predictiveVC.setAppOpenResponse(appOpenResponse: appOpenResponse, animated: true)
            })
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.registerForNotifications()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        Dispatcher.delay(500, closure: { [weak self] in
            self?.showAskButtonTooltipIfNecessary()
        })
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.deregisterForNotification()
        
        view.endEditing(true)
        
        conversationManager.saveCurrentEvents()
    }
    
    // MARK: Display Update
    
    func updateFonts() {
        updateAskButton()
        
        chatMessagesView.updateDisplay()
        suggestedRepliesView.updateDisplay()
        connectionStatusView.updateDisplay()
        chatInputView.updateDisplay()
        
        if isViewLoaded {
            view.setNeedsLayout()
        }
    }
    
    func updateAskButton() {
        if isLiveChat {
            navigationItem.leftBarButtonItem = nil
            return
        }
        
        let askButton = UIBarButtonItem.chatBubbleBarButtonItem(title: ASAPP.strings.chatAskNavBarButton,
                                                                font: ASAPP.styles.font(for: .navBarButton),
                                                                textColor: ASAPP.styles.navBarButtonForegroundColor,
                                                                backgroundColor: ASAPP.styles.navBarButtonBackgroundColor,
                                                                style: .ask,
                                                                target: self,
                                                                action: #selector(ChatViewController.didTapAskButton))
        navigationItem.leftBarButtonItem = askButton
    }
    
    // MARK: Status Bar Style
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if showPredictiveOnViewAppear || predictiveVCVisible {
            return .lightContent
        } else {
            if ASAPP.styles.navBarBackgroundColor.isDark() {
                return .lightContent
            } else {
                return .default
            }
        }
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .fade
    }
    
    func updateStatusBar(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                self?.setNeedsStatusBarAppearanceUpdate()
            })
        } else {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: Supported Orientations
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: Connection
    
    func reconnect() {
        if connectionStatus == .disconnected {
            connectionStatus = .connecting
            conversationManager.enterConversation()
            conversationManager.startSRS()
        }
    }
    
    // MARK: Updates
    
    func updateIsLiveChat(withEvents events: [Event]) {
        var tempLiveChat = false
        for (_, event) in events.enumerated().reversed() {
            if event.eventType == .newRep || event.eventType == .switchSRSToChat {
                tempLiveChat = true
                break
            }
            if event.eventType == .conversationEnd {
                tempLiveChat = false
                break
            }
        }
        
        DebugLog("Updated isLiveChat = \(tempLiveChat ? "TRUE" : "FALSE")")
        
        isLiveChat = tempLiveChat
    }
    
    func updateViewForLiveChat(animated: Bool = true) {
        updateAskButton()
        
        if isLiveChat {
            clearSuggestedRepliesView(true, completion: nil)
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
        }
    }
    
    // MARK: Button Actions
    
    func didTapAskButton() {
        increaseTooltipActionsCount(increaseAmount: 2)
        
        showPredictiveView()
        
        conversationManager.trackButtonTap(buttonName: .showPredictiveFromChat)
    }
    
    func didTapCloseButton() {
        conversationManager.trackButtonTap(buttonName: .closeChatFromChat)
        
        dismissChatViewController()
    }
}

// MARK:- Tooltip

extension ChatViewController {
    
    func hasShownAskTooltipKey() -> String {
        return credentials.hashKey(withPrefix: "AskTooltipShown")
    }
    
    func numberOfTooltipActions() -> Int {
        return UserDefaults.standard.integer(forKey: hasShownAskTooltipKey())
    }
    
    private static let MAX_TOOLTIP_ACTIONS_COUNT = 3
    
    func increaseTooltipActionsCount(increaseAmount: Int = 1) {
        let numberOfTimesShown = numberOfTooltipActions() + increaseAmount
        UserDefaults.standard.set(numberOfTimesShown, forKey: hasShownAskTooltipKey())
    }
    
    func showAskButtonTooltipIfNecessary() {
        guard !showPredictiveOnViewAppear && !predictiveVCVisible && !isLiveChat
            && numberOfTooltipActions() < ChatViewController.MAX_TOOLTIP_ACTIONS_COUNT else {
                return
        }
        
        if askTooltipPresenter != nil {
            return
        }
        
        guard let navView = navigationController?.view,
            let buttonItem = navigationItem.leftBarButtonItem else {
                return
        }
        
        increaseTooltipActionsCount()
        
        askTooltipPresenter = TooltipView.showTooltip(withText: ASAPP.strings.chatAskTooltip,
                                                      targetBarButtonItem: buttonItem,
                                                      parentView: navView,
                                                      onDismiss: { [weak self] in
                                                        self?.askTooltipPresenter = nil
        })
    }
}

// MARK:- Layout

extension ChatViewController {
    
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
        
        let repliesHeight: CGFloat = suggestedRepliesView.preferredDisplayHeight()
        var repliesTop = view.bounds.height
        if actionableMessage != nil && !isLiveChat {
            repliesTop -= repliesHeight
        }
        suggestedRepliesView.frame = CGRect(x: 0.0, y: repliesTop, width: viewWidth, height: repliesHeight)
        
        let messagesHeight = min(chatInputView.frame.minY,
                                 suggestedRepliesView.frame.minY + suggestedRepliesView.transparentInsetTop)
        chatMessagesView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: messagesHeight)
        chatMessagesView.layoutSubviews()
        chatMessagesView.contentInsetTop = minVisibleY
        
        
        if actionableMessage != nil {
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
                }, completion: { (completed) in
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

// MARK:- SRS Actions

extension ChatViewController {
    
    func handleSRSButtonItemSelection(_ buttonItem: SRSButtonItem, fromEvent event: Event) -> Bool {
        if _handleDemoButtonItemTapped(buttonItem) {
            return true
        }
        
        func sendButtonTap() -> Bool {
            guard conversationManager.isConnected(retryConnectionIfNeeded: true) else {
                return false
            }
            
            
            let originalQuery = simpleStore.getSRSOriginalSearchQuery()
            conversationManager.sendButtonItemSelection(buttonItem,
                                                        originalSearchQuery: originalQuery,
                                                        currentSRSEvent: suggestedRepliesView.currentActionableEvent)
            
            return true
        }
        
        conversationManager.trackSRSButtonItemTap(buttonItem: buttonItem)
        
        
        // Check if this is a web url
        if let webURL = buttonItem.webURL {
            if openWebURL(url: webURL) {
                DebugLog("Did select button with web url: \(webURL)")
                
                if conversationManager.isConnected(retryConnectionIfNeeded: true) {
                    conversationManager.sendButtonItemSelection(
                        buttonItem,
                        originalSearchQuery: simpleStore.getSRSOriginalSearchQuery(),
                        currentSRSEvent: suggestedRepliesView.currentActionableEvent)
                }
                return false
            }
        }
        
        switch buttonItem.type {
        case .InAppLink, .Link:
            if let deepLink = buttonItem.deepLink {
                DebugLog("\nDid select action: \(deepLink) w/ userInfo: \(buttonItem.deepLinkData)")
                
                let originalQuery = simpleStore.getSRSOriginalSearchQuery()
                conversationManager.sendButtonItemSelection(buttonItem,
                                                            originalSearchQuery: originalQuery,
                                                            currentSRSEvent: suggestedRepliesView.currentActionableEvent)
                
                dismiss(animated: true, completion: { [weak self] in
                    self?.callback(deepLink, buttonItem.deepLinkData)
                })
                return false
            }
            break
            
        case .SRS, .Action, .Message:
            guard conversationManager.isConnected(retryConnectionIfNeeded: true) else {
                return false
            }
            
            simpleStore.updateSuggestedReplyEventLogSeqs(eventLogSeqs: suggestedRepliesView.actionableEventLogSeqs)
            chatMessagesView.scrollToBottomAnimated(true)
        
            conversationManager.sendButtonItemSelection(
                buttonItem,
                originalSearchQuery: simpleStore.getSRSOriginalSearchQuery(),
                currentSRSEvent: suggestedRepliesView.currentActionableEvent,
                completion: { [weak self] (message, request, responseTime) in
                    if message.type != .Response {
                        self?.suggestedRepliesView.deselectCurrentSelection(animated: true)
                    }
            })
            return true
            
        case .AppAction:
            return performAppAction(buttonItem.appAction, forEvent: event)
        }
        
        return false
    }
    
    func openWebURL(url: URL) -> Bool {
        
        // SFSafariViewController
        if #available(iOS 9.0, *) {
            if let urlScheme = url.scheme {
                if ["http", "https"].contains(urlScheme) {
                    let safariVC = SFSafariViewController(url: url)
                    present(safariVC, animated: true, completion: nil)
                    return true
                } else {
                    DebugLogError("Url is missing http/https url scheme: \(url)")
                }
            }
        }
        
        // Open in Safari
        if UIApplication.shared.canOpenURL(url) {
            UIApplication.shared.openURL(url)
            return true
        }
        return false
    }
    
    func performAppAction(_ action: AppAction?, forEvent event: Event) -> Bool {
        guard let action = action else {
            return false
        }
        
        switch action {
        case .Ask:
            setPredictiveViewControllerVisible(true, animated: true, completion: nil)
            return false
            
        case .BeginLiveChat:
            conversationManager.sendSRSSwitchToChat()
            return true
            
        case .AddCreditCard:
            let creditCardViewController = CreditCardInputViewController()
            creditCardViewController.delegate = self
            present(creditCardViewController, animated: true, completion: nil)
            return false
            
        case .LeaveFeedback:
            let leaveFeedbackViewController = LeaveFeedbackViewController()
            leaveFeedbackViewController.issueId = event.issueId
            present(leaveFeedbackViewController, animated: true, completion: nil)
            return false
        }
    }
    
    func _handleDemoButtonItemTapped(_ buttonItem: SRSButtonItem) -> Bool {
        guard ASAPP.isDemoContentEnabled() && conversationManager.isConnected() else {
             return false
        }
        
        if conversationManager.demo_OverrideButtonItemSelection(buttonItem: buttonItem) {
            return true
        }
        
        if let deepLink = buttonItem.deepLink?.lowercased() {
            switch deepLink {
            case "troubleshoot":
                chatMessagesView.scrollToBottomAnimated(true)
                conversationManager.sendFakeTroubleshooterMessage(buttonItem, afterEvent: chatMessagesView.mostRecentEvent)
                return true
                
            case "restartdevicenow":
                chatMessagesView.scrollToBottomAnimated(true)
                conversationManager.sendFakeDeviceRestartMessage(buttonItem, afterEvent: chatMessagesView.mostRecentEvent)
                return true
                
            default: break
            }
        }
    
        return false
    }
}

// MARK:- ChatMessagesViewDelegate

extension ChatViewController: ChatMessagesViewDelegate {
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didTapImageView imageView: UIImageView, forEvent event: Event) {
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
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didSelectButtonItem buttonItem: SRSButtonItem, fromEvent event: Event) {
        _ = handleSRSButtonItemSelection(buttonItem, fromEvent: event)
    }
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didTapMostRecentEvent event: Event) {
        if !isLiveChat {
            showSuggestedRepliesViewIfNecessary()
        }
    }
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didUpdateButtonItemsForEvent event: Event) {
        if event == chatMessagesView.mostRecentEvent {
            if let actionableMessage = event.srsResponse {
                suggestedRepliesView.reloadButtonItemsForActionableMessage(actionableMessage, event: event)
            }
        }
    }
    
    func chatMessagesViewPerformedKeyboardHidingAction(_ messagesView: ChatMessagesView) {
        view.endEditing(true)
    }
}

// MARK:- PredictiveViewController

extension ChatViewController: PredictiveViewControllerDelegate {
    
    func setPredictiveViewControllerVisible(_ visible: Bool, animated: Bool, completion: (() -> Void)?) {
        if predictiveVCVisible == visible {
            return
        }
        
        predictiveVCVisible = visible
        predictiveVC.view.endEditing(true)
        view.endEditing(true)
        
        if visible {
            clearSuggestedRepliesView(true)
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
                }, completion: { [weak self] (completed) in
                    self?.predictiveVC.presentingViewUpdatedVisibility(visible)
                    completion?()
                    
                    if !visible {
                        Dispatcher.delay(4000, closure: {
                            self?.showAskButtonTooltipIfNecessary()
                        })
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
        
        simpleStore.updateSRSOriginalSearchQuery(query: queryText)
        
        keyboardObserver.registerForNotifications()
        chatMessagesView.overrideToHideInfoView = true
        chatMessagesView.scrollToBottomAnimated(false)
        
        setPredictiveViewControllerVisible(false, animated: true) { [weak self] in
            Dispatcher.delay(250, closure: {
                self?.sendMessage(withText: queryText, fromPrediction: fromPrediction)
            })
        }
    }
    
    func predictiveViewControllerDidTapViewChat(_ viewController: PredictiveViewController) {
        setPredictiveViewControllerVisible(false, animated: true) { [weak self] in
            self?.showSuggestedRepliesViewIfNecessary()
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

// MARK:- Showing/Hiding ChatSuggestedRepliesView

extension ChatViewController {
    
    // MARK: Showing
    
    func showSuggestedRepliesViewIfNecessary(animated: Bool = true, completion: (() -> Void)? = nil) {
        if let actionableEvents = simpleStore.getSuggestedReplyEvents(fromEvents: chatMessagesView.allEvents) {
            showSuggestedRepliesViewIfNecessary(withEvents: actionableEvents, animated: animated, completion: completion)
        } else {
            showSuggestedRepliesViewIfNecessary(withEvent: chatMessagesView.mostRecentEvent, animated: animated)
        }
    }
    
    private func showSuggestedRepliesViewIfNecessary(withEvents events: [Event]?, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let events = events else { return }
        guard actionableMessage == nil else { return }
        
        for event in events {
            if event.eventType != .srsResponse || event.srsResponse?.buttonItems == nil {
                DebugLog("Passed non-srsResponse event to showSuggestedRepliesViewIfNecessary")
                return
            }
        }
        
        actionableMessage = events.last?.srsResponse
        suggestedRepliesView.reloadActionableMessagesWithEvents(events)
        conversationManager.currentSRSClassification = suggestedRepliesView.currentSRSClassification
        updateFramesAnimated(animated, scrollToBottomIfNearBottom: true, completion: completion)
        
        simpleStore.updateSuggestedReplyEventLogSeqs(eventLogSeqs: suggestedRepliesView.actionableEventLogSeqs)
    }
    
    private func showSuggestedRepliesViewIfNecessary(withEvent event: Event?, animated: Bool = true) {
        guard let event = event else {
            return
        }
        guard event.eventType == .srsResponse && actionableMessage == nil else {
            return
        }
        guard let srsResponse = event.srsResponse,
            let _ = srsResponse.buttonItems else {
                return
        }
        
        showSuggestedRepliesView(withSRSResponse: srsResponse, forEvent: event, animated: animated)
    }
    
    func showSuggestedRepliesView(withSRSResponse srsResponse: SRSResponse, forEvent event: Event, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard srsResponse.buttonItems != nil && !isLiveChat else { return }
        
        actionableMessage = srsResponse
        suggestedRepliesView.setActionableMessage(srsResponse, forEvent: event, animated: animated)
        conversationManager.currentSRSClassification = suggestedRepliesView.currentSRSClassification
        updateFramesAnimated(animated, scrollToBottomIfNearBottom: true, completion: completion)
        
        simpleStore.updateSuggestedReplyEventLogSeqs(eventLogSeqs: suggestedRepliesView.actionableEventLogSeqs)
    }
    
    // MARK: Hiding
    
    func clearSuggestedRepliesView(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        actionableMessage = nil
        
        updateFramesAnimated(animated, scrollToBottomIfNearBottom: true, completion: { [weak self] in
            self?.suggestedRepliesView.clear()
            completion?()
        })
    }
}

// MARK:- ChatSuggestedRepliesViewDelegate

extension ChatViewController: ChatSuggestedRepliesViewDelegate {
    
    // MARK: Delegate
    
    func chatSuggestedRepliesViewDidCancel(_ repliesView: ChatSuggestedRepliesView) {
        if isLiveChat {
            _ = chatInputView.becomeFirstResponder()
        }
        clearSuggestedRepliesView()
    }
    
    func chatSuggestedRepliesViewWillTapBack(_ repliesView: ChatSuggestedRepliesView) {
        conversationManager.trackButtonTap(buttonName: .srsBack)
    }
    
    func chatSuggestedRepliesViewDidTapBack(_ repliesView: ChatSuggestedRepliesView) {
        conversationManager.currentSRSClassification = suggestedRepliesView.currentSRSClassification
    }
    
    func chatSuggestedRepliesView(_ replies: ChatSuggestedRepliesView,
                                  didTapSRSButtonItem buttonItem: SRSButtonItem,
                                  fromEvent event: Event) -> Bool {
        return handleSRSButtonItemSelection(buttonItem, fromEvent: event)
    }
}

// MARK:- ConversationManagerDelegate

extension ChatViewController: ConversationManagerDelegate {
    func conversationManager(_ manager: ConversationManager, didReceiveMessageEvent messageEvent: Event) {
        provideHapticFeedbackForMessageIfNecessary(message: messageEvent)
        
        if messageEvent.eventType == .newRep && messageEvent.srsResponse != nil {
            ASAPP.soundEffectPlayer.playSound(.liveChatNotification)
        }
        
        chatMessagesView.insertNewMessageEvent(messageEvent) { [weak self] in
            if messageEvent.eventType == .srsResponse {
                self?.didReceiveSRSMessage(message: messageEvent)
            } else if !messageEvent.isCustomerEvent {
                self?.clearSuggestedRepliesView(true, completion: nil)
            }
        }
    }
    
    func conversationManager(_ manager: ConversationManager, didReceiveUpdatedMessageEvent messageEvent: Event) {
        chatMessagesView.refreshMessageEvent(event: messageEvent)
    }
    
    func conversationManager(_ manager: ConversationManager, didUpdateRemoteTypingStatus isTyping: Bool, withPreviewText previewText: String?, event: Event) {
        chatMessagesView.updateOtherParticipantTypingStatus(isTyping, withPreviewText: (credentials.isCustomer ? nil : previewText))
    }
    
    func conversationManager(_ manager: ConversationManager, connectionStatusDidChange isConnected: Bool) {
        
        if isConnected  {
            connectedAtLeastOnce = true
            delayedDisconnectTime = nil
        } else if delayedDisconnectTime == nil {
            delayedDisconnectTime = Date(timeIntervalSinceNow: 2) // 2 seconds from now
            Dispatcher.delay(2300, closure: { [weak self] in
                self?.updateFramesAnimated()
            })
        }
        
        connectionStatus = isConnected ? .connected : .disconnected
        updateFramesAnimated(scrollToBottomIfNearBottom: false)
        
        if isConnected {
            // Fetch events
            reloadMessageEvents()
        }
        
        DebugLog("ChatViewController: Connection -> \(isConnected ? "connected" : "not connected")")
    }
    
    func conversationManager(_ manager: ConversationManager, conversationStatusEventReceived event: Event, isLiveChat: Bool) {
        let wasLiveChat = self.isLiveChat
        self.isLiveChat = isLiveChat
        
        if !wasLiveChat && self.isLiveChat {
            conversationManager.trackLiveChatBegan(issueId: event.issueId)
        } else if wasLiveChat && !self.isLiveChat {
            conversationManager.trackLiveChatEnded(issueId: event.issueId)
        }
        
        conversationManager.saveCurrentEvents(async: true)
    }
    
    // MARK: Handling Received Messages
    
    func provideHapticFeedbackForMessageIfNecessary(message: Event) {
        switch message.eventType {
        case .srsResponse, .textMessage, .pictureMessage:
            if !message.wasSentByUserWithCredentials(credentials), #available(iOS 10.0, *) {
                if let generator = hapticFeedbackGenerator as? UIImpactFeedbackGenerator {
                    generator.impactOccurred()
                }
            }
            break
            
        default:
            // no-op
            break
        }
    }
    
    func didReceiveSRSMessage(message: Event) {
        guard let srsResponse = message.srsResponse else { return }
        
        // Immediate Action
        if let immediateAction = srsResponse.immediateAction {
            Dispatcher.delay(1200, closure: { [weak self] in
                _ = self?.handleSRSButtonItemSelection(immediateAction, fromEvent: message)
            })
        }
            // Show Suggested Replies View
        else if srsResponse.buttonItems != nil {
            // Already Visible
            if suggestedRepliesView.frame.minY < view.bounds.height {
                Dispatcher.delay(200, closure: { [weak self] in
                    self?.showSuggestedRepliesView(withSRSResponse: srsResponse, forEvent: message)
                })
            } else {
                // Not visible yet
                Dispatcher.delay(1000, closure: { [weak self] in
                    self?.showSuggestedRepliesView(withSRSResponse: srsResponse, forEvent: message)
                })
            }
        }
            // Hide Suggested Replies View
        else {
            clearSuggestedRepliesView()
        }
    }
}

// MARK:- Image Selection

extension ChatViewController {
    
    func presentImageUploadOptions(fromView presentFromView: UIView) {
        let cameraIsAvailable = UIImagePickerController.isSourceTypeAvailable(.camera)
        let photoLibraryIsAvailable = UIImagePickerController.isSourceTypeAvailable(.photoLibrary)
        
        if !cameraIsAvailable && !photoLibraryIsAvailable {
            // Show alert to check settings
            showAlert(withTitle: ASAPPLocalizedString("Photos Unavailable"),
                      message: ASAPPLocalizedString("Please update your settings to allow access to the camera and/or photo library."))
            return
        }
        
        if cameraIsAvailable && photoLibraryIsAvailable {
            presentCameraOrPhotoLibrarySelection(fromView: presentFromView)
        } else if cameraIsAvailable {
            presentCamera()
        } else if photoLibraryIsAvailable {
            presentPhotoLibrary()
        }
    }
    
    func presentCameraOrPhotoLibrarySelection(fromView presentFromView: UIView) {
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .actionSheet)
        alertController.addAction(UIAlertAction(title: ASAPPLocalizedString("Camera"), style: .default, handler: { [weak self] (alert) in
            self?.presentCamera()
        }))
        alertController.addAction(UIAlertAction(title: ASAPPLocalizedString("Photo Library"), style: .default, handler: { [weak self] (alert) in
            self?.presentPhotoLibrary()
        }))
        alertController.addAction(UIAlertAction(title: ASAPPLocalizedString("Cancel"), style: .destructive, handler: { (alert) in
            // No-op
        }))
        alertController.popoverPresentationController?.sourceView = presentFromView
        
        present(alertController, animated: true, completion: nil)
    }
    
    func presentCamera() {
        let imagePickerController = createImagePickerController(withSourceType: .camera)
        imagePickerController.sourceType = .camera
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func presentPhotoLibrary() {
        let imagePickerController = createImagePickerController(withSourceType: .photoLibrary)
        imagePickerController.sourceType = .photoLibrary
        imagePickerController.delegate = self
        
        present(imagePickerController, animated: true, completion: nil)
    }
    
    func createImagePickerController(withSourceType sourceType: UIImagePickerControllerSourceType) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        imagePickerController.allowsEditing = true
        
        let barTintColor = ASAPP.styles.backgroundColor2
        imagePickerController.navigationBar.shadowImage = nil
        imagePickerController.navigationBar.setBackgroundImage(nil, for: .default)
        imagePickerController.navigationBar.barTintColor = barTintColor
        imagePickerController.navigationBar.tintColor = ASAPP.styles.foregroundColor2
        if barTintColor.isBright() {
            imagePickerController.navigationBar.barStyle = .default
        } else {
            imagePickerController.navigationBar.barStyle = .black
        }
        imagePickerController.view.backgroundColor = ASAPP.styles.backgroundColor1
        
        return imagePickerController
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

// MARK:- Alerts

extension ChatViewController {
    
    func showAlert(withTitle title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .destructive, handler: nil))
        
        present(alertController, animated: true, completion: nil)
    }
}

// MARK:- Actions

extension ChatViewController {
    
    func sendMessage(withText text: String, fromPrediction: Bool = false) {
        if isLiveChat {
            conversationManager.sendTextMessage(text)
        } else {
            conversationManager.sendSRSQuery(text, isRequestFromPrediction: fromPrediction)
        }
    }
    
    func reloadMessageEvents() {
        conversationManager.getLatestMessages { [weak self] (fetchedEvents, error) in
            
            if let fetchedEvents = fetchedEvents,
                let chatMessagesView = self?.chatMessagesView {
                
                let shouldScroll = chatMessagesView.numberOfEvents != fetchedEvents.count
                
                chatMessagesView.replaceMessageEventsWithEvents(fetchedEvents)
                
                if shouldScroll {
                    chatMessagesView.scrollToBottomAnimated(false)
                }
                
                self?.updateIsLiveChat(withEvents: fetchedEvents)
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
