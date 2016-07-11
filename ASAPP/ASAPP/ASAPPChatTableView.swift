//
//  ASAPPChatTableView.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/16/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ASAPPChatTableView: UITableView, UITableViewDelegate, ASAPPStateDelegate {

    /*
    // Only override drawRect: if you perform custom drawing.
    // An empty implementation adversely affects performance during animation.
    override func drawRect(rect: CGRect) {
        // Drawing code
    }
    */
    
    var state: ASAPPState!
    
    static let CELL_IDENT_MSG_SEND: String = "asappCellMsgSend"
    static let CELL_IDENT_MSG_RECEIVE: String = "asappCellMsgReceive"
    static let CELL_IDENT_MSG_RECEIVE_CUSTOMER: String = "asappCellMsgReceiveCustomer"
    
    var eventSource: ASAPPChatDataSource!
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    convenience init(state: ASAPPState) {
        self.init()
        self.state = state
        self.delegate = self
        
        self.registerClass(ASAPPBubbleViewCell.self, forCellReuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_SEND)
        self.registerClass(ASAPPBubbleViewCell.self, forCellReuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE)
        self.registerClass(ASAPPBubbleViewCell.self, forCellReuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE_CUSTOMER)
        
        eventSource = ASAPPChatDataSource()
        eventSource.state = state
        self.dataSource = eventSource
        
        self.separatorColor = UIColor.clearColor()
        self.separatorStyle = .None
        
        self.allowsSelection = false
        
        self.estimatedRowHeight = 44
        self.rowHeight = UITableViewAutomaticDimension
        
        registerForEvents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func registerForEvents() {
        state.on(.Event, observer: self) { [weak self] (info) in
            guard self != nil else {
                return
            }
            
            guard let eInfo = info as? [String: AnyObject],
                let event = eInfo["event"] as? ASAPPEvent,
                let isNew = eInfo["isNew"] as? Bool
                else {
                    return
            }
            
            if !event.shouldDisplay() {
                return
            }
            
            if let source = self?.dataSource as? ASAPPChatDataSource {
                source.addObject(info!)
                let shouldScroll = self?.isNearBottom(10)
                let indexPath = NSIndexPath(forRow: source.events.count - 1, inSection: 0)
                self?.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
                if isNew {
                    self?.scrollToBottomIfNeeded(shouldScroll!)
                }
            }
        }
        
        state.on(.FetchedEvents, observer: self) { [weak self] (info) in
            guard self != nil else {
                return
            }
            
            self?.scrollToBottomIfNeeded(true)
        }
    }
    
    func didClearEventLog() {
        if let source = self.dataSource as? ASAPPChatDataSource {
            source.clearAll()
            self.reloadData()
        }
    }
    
    func scrollToBottomIfNeeded(isNeeded: Bool) {
        if !isNeeded {
            return
        }
        
        if let source = self.dataSource as? ASAPPChatDataSource {
            if source.events.count == 0 {
                return
            }
            let indexPath = NSIndexPath(forRow: source.events.count - 1, inSection: 0)
            self.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: false)
        }
    }
    
    func isNearBottom(delta: CGFloat) -> Bool {
//        _scrollView.contentOffset.y + delta >= _scrollView.contentSize.height - _scrollView.height;
        ASAPPLog(self.contentOffset.y, self.contentSize.height - self.frame.size.height)
        return self.contentOffset.y + delta >= self.contentSize.height - self.frame.size.height
    }
    
    override func insertRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        super.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
    }
    
    // MARK: - DataSource
    
    class ASAPPChatDataSource: NSObject, UITableViewDataSource {
        
        var state: ASAPPState!
        var events: NSMutableArray = []
        
        func addObject(anObject: AnyObject) {
            events.addObject(anObject)
        }
        
        func clearAll() {
            events.removeAllObjects()
        }
        
        func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
            return events.count
        }
        
        func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
            guard let eventInfo = events.objectAtIndex(indexPath.row) as? [String: AnyObject],
                let event = eventInfo["event"] as? ASAPPEvent else {
                    ASAPPLoge("ERROR: Invalid event info")
                    return UITableViewCell()
            }
            
            if event.isMessageEvent() {
                var cell: ASAPPBubbleViewCell = ASAPPBubbleViewCell()
                if state.isMyEvent(event) {
                    cell = ASAPPBubbleViewCell(style: .Default, reuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_SEND, state: state)
                } else if !state.isCustomer() && event.isCustomerEvent() {
                    cell = ASAPPBubbleViewCell(style: .Default, reuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE_CUSTOMER, state: state)
                } else {
                    cell = ASAPPBubbleViewCell(style: .Default, reuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE, state: state)
                }
                
                cell.setEvent(event)
                cell.layoutSubviews()
                
                return cell
            }
            
            return UITableViewCell()
        }
    }
}
