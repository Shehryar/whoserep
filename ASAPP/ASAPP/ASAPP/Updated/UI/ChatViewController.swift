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
    
    var credentials: Credentials
    var conversationManager: ConversationManager
    
    var keyboardObserver = ASAPPKeyboardObserver()
    var keyboardOffset: CGFloat = 0 {
        didSet {
            if keyboardOffset != oldValue {
                view.setNeedsUpdateConstraints()
                view.updateConstraintsIfNeeded()
            }
        }
    }
    
    // MARK: Properties: UI
    
    var chatMessagesView: ChatMessagesView
    var chatInputView = ChatInputView()
    
    // MARK:- Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        self.conversationManager = ConversationManager(withCredentials: credentials)
        self.chatMessagesView = ChatMessagesView()
        
        super.init(nibName: nil, bundle: nil)
        
        self.conversationManager.delegate = self
        if let storedEvents = self.conversationManager.getStoredMessages() {
            self.chatMessagesView.messageEvents = storedEvents
        }
        
        chatInputView.onSendButtonTap = {[weak self] (messageText: String) in
            self?.sendMessage(withText: messageText)
            self?.chatInputView.clear()
        }
        
        keyboardObserver.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        keyboardObserver.delegate = nil
        conversationManager.delegate = nil
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        view.addSubview(chatMessagesView)
        view.addSubview(chatInputView)
        
        updateViewConstraints()
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
            chatMessagesView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(navigationBar.frame), 0, 0, 0)
        }
    }
}

// MARK:- KeyboardObserver

extension ChatViewController: ASAPPKeyboardObserverDelegate {
    func ASAPPKeyboardWillShow(size: CGRect, duration: NSTimeInterval) {
        keyboardOffset = size.height
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
        }
        chatMessagesView.scrollToBottom(false)
    }
    
    func ASAPPKeyboardWillHide(duration: NSTimeInterval) {
        keyboardOffset = 0
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK:- ConversationManagerDelegate

extension ChatViewController: ConversationManagerDelegate {
    func conversationManager(manager: ConversationManager, didReceiveMessageEvent messageEvent: Event) {
        chatMessagesView.insertNewMessageEvent(messageEvent)
    }
}

// MARK:- Actions

extension ChatViewController {
    func sendMessage(withText text: String) {
        conversationManager.sendMessage(text)
    }
}
