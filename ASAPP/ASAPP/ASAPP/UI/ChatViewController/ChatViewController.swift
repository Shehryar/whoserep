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
        self.chatMessagesView = ChatMessagesView()
        
        super.init(nibName: nil, bundle: nil)
        
        conversationManager.delegate = self
        
        chatMessagesView.replaceMessageEventsWithEvents(conversationManager.storedMessages)
        chatInputView.delegate = self
        
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
        
        chatMessagesView.snp_remakeConstraints { (make) in
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
    func keyboardWillShow(size: CGRect, duration: NSTimeInterval) {
        keyboardOffset = size.height
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
            self.chatMessagesView.scrollToBottomAnimated(false)
        }
    }
    
    func keyboardWillHide(duration: NSTimeInterval) {
        keyboardOffset = 0
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK:- ChatInputViewDelegate

extension ChatViewController: ChatInputViewDelegate {
    func chatInputView(chatInputView: ChatInputView, didTapSendMessage message: String) {
        self.sendMessage(withText: message)
        self.chatInputView.clear()
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
    
    func conversationManager(manager: ConversationManager, didUpdateRemoteTypingStatus isTyping: Bool, withEvent event: Event) {
        let userString = event.isCustomerEvent ? "Customer" : "Representative"
        let typingString = isTyping ? "started typing." : "finished typing."
        
        DebugLog("\(userString) \(typingString)")
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
