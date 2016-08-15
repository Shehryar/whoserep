//
//  ChatViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    // MARK: Public Properties
    
    private(set) var credentials: Credentials
    
    private(set) var styles: ASAPPStyles
    
    private var suggestedReplies: NSObject?
    
    // MARK: Private Properties
    
    private var conversationManager: ConversationManager
    
    private var keyboardObserver = KeyboardObserver()
    private var keyboardOffset: CGFloat = 0
    private var keyboardRenderedHeight: CGFloat = 0
    
    private let chatMessagesView: ChatMessagesView
    private let chatInputView = ChatInputView()
    private let connectionStatusView = ChatConnectionStatusView()
    private let suggestedRepliesView = ChatSuggestedRepliesView()
    private var shouldShowConnectionStatusView: Bool {
        return connectionStatusView.status == .Disconnected || connectionStatusView.status == .Connecting
    }
    private var isInitialLayout = true
    
    // MARK:- Initialization
    
    init(withCredentials credentials: Credentials, styles: ASAPPStyles?) {
        self.credentials = credentials
        self.styles = styles ?? ASAPPStyles()
        self.conversationManager = ConversationManager(withCredentials: credentials)
        self.chatMessagesView = ChatMessagesView(withCredentials: credentials)
        
        super.init(nibName: nil, bundle: nil)
        
        automaticallyAdjustsScrollViewInsets = false
        
        conversationManager.delegate = self
        
        chatMessagesView.delegate = self
        chatMessagesView.applyStyles(self.styles)
        chatMessagesView.replaceMessageEventsWithEvents(conversationManager.storedMessages)
        
        chatInputView.delegate = self
        chatInputView.applyStyles(self.styles)
        chatInputView.layer.shadowColor = UIColor.blackColor().CGColor
        chatInputView.layer.shadowOffset = CGSize(width: 0, height: 0)
        chatInputView.layer.shadowRadius = 2
        chatInputView.layer.shadowOpacity = 0.1
        
        suggestedRepliesView.delegate = self
        suggestedRepliesView.applyStyles(self.styles)
        
        connectionStatusView.applyStyles(self.styles)
        connectionStatusView.onTapToConnect = { [weak self] in
            self?.connectionStatusView.status = .Connecting
            self?.conversationManager.enterConversation()
        }
        
        keyboardObserver.delegate = self
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
        
        view.clipsToBounds = true
        view.backgroundColor = styles.backgroundColor1
        
        view.addSubview(chatMessagesView)
        view.addSubview(chatInputView)
        view.addSubview(suggestedRepliesView)
        view.addSubview(connectionStatusView)
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.registerForNotifications()
        
        if conversationManager.isConnected() {
            reloadMessageEvents()
        } else {
            connectionStatusView.status = .Connecting
            conversationManager.enterConversation()
        }
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.deregisterForNotification()
        
        view.endEditing(true)
        
        conversationManager.exitConversation()
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
        
        if isInitialLayout {
            chatMessagesView.scrollToBottomAnimated(false)
            isInitialLayout = false
        }
    }
    
    func updateFrames() {
        var minVisibleY: CGFloat = 0
        if let navigationBar = navigationController?.navigationBar {
            if let navBarFrame = navigationBar.superview?.convertRect(navigationBar.frame, toView: view) {
                let intersection = CGRectIntersection(chatMessagesView.frame, navBarFrame)
                if !CGRectIsNull(intersection) {
                    minVisibleY = CGRectGetMaxY(intersection)
                }
            }
        }
        
        let viewWidth = CGRectGetWidth(view.bounds)
        
        let connectionStatusHeight: CGFloat = 40
        var connectionStatusTop = minVisibleY - connectionStatusHeight
        if shouldShowConnectionStatusView {
            connectionStatusTop = minVisibleY
        }
        connectionStatusView.frame = CGRect(x: 0, y: connectionStatusTop, width: viewWidth, height: connectionStatusHeight)
        
        let inputHeight = ceil(chatInputView.sizeThatFits(CGSize(width: viewWidth, height: 300)).height)
        let inputTop = CGRectGetHeight(view.bounds) - keyboardOffset - inputHeight
        chatInputView.frame = CGRect(x: 0, y: inputTop, width: viewWidth, height: inputHeight)
        chatInputView.layoutSubviews()
        
        var repliesHeight: CGFloat = max(keyboardRenderedHeight + inputHeight, 225.0)
        var repliesTop = CGRectGetHeight(view.bounds)
        if suggestedReplies != nil {
            repliesTop -= repliesHeight
        }
        suggestedRepliesView.frame = CGRect(x: 0.0, y: repliesTop, width: viewWidth, height: repliesHeight)
        
        let messagesHeight = min(CGRectGetMinY(chatInputView.frame),
                                 CGRectGetMinY(suggestedRepliesView.frame))
        chatMessagesView.frame = CGRect(x: 0, y: 0, width: viewWidth, height: messagesHeight)
        chatMessagesView.layoutSubviews()
        chatMessagesView.contentInsetTop = CGRectGetMaxY(connectionStatusView.frame)
    }
    
    func updateFramesAnimated(animated: Bool = true, scrollToBottomIfNearBottom: Bool = false, completion: (() -> Void)? = nil) {
        let wasNearBottom = chatMessagesView.isNearBottom()
        if animated {
            UIView.animateWithDuration(0.2, animations: {
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
    
    func keyboardWillUpdateVisibleHeight(height: CGFloat, withDuration duration: NSTimeInterval, animationCurve: UIViewAnimationOptions) {
        keyboardOffset = height
        if height > 0 {
            keyboardRenderedHeight = height
        }
        
        updateFramesAnimated(scrollToBottomIfNearBottom: true)
    }
}

// MARK:- ChatMessagesViewDelegate

extension ChatViewController: ChatMessagesViewDelegate {
    func chatMessagesView(messagesView: ChatMessagesView, didTapImageView imageView: UIImageView, forEvent event: Event) {
        guard let image = imageView.image else {
            return
        }
        
        view.endEditing(true)
        
        let imageViewerImage = ImageViewerImage(image: image)
        let imageViewer = ImageViewer(withImages: [imageViewerImage], initialIndex: 0)
        imageViewer.preparePresentationFromImageView(imageView)
        imageViewer.presentationImageCornerRadius = 18
        presentViewController(imageViewer, animated: true, completion: nil)
    }
}

// MARK:- ChatInputViewDelegate

extension ChatViewController: ChatInputViewDelegate {
    func chatInputView(chatInputView: ChatInputView, didTypeMessageText text: String?) {
        let isTyping = text != nil && !text!.isEmpty
        conversationManager.updateCurrentUserTypingStatus(isTyping, withText: text)
    }
    
    func chatInputView(chatInputView: ChatInputView, didTapSendMessage message: String) {
        self.chatInputView.clear()
        self.sendMessage(withText: message)
    }
    
    func chatInputView(chatInputView: ChatInputView, didTapMediaButton mediaButton: UIButton) {
        presentImageUploadOptions(fromView: mediaButton)
    }
    
    func chatInputViewDidChangeContentSize(chatInputView: ChatInputView) {
        updateFramesAnimated(scrollToBottomIfNearBottom: true)
    }
}

// MARK:- ChatSuggestedRepliesView

extension ChatViewController: ChatSuggestedRepliesViewDelegate {
    func chatSuggestedRepliesViewDidCancel(repliesView: ChatSuggestedRepliesView) {
        suggestedReplies = nil
        chatInputView.becomeFirstResponder()
        updateFramesAnimated(scrollToBottomIfNearBottom: true)
    }
    
    func chatSuggestedRepliesView(replies: ChatSuggestedRepliesView, didSelectReply reply: NSObject) {
        suggestedReplies = nil
        
        chatInputView.becomeFirstResponder()
        updateFramesAnimated(scrollToBottomIfNearBottom: true)
    }
}

// MARK:- ConversationManagerDelegate

extension ChatViewController: ConversationManagerDelegate {
    func conversationManager(manager: ConversationManager, didReceiveMessageEvent messageEvent: Event) {
        chatMessagesView.insertNewMessageEvent(messageEvent)
        
        suggestedReplies = NSObject()
        chatInputView.endEditing(true)
        updateFramesAnimated(true, scrollToBottomIfNearBottom: true)
    }
    
    func conversationManager(manager: ConversationManager, didUpdateRemoteTypingStatus isTyping: Bool, withPreviewText previewText: String?, event: Event) {
        chatMessagesView.updateOtherParticipantTypingStatus(isTyping, withPreviewText: (credentials.isCustomer ? nil : previewText))
    }
    
    func conversationManager(manager: ConversationManager, connectionStatusDidChange isConnected: Bool) {
        connectionStatusView.status = isConnected ? .Connected : .Disconnected
        updateFramesAnimated()
        
        if isConnected {
            // Fetch events
            reloadMessageEvents()
        }
    }
}

// MARK:- Image Selection

extension ChatViewController {
    
    func presentImageUploadOptions(fromView presentFromView: UIView) {
        let cameraIsAvailable = UIImagePickerController.isSourceTypeAvailable(.Camera)
        let photoLibraryIsAvailable = UIImagePickerController.isSourceTypeAvailable(.PhotoLibrary)
        
        if !cameraIsAvailable && !photoLibraryIsAvailable {
            // TODO: Localization
            
            // Show alert to check settings
            showAlert(withTitle: "Photos Unavailable", message: "Please update your settings to allow access to the camera and/or photo library.")
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
        // TODO: Localization
        
        let alertController = UIAlertController(title: nil, message: nil, preferredStyle: .ActionSheet)
        alertController.addAction(UIAlertAction(title: "Camera", style: .Default, handler: { (alert) in
            self.presentCamera()
        }))
        alertController.addAction(UIAlertAction(title: "Photo Library", style: .Default, handler: { (alert) in
            self.presentPhotoLibrary()
        }))
        alertController.addAction(UIAlertAction(title: "Cancel", style: .Destructive, handler: { (alert) in
            // No-op
        }))
        alertController.popoverPresentationController?.sourceView = presentFromView
        
        presentViewController(alertController, animated: true, completion: nil)
    }
    
    func presentCamera() {
        let imagePickerController = createImagePickerController(withSourceType: .Camera)
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func presentPhotoLibrary() {
        let imagePickerController = createImagePickerController(withSourceType: .PhotoLibrary)
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func createImagePickerController(withSourceType sourceType: UIImagePickerControllerSourceType) -> UIImagePickerController {
        let imagePickerController = UIImagePickerController()
        
        let barTintColor = styles.backgroundColor2
        imagePickerController.navigationBar.barTintColor = barTintColor
        imagePickerController.navigationBar.tintColor = styles.foregroundColor2
        if barTintColor.isBright() {
            imagePickerController.navigationBar.barStyle = .Default
        } else {
            imagePickerController.navigationBar.barStyle = .Black
        }
        imagePickerController.view.backgroundColor = styles.backgroundColor1
        
        return imagePickerController
    }
}

// MARK:- UIImagePickerControllerDelegate

extension ChatViewController: UIImagePickerControllerDelegate, UINavigationControllerDelegate {
    
    func imagePickerController(picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [String : AnyObject]) {
        if let image = (info[UIImagePickerControllerEditedImage] ?? info[UIImagePickerControllerOriginalImage]) as? UIImage {
            conversationManager.sendPictureMessage(image)
        }
        
        dismissViewControllerAnimated(true, completion: nil)
    }
    
    func imagePickerControllerDidCancel(picker: UIImagePickerController) {
        dismissViewControllerAnimated(true, completion: nil)
    }
}

// MARK:- Alerts

extension ChatViewController {
    
    func showAlert(withTitle title: String, message: String?) {
        let alertController = UIAlertController(title: title, message: message, preferredStyle: .Alert)
        alertController.addAction(UIAlertAction(title: "Ok", style: .Destructive, handler: nil))
        
        presentViewController(alertController, animated: true, completion: nil)
    }
}

// MARK:- Actions

extension ChatViewController {
    
    func sendMessage(withText text: String) {
        conversationManager.sendMessage(text)
    }
    
    func reloadMessageEvents() {
        let shouldFetchMostRecentOnly = false
        if shouldFetchMostRecentOnly {
            if let mostRecentEvent = chatMessagesView.mostRecentEvent {
                conversationManager.getMessageEvents(mostRecentEvent) { [weak self] (fetchedEvents, error) in
                    if let fetchedEvents = fetchedEvents {
                        self?.chatMessagesView.mergeMessageEventsWithEvents(fetchedEvents)
                    }
                }
            } else {
                conversationManager.getLatestMessages { [weak self] (fetchedEvents, error) in
                    if let fetchedEvents = fetchedEvents {
                        self?.chatMessagesView.replaceMessageEventsWithEvents(fetchedEvents)
                    }
                }
            }
        } else {
            conversationManager.getLatestMessages { [weak self] (fetchedEvents, error) in
                if let fetchedEvents = fetchedEvents {
                    self?.chatMessagesView.replaceMessageEventsWithEvents(fetchedEvents)
                }
            }
        }
    }
}
