//
//  ChatViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    // MARK: Properties: Data
    
    private(set) var credentials: Credentials
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
    
    // MARK: Properties: UI
    
    private var chatMessagesView: ChatMessagesView
    private var chatInputView = ChatInputView()
    private var isInitialLayout = true
    
    // MARK:- Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        self.conversationManager = ConversationManager(withCredentials: credentials)
        self.chatMessagesView = ChatMessagesView(withCredentials: credentials)
        
        super.init(nibName: nil, bundle: nil)
        
        conversationManager.delegate = self
        
        chatMessagesView.replaceMessageEventsWithEvents(conversationManager.storedMessages)
        chatInputView.delegate = self
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
        chatInputView.delegate = nil
        conversationManager.delegate = nil
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.clipsToBounds = true
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(chatMessagesView)
        view.addSubview(chatInputView)
        
        view.setNeedsUpdateConstraints()
        view.updateFocusIfNeeded()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        keyboardObserver.registerForNotifications()
        conversationManager.enterConversation()
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        keyboardObserver.deregisterForNotification()
    }
    
    override func viewDidDisappear(animated: Bool) {
        super.viewDidDisappear(animated)
        conversationManager.exitConversation()
    }
}

// MARK:- Layout

extension ChatViewController {
    override func updateViewConstraints() {
        chatInputView.snp_updateConstraints { (make) in
            make.bottom.equalTo(self.view.snp_bottom).offset(-keyboardOffset)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
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
            chatMessagesView.contentInsetTop = CGRectGetMaxY(navigationBar.frame)
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
        
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
            if keyboardWasHidden && height > 0{
                self.chatMessagesView.scrollToBottomAnimated(false)
            }
        }
    }
}

// MARK:- ChatInputViewDelegate

extension ChatViewController: ChatInputViewDelegate {
    func chatInputView(chatInputView: ChatInputView, didTypeMessageText text: String?) {
        let isTyping = text != nil && !text!.isEmpty
        conversationManager.updateCurrentUserTypingStatus(isTyping, withText: text)
    }
    
    func chatInputView(chatInputView: ChatInputView, didTapSendMessage message: String) {
        self.sendMessage(withText: message)
        self.chatInputView.clear()
    }
    
    func chatInputViewDidTapMediaButton(chatInputView: ChatInputView) {
        let alert = UIAlertController(title: "Coming Soon!", message: "This feature is still under development.", preferredStyle: .Alert)
        alert.addAction(UIAlertAction(title: "Ok", style: .Default, handler: nil))
        presentViewController(alert, animated: true, completion: nil)
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
