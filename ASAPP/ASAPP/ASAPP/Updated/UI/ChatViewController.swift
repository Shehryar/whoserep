//
//  ChatViewController.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatViewController: UIViewController {
    
    var credentials: Credentials
    
    var keyboardObserver = ASAPPKeyboardObserver()
    
    var chatView: ASAPPChatTableView!
    var input: ASAPPChatInputView!
    
    var keyboardOffset: CGFloat = 0
    var dataSource: ASAPPStateDataSource!
    
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
        
        // Subviews
        if let eventCenter = dataSource as? ASAPPStateEventCenter {
            // Input View
            if let action = dataSource as? ASAPPStateAction {
                input = ASAPPChatInputView(dataSource: dataSource, eventCenter: eventCenter, action: action)
                self.view.addSubview(input)
            } else {
                ASAPPLoge("Invalid dataSource passed which cannot be cast into action")
            }
            
            // Chat View
            chatView = ASAPPChatTableView(stateDataSource: dataSource, eventCenter: eventCenter)
            self.view.addSubview(chatView)
        } else {
            ASAPPLoge("Invalid dataSource passed which cannot be cast into eventCenter")
        }
        
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
        input.snp_updateConstraints { (make) in
            make.bottom.equalTo(self.view.snp_bottom).offset(-keyboardOffset)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
        }
        
        chatView.snp_remakeConstraints { (make) in
            make.top.equalTo(self.view.snp_top)
            make.leading.equalTo(self.view.snp_leading)
            make.trailing.equalTo(self.view.snp_trailing)
            make.bottom.equalTo(input.snp_top)
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

// MARK: - KeyboardObserver

extension ChatViewController: ASAPPKeyboardObserverDelegate {
    func ASAPPKeyboardWillShow(size: CGRect, duration: NSTimeInterval) {
        keyboardOffset = size.height
        view.setNeedsUpdateConstraints()
        view.updateConstraintsIfNeeded()
        
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
        }
        
        chatView.scrollToBottom(false)
    }
    
    func ASAPPKeyboardWillHide(duration: NSTimeInterval) {
        keyboardOffset = 0
        self.view.setNeedsUpdateConstraints()
        self.view.updateConstraintsIfNeeded()
        
        UIView.animateWithDuration(duration) {
            self.view.layoutIfNeeded()
        }
    }
}
