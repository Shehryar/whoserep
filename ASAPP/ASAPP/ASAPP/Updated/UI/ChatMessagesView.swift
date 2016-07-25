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
    
    public var messageEvents: [Event] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    public var contentInset: UIEdgeInsets {
        set { tableView.contentInset = newValue }
        get { return tableView.contentInset }
    }
    
    // MARK: Properties: UI
    let tableView = UITableView()

    // MARK:- Initialization
    
    let MessageCellReuseId = "MessageCellReuseId"
    
    override init(frame: CGRect) {
        super.init(frame: CGRectZero)
     
        backgroundColor = UIColor.whiteColor()
        
        tableView.frame = bounds
        tableView.autoresizingMask = [.FlexibleWidth, .FlexibleHeight]
        tableView.backgroundColor = UIColor.clearColor()
        tableView.separatorStyle = .None
        tableView.estimatedRowHeight = 80
        tableView.rowHeight = UITableViewAutomaticDimension
        tableView.registerClass(ChatMessageEventCell.self, forCellReuseIdentifier: MessageCellReuseId)
        tableView.dataSource = self
        tableView.delegate = self
        addSubview(tableView)
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
        return messageEvents.count
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(MessageCellReuseId) as? ChatMessageEventCell {
            cell.messageEvent = messageEvents[indexPath.row]
            return cell
        }
        
        return UITableViewCell()
    }
}

// MARK:- UITableViewDelegate

extension ChatMessagesView: UITableViewDelegate {
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        let event = messageEvents[indexPath.row]
        
        // TODO: Check if event.isNew
        if let messageCell = cell as? ChatMessageEventCell {
            messageCell.animate()
        }
    }
}

// MARK:- Public Instance Methods

extension ChatMessagesView {
    
    // MARK: Messages
    
    public func insertNewMessageEvent(event: Event) {
        messageEvents.append(event)
        tableView.reloadData()
    }
    
    // MARK: Scroll
    
    public func isNearBottom(delta: CGFloat) -> Bool {
        return tableView.contentOffset.y + delta >= tableView.contentSize.height - CGRectGetHeight(tableView.bounds)
    }
    
    public func scrollToBottomIfNeeded(animated: Bool) {
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
