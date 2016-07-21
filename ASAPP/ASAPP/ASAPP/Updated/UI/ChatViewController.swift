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
    var dataSource: ASAPPStateDataSource!
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
    
    var chatView: ASAPPChatTableView!
    var chatInputView = ChatInputView()
    
    // MARK:- Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        super.init(nibName: nil, bundle: nil)
        
        keyboardObserver.delegate = self
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        keyboardObserver.delegate = nil
    }
    
    // MARK:- View
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.whiteColor()
        
        // Subviews
        if let eventCenter = dataSource as? ASAPPStateEventCenter {
            // Chat View
            chatView = ASAPPChatTableView(stateDataSource: dataSource, eventCenter: eventCenter)
            self.view.addSubview(chatView)
        } else {
            ASAPPLoge("Invalid dataSource passed which cannot be cast into eventCenter")
        }
        chatInputView.onSendButtonTap = {[weak self] (messageText: String) in
            self?.chatInputView.clear()
        }
        
        view.addSubview(chatInputView)
        
        updateViewConstraints()
    }
    
    override func viewWillAppear(animated: Bool) {
        super.viewWillAppear(animated)
        
        keyboardObserver.registerForNotifications()
        
        
        // HACK
        chatView.eventSource.clearAll()
        let events = dataSource.eventsFromEventLog()
        if events == nil {
            return
        }
        
        for event in events! {
            if !event.isMessageEvent {
                continue
            }
            let eInfo: [String: AnyObject] = [
                "event": event,
                "isNew": false
            ]
            chatView.eventSource.addObject(eInfo)
        }
        
        chatView.reloadData()
        
        chatView.calculateHeightForAllCells()
        chatView.scrollToBottom(false)
    }
    
    override func viewWillDisappear(animated: Bool) {
        super.viewWillDisappear(animated)
        
        keyboardObserver.deregisterForNotification()
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
        
        chatView.snp_remakeConstraints { (make) in
            make.top.equalTo(self.view.snp_top)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            make.bottom.equalTo(chatInputView.snp_top)
        }
        
        super.updateViewConstraints()
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        
        if let navigationBar = navigationController?.navigationBar {
            chatView.contentInset = UIEdgeInsetsMake(CGRectGetMaxY(navigationBar.frame), 0, 0, 0)
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
        chatView.scrollToBottom(false)
    }
    
    func ASAPPKeyboardWillHide(duration: NSTimeInterval) {
        keyboardOffset = 0
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
        }
    }
}

// MARK:- Managing Data

extension ChatViewController {
    
}
