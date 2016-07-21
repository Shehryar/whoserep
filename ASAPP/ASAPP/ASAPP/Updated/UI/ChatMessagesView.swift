//
//  ChatMessagesView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesView: UIView {

    // MARK:- Public Properties
    private(set) public var conversationManager: ConversationManager
    
    public var contentInset: UIEdgeInsets {
        set { tableView.contentInset = newValue }
        get { return tableView.contentInset }
    }
    
    // MARK: Properties: Data
    
    
    // MARK: Properties: UI
    let tableView = UITableView()

    // MARK:- Initialization
    
    let MessageCellReuseId = "MessageCellReuseId"
    
    init(withConversationManager conversationManager: ConversationManager) {
        self.conversationManager = conversationManager
        super.init(frame: CGRectZero)
     
        backgroundColor = UIColor.whiteColor()
        
        tableView.frame = bounds
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.registerClass(ASAPPBubbleViewCell.self, forCellReuseIdentifier: MessageCellReuseId)
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
    }
    
    override init(frame: CGRect) {
        fatalError("must call init(withConversationManager:)")
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
}

// MARK:- UITableViewDataSource

extension ChatMessagesView: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return conversationManager.messageEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(MessageCellReuseId) as? ASAPPBubbleViewCell {
            cell.setEvent(conversationManager.messageEvents[indexPath.row], isNew: false)
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK:- UITableViewDelegate

extension ChatMessagesView: UITableViewDelegate {
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        return 60
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let event = conversationManager.messageEvents[indexPath.row]
        
        // TODO: Check if event.isNew
        if let bubbleCell = tableView.cellForRowAtIndexPath(indexPath) as? ASAPPBubbleViewCell {
            bubbleCell.animate()
        }
    }
}

// MARK:- Public Instance Methods: Scroll

extension ChatMessagesView {
    func isNearBottom(delta: CGFloat) -> Bool {
        return tableView.contentOffset.y + delta >= tableView.contentSize.height - CGRectGetHeight(tableView.bounds)
    }
    
    func scrollToBottomIfNeeded(animated: Bool) {
        if !isNearBottom(10) {
            return
        }
        scrollToBottom(animated)
    }

    public func scrollToBottom(animated: Bool) {
        var indexPath: NSIndexPath?
        let lastSection = numberOfSectionsInTableView(tableView) - 1
        if lastSection >= 0 {
            let lastRow = tableView(tableView, numberOfRowsInSection: lastSection) - 1
            if lastRow >= 0 {
                indexPath = NSIndexPath(forRow: lastRow, inSection: lastSection)
            }
        }
        
        if let indexPath = indexPath {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
        }
    }
}


