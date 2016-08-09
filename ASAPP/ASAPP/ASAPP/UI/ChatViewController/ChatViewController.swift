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
    
    // MARK: Private Properties
    
    private var conversationManager: ConversationManager
    
    private var keyboardObserver = KeyboardObserver()
    private var keyboardOffset: CGFloat = 0 {
        didSet {
            if keyboardOffset != oldValue {
                view.setNeedsUpdateConstraints()
                view.updateConstraintsIfNeeded()
            }
        }
    }
    
    private var chatMessagesView: ChatMessagesView
    private var chatInputView = ChatInputView()
    private var isInitialLayout = true
    
    // MARK:- Initialization
    
    init(withCredentials credentials: Credentials, styles: ASAPPStyles?) {
        self.credentials = credentials
        self.styles = styles ?? ASAPPStyles()
        self.conversationManager = ConversationManager(withCredentials: credentials)
        self.chatMessagesView = ChatMessagesView(withCredentials: credentials)
        
        super.init(nibName: nil, bundle: nil)
        
        edgesForExtendedLayout = .None
        
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
        
        conversationManager.exitConversation()
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        view.backgroundColor = styles.backgroundColor1
        
        view.addSubview(chatMessagesView)
        view.addSubview(chatInputView)
        
        view.setNeedsUpdateConstraints()
        
        conversationManager.enterConversation()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.registerForNotifications()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.deregisterForNotification()
        
        view.endEditing(true)
    }
}

// MARK:- Layout

extension ChatViewController {
    override func updateViewConstraints() {
        chatInputView.snp_updateConstraints { (make) in
            make.bottom.equalTo(self.view.snp_bottom).offset(-keyboardOffset)
            make.left.equalTo(self.view.snp_left)
            make.width.equalTo(self.view.snp_width)
            make.right.equalTo(self.view.snp_right)
        }
        
        chatMessagesView.snp_updateConstraints { (make) in
            make.top.equalTo(self.view.snp_top)
            make.left.equalTo(self.view.snp_left)
            make.right.equalTo(self.view.snp_right)
            make.bottom.equalTo(chatInputView.snp_top)
        }

        super.updateViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let navigationBar = navigationController?.navigationBar {
            if let navBarFrame = navigationBar.superview?.convertRect(navigationBar.frame, toView: view) {
                chatMessagesView.contentInsetTop = CGRectGetHeight(CGRectIntersection(navBarFrame, chatMessagesView.frame))
            }
        }
        
        if isInitialLayout {
            chatMessagesView.scrollToBottomAnimated(false)
            isInitialLayout = false
        }
    }
}

// MARK:- KeyboardObserver

extension ChatViewController: KeyboardObserverDelegate {
    
    func keyboardWillUpdateVisibleHeight(height: CGFloat, withDuration duration: NSTimeInterval, animationCurve: UIViewAnimationOptions) {
        let keyboardWasHidden = keyboardOffset <= 0
        keyboardOffset = height
        
        let wasNearBottom = chatMessagesView.isNearBottom()
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
            if wasNearBottom && keyboardWasHidden && height > 0 {
                self.chatMessagesView.scrollToBottomAnimated(false)
            }
        }
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
        if chatMessagesView.isNearBottom() {
            view.layoutIfNeeded()
            chatMessagesView.scrollToBottomAnimated(true)
        }
    }
}

// MARK:- ConversationManagerDelegate

extension ChatViewController: ConversationManagerDelegate {
    func conversationManager(manager: ConversationManager, didReceiveMessageEvent messageEvent: Event) {
        chatMessagesView.insertNewMessageEvent(messageEvent)
    }
    
    func conversationManager(manager: ConversationManager, didUpdateRemoteTypingStatus isTyping: Bool, withPreviewText previewText: String?, event: Event) {
        chatMessagesView.updateOtherParticipantTypingStatus(isTyping, withPreviewText: (credentials.isCustomer ? nil : previewText))
    }
    
    func conversationManager(manager: ConversationManager, connectionStatusDidChange isConnected: Bool) {
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
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .Camera
        imagePickerController.navigationBar.tintColor = Colors.blueColor()
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
    }
    
    func presentPhotoLibrary() {
        let imagePickerController = UIImagePickerController()
        imagePickerController.sourceType = .PhotoLibrary
        imagePickerController.navigationBar.tintColor = Colors.blueColor()
        imagePickerController.delegate = self
        
        presentViewController(imagePickerController, animated: true, completion: nil)
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
        conversationManager.getLatestMessages { [weak self] (fetchedEvents, error) in
            if let fetchedEvents = fetchedEvents {
                self?.chatMessagesView.mergeMessageEventsWithEvents(fetchedEvents)
            }
        }
    }
}
