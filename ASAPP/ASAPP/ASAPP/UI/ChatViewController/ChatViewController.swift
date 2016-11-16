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
    
    // MARK: Public Properties
    
    let credentials: Credentials
    
    let styles: ASAPPStyles
    
    let strings: ASAPPStrings
    
    let callback: ASAPPCallbackHandler
    
    // MARK: Private Properties
    
    fileprivate let simpleStore: ChatSimpleStore
    
    fileprivate let conversationManager: ConversationManager
    
    fileprivate var actionableMessage: SRSResponse?
    
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
        }
    }
    
    fileprivate var connectionStatus: ChatConnectionStatus = .disconnected {
        didSet {
            connectionStatusView.status = connectionStatus
        }
    }
    fileprivate var connectedAtLeastOnce = false
    
    fileprivate var showWelcomeOnViewAppear = true
    
    fileprivate var askTooltipPresenter: TooltipPresenter?
    fileprivate var keyboardObserver = KeyboardObserver()
    fileprivate var keyboardOffset: CGFloat = 0
    fileprivate var keyboardRenderedHeight: CGFloat = 0
    
    fileprivate let chatMessagesView: ChatMessagesView
    fileprivate let chatInputView: ChatInputView
    fileprivate let connectionStatusView: ChatConnectionStatusView
    fileprivate let suggestedRepliesView = ChatSuggestedRepliesView()
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
    fileprivate var isInitialLayout = true
    fileprivate var askQuestionVC: ChatWelcomeViewController?
    fileprivate var askQuestionNavController: UINavigationController?
    fileprivate var didPresentAskQuestionView = false
    fileprivate var askQuestionVCVisible = false
    fileprivate var delayedDisconnectTime: Date?
    
    fileprivate var hapticFeedbackGenerator: Any?
    
    // MARK:- Initialization
    
    init(withCredentials credentials: Credentials,
         styles: ASAPPStyles?,
         strings: ASAPPStrings?,
         callback: @escaping ASAPPCallbackHandler) {
        
        self.credentials = credentials
        self.styles = styles ?? ASAPPStyles()
        self.strings = strings ?? ASAPPStrings()
        self.callback = callback
        self.simpleStore = ChatSimpleStore(credentials: credentials)
        self.conversationManager = ConversationManager(withCredentials: credentials)
        self.chatMessagesView = ChatMessagesView(withCredentials: self.credentials, styles: self.styles, strings: self.strings)
        self.chatInputView = ChatInputView(styles: self.styles, strings: self.strings)
        self.connectionStatusView = ChatConnectionStatusView(styles: self.styles, strings: self.strings)
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false
        
        conversationManager.delegate = self
        
        // Buttons
        
        let askButton = UIBarButtonItem.chatBubbleBarButtonItem(title: self.strings.chatAskNavBarButton,
                                                                font: self.styles.navBarButtonFont,
                                                                textColor: self.styles.navBarButtonForegroundColor,
                                                                backgroundColor: self.styles.navBarButtonBackgroundColor,
                                                                style: .ask,
                                                                target: self,
                                                                action: #selector(ChatViewController.didTapAskButton))
        navigationItem.leftBarButtonItem = askButton
        
        let closeButton = UIBarButtonItem.circleCloseBarButtonItem(foregroundColor: self.styles.navBarButtonForegroundColor,
                                                                   backgroundColor: self.styles.navBarButtonBackgroundColor,
                                                                   target: self,
                                                                   action: #selector(ChatViewController.didTapCloseButton))
        closeButton.accessibilityLabel = self.strings.accessibilityClose
        navigationItem.rightBarButtonItem = closeButton
        
        // Subviews
        
        chatMessagesView.delegate = self
        chatMessagesView.replaceMessageEventsWithEvents(conversationManager.storedMessages)
        
        if let mostRecentEvent = chatMessagesView.mostRecentEvent {
            let secondsSinceLastEvent = Date().timeIntervalSince(mostRecentEvent.eventDate)
            
            showWelcomeOnViewAppear = secondsSinceLastEvent > (15 * 60)
            if secondsSinceLastEvent < (60 * 15) {
                showWelcomeOnViewAppear = false
            }
        } else {
            showWelcomeOnViewAppear = true
        }
        
        chatInputView.delegate = self
        chatInputView.displayMediaButton = true
        chatInputView.layer.shadowColor = UIColor.black.cgColor
        chatInputView.layer.shadowOffset = CGSize(width: 0, height: 0)
        chatInputView.layer.shadowRadius = 2
        chatInputView.layer.shadowOpacity = 0.1
        
        suggestedRepliesView.delegate = self
        suggestedRepliesView.applyStyles(self.styles)
        
        connectionStatusView.onTapToConnect = { [weak self] in
            self?.reconnect()
        }
        
        // Ask a Question View Controller
        
        askQuestionVC = ChatWelcomeViewController(appOpenResponse: nil,
                                                  styles: self.styles,
                                                  strings: self.strings)
        if let askQuestionVC = askQuestionVC {
            askQuestionVC.delegate = self
            askQuestionNavController = UINavigationController(rootViewController: askQuestionVC)
            askQuestionNavController?.view.alpha = 0.0
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
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        askQuestionVC?.delegate = nil
        keyboardObserver.delegate = nil
        chatMessagesView.delegate = nil
        chatInputView.delegate = nil
        conversationManager.delegate = nil
        suggestedRepliesView.delegate = nil
        
        conversationManager.exitConversation()
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
            if styles.navBarBackgroundColor.isDark() {
                navigationBar.barStyle = .black
                if styles.navBarBackgroundColor != UIColor.black {
                    navigationBar.barTintColor = styles.navBarBackgroundColor
                }
            } else {
                navigationBar.barStyle = .default
                if styles.navBarBackgroundColor != UIColor.white {
                    navigationBar.barTintColor = styles.navBarBackgroundColor
                }
            }
            navigationBar.tintColor = styles.navBarButtonColor
            setNeedsStatusBarAppearanceUpdate()
        }
        
        // View
        
        view.clipsToBounds = true
        view.backgroundColor = styles.backgroundColor1
        updateViewForLiveChat(animated: false)
        
        view.addSubview(chatMessagesView)
        view.addSubview(chatInputView)
        view.addSubview(suggestedRepliesView)
        view.addSubview(connectionStatusView)
        
        // Ask Question
        if let askQuestionView = askQuestionNavController?.view {
            if let navView = navigationController?.view {
                navView.addSubview(askQuestionView)
            } else {
                view.addSubview(askQuestionView)
            }
            askQuestionView.alpha = 0.0
        }
        
        updateIsLiveChat(withEvents: conversationManager.storedMessages)
        
        
        let minTimeBetweenSessions: TimeInterval = 60 * 15 // 15 minutes
        if chatMessagesView.mostRecentEvent == nil ||
            chatMessagesView.mostRecentEvent!.eventDate.timeSinceIsGreaterThan(numberOfSeconds: minTimeBetweenSessions) {
            conversationManager.trackSessionStart()
        }
        
        // Inferred button
        conversationManager.trackButtonTap(buttonName: .openChat)
        
        
        if showWelcomeOnViewAppear || chatMessagesView.isEmpty {
            showWelcomeOnViewAppear = false
            setAskQuestionViewControllerVisible(true, animated: false, completion: nil)
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
                self?.askQuestionVC?.setAppOpenResponse(appOpenResponse: appOpenResponse, animated: true)
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
    
    // MARK: Status Bar Style
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if showWelcomeOnViewAppear || askQuestionVCVisible {
            return .lightContent
        } else {
            if styles.navBarBackgroundColor.isDark() {
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
        guard DEMO_LIVE_CHAT else {
            isLiveChat = false
            return
        }
        
        var tempLiveChat = false
        for (_, event) in events.enumerated().reversed() {
            if event.eventType == .newRep {
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
        if isLiveChat {
            clearSuggestedRepliesView(true, completion: nil)
            chatInputView.placeholderText = strings.chatInputPlaceholder
        } else {
            view.endEditing(true)
            chatInputView.placeholderText = strings.predictiveInputPlaceholder
        }
        
        if animated {
            updateFramesAnimated()
        } else {
            updateFrames()
        }
    }
    
    func showWelcomeView() {
        setAskQuestionViewControllerVisible(true, animated: true, completion: nil)
    }
    
    
    func dismissChatViewController() {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
    }
    
    // MARK: Button Actions
    
    func didTapAskButton() {
        showWelcomeView()
        
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
    
    func hasShownAskTooltip() -> Bool {
        return UserDefaults.standard.bool(forKey: hasShownAskTooltipKey())
    }
    
    func setHasShownTooltipTrue() {
        UserDefaults.standard.set(true, forKey: hasShownAskTooltipKey())
    }
    
    func showAskButtonTooltipIfNecessary() {
        guard !showWelcomeOnViewAppear && !askQuestionVCVisible && !hasShownAskTooltip() else {
                return
        }
        
        guard let navView = navigationController?.view,
            let buttonItem = navigationItem.leftBarButtonItem else {
            return
        }
        
        setHasShownTooltipTrue()
        
        askTooltipPresenter = TooltipView.showTooltip(withText: strings.chatAskTooltip,
                                                      styles: styles,
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
        // Ask Question
        if let askQuestionView = askQuestionNavController?.view {
            if let navView = navigationController?.view {
                askQuestionView.frame = navView.bounds
            } else {
                askQuestionView.frame = view.bounds
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
        if actionableMessage != nil {
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
    
    func handleSRSButtonItemSelection(_ buttonItem: SRSButtonItem) {
        
        simpleStore.updateSuggestedReplyEventLogSeqs(eventLogSeqs: suggestedRepliesView.actionableEventLogSeqs)
        
        if DEMO_CONTENT_ENABLED {
            if let deepLink = buttonItem.deepLink?.lowercased() {
                switch deepLink {
                case "troubleshoot":
                    if !chatMessagesView.isNearBottom() {
                        chatMessagesView.scrollToBottomAnimated(true)
                    }
                    conversationManager.sendFakeTroubleshooterMessage(buttonItem, afterEvent: chatMessagesView.mostRecentEvent)
                    return
                    
                case "restartdevicenow":
                    if !chatMessagesView.isNearBottom() {
                        chatMessagesView.scrollToBottomAnimated(true)
                    }
                    conversationManager.sendFakeDeviceRestartMessage(buttonItem, afterEvent: chatMessagesView.mostRecentEvent)
                    return
                    
                default:
                    // No-op
                    break
                }
            }
        }
        
        
        
        // Check if this is a web url
        if let webURL = buttonItem.webURL {
            if openWebURL(url: webURL) {
                suggestedRepliesView.deselectCurrentSelection(animated: true)
                DebugLog("Did select button with web url: \(webURL)")
                
                conversationManager.trackWebLink(link: webURL.absoluteString)
                return
            }
        }
        
        switch buttonItem.type {
        case .InAppLink, .Link:
            if let deepLink = buttonItem.deepLink {
                DebugLog("\nDid select action: \(deepLink) w/ userInfo: \(buttonItem.deepLinkData)")
                
                conversationManager.trackDeepLink(link: deepLink, deepLinkData: buttonItem.deepLinkData as? AnyObject)
                
                dismiss(animated: true, completion: { [weak self] in
                    self?.callback(deepLink, buttonItem.deepLinkData)
                })
            }
            break
            
        case .SRS, .Action, .Message:
            if !chatMessagesView.isNearBottom() {
                chatMessagesView.scrollToBottomAnimated(true)
            }
            
            let originalQuery = simpleStore.getSRSOriginalSearchQuery()
            conversationManager.sendButtonItemSelection(buttonItem,
                                                        originalSearchQuery: originalQuery)
            break
        }
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
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didSelectButtonItem buttonItem: SRSButtonItem) {
        
        handleSRSButtonItemSelection(buttonItem)
    }
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didTapMostRecentEvent event: Event) {
        showSuggestedRepliesViewIfNecessary()
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

// MARK:- ChatWelcomeViewController

extension ChatViewController: ChatWelcomeViewControllerDelegate {
    
    func setAskQuestionViewControllerVisible(_ visible: Bool, animated: Bool, completion: (() -> Void)?) {
        if askQuestionVCVisible == visible {
            return
        }
        
        askQuestionVCVisible = visible
        askQuestionVC?.view.endEditing(true)
        view.endEditing(true)
        
        if visible {
            clearSuggestedRepliesView(true)
            keyboardObserver.deregisterForNotification()
        } else {
            keyboardObserver.registerForNotifications()
        }
        
        guard let welcomeView = askQuestionNavController?.view else { return }
        let alpha: CGFloat = visible ? 1 : 0
        
        if animated {
            UIView.animate(withDuration: 0.3, animations: { [weak self] in
                welcomeView.alpha = alpha
                self?.updateStatusBar(false)
                }, completion: { [weak self] (completed) in
                    self?.askQuestionVC?.presentingViewUpdatedVisibility(visible)
                    completion?()
                    
                    if !visible {
                        Dispatcher.delay(4000, closure: {
                            self?.showAskButtonTooltipIfNecessary()
                        })
                    }
            })
        } else {
            welcomeView.alpha = alpha
            askQuestionVC?.presentingViewUpdatedVisibility(visible)
            updateStatusBar(false)
            completion?()
        }
        
    }
    
    // MARK: Delegate
    
    func chatWelcomeViewController(_ viewController: ChatWelcomeViewController,
                                   didFinishWithText queryText: String,
                                   fromPrediction: Bool) {
        
        simpleStore.updateSRSOriginalSearchQuery(query: queryText)
        
        keyboardObserver.registerForNotifications()
        chatMessagesView.scrollToBottomAnimated(false)
        
        setAskQuestionViewControllerVisible(false, animated: true) { [weak self] in
            Dispatcher.delay(250, closure: {
                self?.sendMessage(withText: queryText, fromPrediction: fromPrediction)
            })
        }
    }
    
    func chatWelcomeViewControllerDidTapViewChat(_ viewController: ChatWelcomeViewController) {
        setAskQuestionViewControllerVisible(false, animated: true) { [weak self] in
            self?.showSuggestedRepliesViewIfNecessary()
        }
        
        conversationManager.trackButtonTap(buttonName: .showChatFromPredictive)
    }
    
    func chatWelcomeViewControllerDidTapX(_ viewController: ChatWelcomeViewController) {
        conversationManager.trackButtonTap(buttonName: .closeChatFromPredictive)
        
        dismissChatViewController()
    }
    
    func chatWelcomeViewControllerIsConnected(_ viewController: ChatWelcomeViewController) -> Bool {
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
        if isLiveChat {
            let isTyping = text != nil && !text!.isEmpty
            conversationManager.sendUserTypingStatus(isTyping: isTyping, withText: text)
        }
    }
    
    func chatInputView(_ chatInputView: ChatInputView, didTapSendMessage message: String) {
        chatInputView.clear()
        sendMessage(withText: message)
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
        guard srsResponse.buttonItems != nil else { return }
        
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
    
    func chatSuggestedRepliesView(_ replies: ChatSuggestedRepliesView, didTapSRSButtonItem buttonItem: SRSButtonItem) {
        handleSRSButtonItemSelection(buttonItem)
    }
}

// MARK:- ConversationManagerDelegate

extension ChatViewController: ConversationManagerDelegate {
    func conversationManager(_ manager: ConversationManager, didReceiveMessageEvent messageEvent: Event) {
        provideHapticFeedbackForMessageIfNecessary(message: messageEvent)
        
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
    
    func conversationManager(_ manager: ConversationManager, conversationEndEventReceived event: Event) {
        if event.eventType == .conversationEnd {
            isLiveChat = false
        }
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
                self?.handleSRSButtonItemSelection(immediateAction)
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
        
        
        // Update for live-chat/srs-chat
        if srsResponse.classification == SRSClassifications.enterLiveChat.rawValue {
            isLiveChat = true
        } else if srsResponse.classification == SRSClassifications.enterSRSChat.rawValue {
            isLiveChat = false
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
        
        let barTintColor = styles.backgroundColor2
        imagePickerController.navigationBar.shadowImage = nil
        imagePickerController.navigationBar.setBackgroundImage(nil, for: .default)
        imagePickerController.navigationBar.barTintColor = barTintColor
        imagePickerController.navigationBar.tintColor = styles.foregroundColor2
        if barTintColor.isBright() {
            imagePickerController.navigationBar.barStyle = .default
        } else {
            imagePickerController.navigationBar.barStyle = .black
        }
        imagePickerController.view.backgroundColor = styles.backgroundColor1
        
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
