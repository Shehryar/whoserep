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
    
    fileprivate var actionableMessage: SRSResponse?
    
    fileprivate var originalSearchQuery: String? {
        didSet {
            if let originalSearchQuery = originalSearchQuery {
                UserDefaults.standard.set(originalSearchQuery, forKey: ORIGINAL_SEARCH_QUERY_KEY)
            } else {
                UserDefaults.standard.removeObject(forKey: ORIGINAL_SEARCH_QUERY_KEY)
            }
        }
    }
    
    fileprivate let ORIGINAL_SEARCH_QUERY_KEY = "SRSOriginalSearchQuery"
    
    // MARK: Private Properties
    
    fileprivate var conversationManager: ConversationManager
    
    /// If false, messages will be sent to SRS
    fileprivate var liveChat = false {
        didSet {
            updateViewForLiveChat()
        }
    }
    
    fileprivate var connectionStatus: ChatConnectionStatus = .disconnected {
        didSet {
            connectionStatusView.status = connectionStatus
        }
    }
    fileprivate var connectedAtLeastOnce = false
    
    fileprivate var showWelcomeOnViewAppear = true
    
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
        
        return connectionStatus == .disconnected
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
        self.conversationManager = ConversationManager(withCredentials: credentials,
                                                       environment: credentials.environment)
        self.chatMessagesView = ChatMessagesView(withCredentials: self.credentials, styles: self.styles, strings: self.strings)
        self.chatInputView = ChatInputView(styles: self.styles, strings: self.strings)
        self.originalSearchQuery = UserDefaults.standard.string(forKey: ORIGINAL_SEARCH_QUERY_KEY)
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
                                                                action: #selector(ChatViewController.showWelcomeView))
        navigationItem.leftBarButtonItem = askButton
        
        let closeButton = UIBarButtonItem.circleCloseBarButtonItem(foregroundColor: self.styles.navBarButtonForegroundColor,
                                                                   backgroundColor: self.styles.navBarButtonBackgroundColor,
                                                                   target: self,
                                                                   action: #selector(ChatViewController.dismissChatViewController))
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
        chatInputView.layer.shadowColor = UIColor.black.cgColor
        chatInputView.layer.shadowOffset = CGSize(width: 0, height: 0)
        chatInputView.layer.shadowRadius = 2
        chatInputView.layer.shadowOpacity = 0.1
        
        suggestedRepliesView.delegate = self
        suggestedRepliesView.applyStyles(self.styles)
        
        connectionStatusView.onTapToConnect = { [weak self] in
            if let blockSelf = self {
                blockSelf.connectionStatus = .connecting
                blockSelf.conversationManager.enterConversation()
                if !blockSelf.liveChat {
                    blockSelf.conversationManager.startSRS()
                }
            }
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
    
    func showWelcomeView() {
        setAskQuestionViewControllerVisible(true, animated: true, completion: nil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        keyboardObserver.delegate = nil
        chatMessagesView.delegate = nil
        chatInputView.delegate = nil
        conversationManager.delegate = nil
        
        // TODO: close this better
        conversationManager.exitConversation()
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        // Nav Bar
        
        if let navigationBar = navigationController?.navigationBar {
            navigationBar.isTranslucent = true
            navigationBar.backgroundColor = UIColor.white
            if styles.navBarBackgroundColor.isDark() {
                navigationBar.barStyle = .blackTranslucent
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
        }
        
        // View
        
        view.clipsToBounds = true
        view.backgroundColor = styles.backgroundColor1
        updateViewForLiveChat()
        
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
        
        if showWelcomeOnViewAppear || chatMessagesView.isEmpty {
            showWelcomeOnViewAppear = false
            setAskQuestionViewControllerVisible(true, animated: false, completion: nil)
        } else {
            showSuggestedRepliesViewIfNecessary(withEvent: chatMessagesView.mostRecentEvent, animated: false)
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.registerForNotifications()
        
        if conversationManager.isConnected() {
            reloadMessageEvents()
        } else {
            connectionStatus = .connecting
            conversationManager.enterConversation()
            Dispatcher.delay(2300, closure: {
                self.updateFramesAnimated()
            })
            if !liveChat {
                conversationManager.startSRS(completion: { (appOpenResponse) in
                    self.askQuestionVC?.setAppOpenResponse(appOpenResponse: appOpenResponse, animated: true)
                })
            }
        }
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.deregisterForNotification()
        
        view.endEditing(true)
        
        conversationManager.exitConversation()
    }
    
    // MARK: Status Bar Style
    
    override var preferredStatusBarStyle : UIStatusBarStyle {
        if showWelcomeOnViewAppear || askQuestionVCVisible {
            return .lightContent
        } else {
            return .default
        }
    }
    
    override var preferredStatusBarUpdateAnimation : UIStatusBarAnimation {
        return .fade
    }
    
    func updateStatusBar(_ animated: Bool) {
        if animated {
            UIView.animate(withDuration: 0.3, animations: { 
                self.setNeedsStatusBarAppearanceUpdate()
            })
        } else {
            setNeedsStatusBarAppearanceUpdate()
        }
    }
    
    // MARK: Supported Orientations
    
    override var supportedInterfaceOrientations: UIInterfaceOrientationMask {
        return .portrait
    }
    
    // MARK: Updates
    
    func updateViewForLiveChat() {
        if liveChat {
            chatInputView.displayMediaButton = true
            chatInputView.placeholderText = strings.chatInputPlaceholder
        } else {
            chatInputView.displayMediaButton = false
            chatInputView.placeholderText = strings.predictiveInputPlaceholder
        }
    }

    func dismissChatViewController() {
        if let presentingViewController = presentingViewController {
            presentingViewController.dismiss(animated: true, completion: nil)
        }
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
        if liveChat {
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
            UIView.animate(withDuration: 0.35, animations: {
                self.updateFrames()
                if wasNearBottom && scrollToBottomIfNearBottom {
                    self.chatMessagesView.scrollToBottomAnimated(false)
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
                return
            }
        }
    
        switch buttonItem.type {
        case .InAppLink, .Link:
            if let deepLink = buttonItem.deepLink {
                DebugLog("\nDid select action: \(deepLink) w/ userInfo: \(buttonItem.deepLinkData)")
                
                dismiss(animated: true, completion: {
                    self.callback(deepLink, buttonItem.deepLinkData)
                })
            }
            break
            
        case .SRS, .Action:
            if !chatMessagesView.isNearBottom() {
                chatMessagesView.scrollToBottomAnimated(true)
            }
            
            conversationManager.sendSRSButtonItemSelection(buttonItem, originalSearchQuery: originalSearchQuery, completion: { [weak self] in
                // TODO: Check for success
                self?.updateFramesAnimated()
            })
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
        showSuggestedRepliesViewIfNecessary(withEvent: event)
    }
    
    func chatMessagesView(_ messagesView: ChatMessagesView, didUpdateButtonItemsForEvent event: Event) {
        if event == chatMessagesView.mostRecentEvent {
            if let actionableMessage = event.srsResponse {
                suggestedRepliesView.reloadButtonItemsForActionableMessage(actionableMessage)
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
            UIView.animate(withDuration: 0.3, animations: { 
                welcomeView.alpha = alpha
                self.updateStatusBar(false)
                }, completion: { (completed) in
                    self.askQuestionVC?.presentingViewUpdatedVisibility(visible)
                    completion?()
            })
        } else {
            welcomeView.alpha = alpha
            askQuestionVC?.presentingViewUpdatedVisibility(visible)
            updateStatusBar(false)
            completion?()
        }
        
    }
    
    // MARK: Delegate
    
    func chatWelcomeViewController(_ viewController: ChatWelcomeViewController, didFinishWithText queryText: String) {
        
        originalSearchQuery = queryText
        
        keyboardObserver.registerForNotifications()
        self.chatMessagesView.scrollToBottomAnimated(false)
        
        setAskQuestionViewControllerVisible(false, animated: true) {
            Dispatcher.delay(250, closure: {
                self.sendMessage(withText: queryText)
            })
        }
    }
    
    func chatWelcomeViewControllerDidTapViewChat(_ viewController: ChatWelcomeViewController) {
        setAskQuestionViewControllerVisible(false, animated: true) {
            self.showSuggestedRepliesViewIfNecessary(withEvent: self.chatMessagesView.mostRecentEvent)
        }
    }
    
    func chatWelcomeViewControllerDidTapX(_ viewController: ChatWelcomeViewController) {
        dismissChatViewController()
    }
}

// MARK:- ChatInputViewDelegate

extension ChatViewController: ChatInputViewDelegate {
    func chatInputView(_ chatInputView: ChatInputView, didTypeMessageText text: String?) {
        if liveChat {
            let isTyping = text != nil && !text!.isEmpty
            conversationManager.updateCurrentUserTypingStatus(isTyping, withText: text)
        }
    }
    
    func chatInputView(_ chatInputView: ChatInputView, didTapSendMessage message: String) {
        self.chatInputView.clear()
        self.sendMessage(withText: message)
    }
    
    func chatInputView(_ chatInputView: ChatInputView, didTapMediaButton mediaButton: UIButton) {
        presentImageUploadOptions(fromView: mediaButton)
    }
    
    func chatInputViewDidChangeContentSize(_ chatInputView: ChatInputView) {
        updateFramesAnimated()
    }
}

// MARK:- ChatSuggestedRepliesView

extension ChatViewController: ChatSuggestedRepliesViewDelegate {
    
    func showSuggestedRepliesViewIfNecessary(withEvent event: Event?, animated: Bool = true) {
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
        
        showSuggestedRepliesView(withSRSResponse: srsResponse, animated: animated)
    }
    
    func showSuggestedRepliesView(withSRSResponse srsResponse: SRSResponse, animated: Bool = true, completion: (() -> Void)? = nil) {
        guard srsResponse.buttonItems != nil else { return }
        
        actionableMessage = srsResponse
        suggestedRepliesView.setActionableMessage(srsResponse, animated: animated)
        updateFramesAnimated(animated, scrollToBottomIfNearBottom: true, completion: completion)
    }
    
    func clearSuggestedRepliesView(_ animated: Bool = true, completion: (() -> Void)? = nil) {
        actionableMessage = nil
        
        updateFramesAnimated(animated, scrollToBottomIfNearBottom: true, completion: {
            self.suggestedRepliesView.clear()
            completion?()
        })
    }
    
    // MARK: Delegate
    
    func chatSuggestedRepliesViewDidCancel(_ repliesView: ChatSuggestedRepliesView) {
        if liveChat {
            _ = chatInputView.becomeFirstResponder()
        }
        clearSuggestedRepliesView()
    }
    
    func chatSuggestedRepliesView(_ replies: ChatSuggestedRepliesView, didTapSRSButtonItem buttonItem: SRSButtonItem) {
        handleSRSButtonItemSelection(buttonItem)
    }
}

// MARK:- ConversationManagerDelegate

extension ChatViewController: ConversationManagerDelegate {
    func conversationManager(_ manager: ConversationManager, didReceiveMessageEvent messageEvent: Event) {
        switch messageEvent.eventType {
        case .srsResponse, .textMessage, .pictureMessage:
            if !messageEvent.wasSentByUserWithCredentials(credentials), #available(iOS 10.0, *) {
                if let generator = hapticFeedbackGenerator as? UIImpactFeedbackGenerator {
                    generator.impactOccurred()
                }
            }
            break
            
        default:
            // no-op
            break
        }
        
        chatMessagesView.insertNewMessageEvent(messageEvent) {
            if messageEvent.eventType == .srsResponse {
                if let srsResponse = messageEvent.srsResponse {
                    if let immediateAction = srsResponse.immediateAction {
                        Dispatcher.delay(1200, closure: {
                            self.handleSRSButtonItemSelection(immediateAction)
                        })
                    } else if srsResponse.buttonItems != nil {
                        if self.suggestedRepliesView.frame.minY < self.view.bounds.height {
                            Dispatcher.delay(200, closure: { [weak self] in
                                self?.showSuggestedRepliesView(withSRSResponse: srsResponse)
                                })
                        } else {
                            Dispatcher.delay(1000, closure: { [weak self] in
                                self?.showSuggestedRepliesView(withSRSResponse: srsResponse)
                                })
                        }
                    } else {
                        self.clearSuggestedRepliesView()
                    }
                }
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
            delayedDisconnectTime = Date(timeIntervalSinceNow: 2) // 4 seconds from now
            Dispatcher.delay(2300, closure: {
                self.updateFramesAnimated()
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
        alertController.addAction(UIAlertAction(title: ASAPPLocalizedString("Camera"), style: .default, handler: { (alert) in
            self.presentCamera()
        }))
        alertController.addAction(UIAlertAction(title: ASAPPLocalizedString("Photo Library"), style: .default, handler: { (alert) in
            self.presentPhotoLibrary()
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
        if let image = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage {
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
    
    func sendMessage(withText text: String) {
        if liveChat {
            conversationManager.sendMessage(text)
        } else {
            conversationManager.sendMessageAsSRSQuery(text)
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
            }
        }
    }
}
