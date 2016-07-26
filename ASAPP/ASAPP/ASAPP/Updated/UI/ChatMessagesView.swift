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
    
    var messageEvents: [Event] = [] {
        didSet {
            tableView.reloadData()
        }
    }
    
    var contentInset: UIEdgeInsets {
        set { tableView.contentInset = newValue }
        get { return tableView.contentInset }
    }
    
    // MARK: Private Properties
    
    private let tableView = UITableView()

    private var newMessageEvents = Set<Event>()
    
    private let MessageCellReuseId = "MessageCellReuseId"
    
    // MARK:- Initialization
    
    override init(frame: CGRect) {
        super.init(frame: CGRectZero)
     
        backgroundColor = UIColor.whiteColor()
        clipsToBounds = false
        
        tableView.frame = bounds
        tableView.clipsToBounds = false
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
        
        if newMessageEvents.contains(event) {
            (cell as? ChatMessageEventCell)?.animate()
            newMessageEvents.remove(event)
        }
    }
}

// MARK:- Public Instance Methods

extension ChatMessagesView {
    
    // MARK: Messages
    
    func insertNewMessageEvent(event: Event) {
        newMessageEvents.insert(event)
        
        let wasNearBottom = isNearBottom()
        
        messageEvents.append(event)
        tableView.reloadData()
        
        if wasNearBottom {
            scrollToBottomAnimated(true)
        }
    }
    
    // MARK: Scroll
    
    func isNearBottom(delta: CGFloat = 80) -> Bool {
        return tableView.contentOffset.y + delta >= tableView.contentSize.height - CGRectGetHeight(tableView.bounds)
    }
    
    func scrollToBottomIfNeeded(animated: Bool) {
        if !isNearBottom(10) {
            return
        }
        scrollToBottomAnimated(animated)
    }

    func scrollToBottomAnimated(animated: Bool) {
        var indexPath: NSIndexPath?
        let lastSection = numberOfSectionsInTableView(tableView) - 1
        if lastSection >= 0 {
            let lastRow = tableView(tableView, numberOfRowsInSection: lastSection) - 1
            if lastRow >= 0 {
                indexPath = NSIndexPath(forRow: lastRow, inSection: lastSection)
            }
        }
        
        if let indexPath = indexPath {
            tableView.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Top, animated: animated)
        }
    }
}
