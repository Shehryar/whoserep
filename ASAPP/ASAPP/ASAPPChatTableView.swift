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
    
    var stateDataSource: ASAPPStateDataSource?
    var eventCenter: ASAPPStateEventCenter!
    
    static let CELL_IDENT_MSG_SEND: String = "asappCellMsgSend"
    static let CELL_IDENT_MSG_RECEIVE: String = "asappCellMsgReceive"
    static let CELL_IDENT_MSG_RECEIVE_CUSTOMER: String = "asappCellMsgReceiveCustomer"
    
    var eventSource: ASAPPChatDataSource!
    
    var heightForRowAtIndexPath: [NSIndexPath: AnyObject] = [:]
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    convenience init(stateDataSource: ASAPPStateDataSource, eventCenter: ASAPPStateEventCenter) {
        self.init()
        self.eventCenter = eventCenter
        self.stateDataSource = stateDataSource
        self.delegate = self
        
        self.registerClass(ASAPPBubbleViewCell.self, forCellReuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_SEND)
        self.registerClass(ASAPPBubbleViewCell.self, forCellReuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE)
        self.registerClass(ASAPPBubbleViewCell.self, forCellReuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE_CUSTOMER)
        
        eventSource = ASAPPChatDataSource()
        eventSource.stateDataSource = self.stateDataSource
        self.dataSource = eventSource
        
        self.separatorColor = UIColor.clearColor()
        self.separatorStyle = .None
        
        self.allowsSelection = false
        
//        self.estimatedRowHeight = 44
        self.rowHeight = UITableViewAutomaticDimension
        
        registerForEvents()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func registerForEvents() {
        eventCenter.on(.Event, observer: self) { [weak self] (info) in
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
                self?.beginUpdates()
                source.addObject(info!)
                let shouldScroll = self?.isNearBottom(10)
                let indexPath = NSIndexPath(forRow: source.events.count - 1, inSection: 0)
                self?.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.None)
                self?.endUpdates()
                if isNew && shouldScroll! {
                    self?.scrollToBottom(true)
                }
            }
        }
        
        eventCenter.on(.FetchedEvents, observer: self) { [weak self] (info) in
            guard self != nil else {
                return
            }
            
            self?.scrollToBottomIfNeeded(false)
        }
    }
    
    func didClearEventLog() {
        if let source = self.dataSource as? ASAPPChatDataSource {
            source.clearAll()
            self.reloadData()
        }
    }
    
    func scrollToBottomIfNeeded(animated: Bool) {
        if !isNearBottom(10) {
            return
        }
        
        scrollToBottom(animated)
    }
    
    func scrollToBottom(animated: Bool) {
        if let source = self.dataSource as? ASAPPChatDataSource {
            if source.events.count == 0 {
                return
            }
            let indexPath = NSIndexPath(forRow: source.events.count - 1, inSection: 0)
            self.scrollToRowAtIndexPath(indexPath, atScrollPosition: UITableViewScrollPosition.Bottom, animated: animated)
        }
    }
    
    func isNearBottom(delta: CGFloat) -> Bool {
        return self.contentOffset.y + delta >= self.contentSize.height - self.frame.size.height
    }
    
    func tableView(tableView: UITableView, estimatedHeightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        if let height = heightForRowAtIndexPath[indexPath] as? CGFloat {
            return height
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let tableDataSource = tableView.dataSource as? ASAPPChatDataSource {
            guard var eventInfo = tableDataSource.events.objectAtIndex(indexPath.row) as? [String: AnyObject],
                let event = eventInfo["event"] as? ASAPPEvent,
                let isNew = eventInfo["isNew"] as? Bool else {
                    ASAPPLoge("ERROR: Invalid event info")
                    return
            }
            
            if !isNew {
                return
            }
            
            eventInfo["isNew"] = false
            tableDataSource.events.replaceObjectAtIndex(indexPath.row, withObject: eventInfo)
            
            if let bubbleCell = cell as? ASAPPBubbleViewCell {
                bubbleCell.animate()
            }
        }
        
        heightForRowAtIndexPath[indexPath] = cell.frame.size.height
        print(heightForRowAtIndexPath[indexPath])
    }
    
    func tableView(tableView: UITableView, didEndDisplayingCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        heightForRowAtIndexPath[indexPath] = cell.frame.size.height
        print("REMOVED", cell.frame.size.height)
    }
    
    // MARK: - DataSource
    
    class ASAPPChatDataSource: NSObject, UITableViewDataSource {
        
        var stateDataSource: ASAPPStateDataSource!
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
                let event = eventInfo["event"] as? ASAPPEvent,
                let isNew = eventInfo["isNew"] as? Bool else {
                    ASAPPLoge("ERROR: Invalid event info")
                    return UITableViewCell()
            }
            
            if event.isMessageEvent() {
                var cell: ASAPPBubbleViewCell = ASAPPBubbleViewCell()
                if stateDataSource.isMyEvent(event) {
                    cell = ASAPPBubbleViewCell(style: .Default, reuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_SEND, stateDataSource: stateDataSource)
                } else if !stateDataSource.isCustomer() && event.isCustomerEvent() {
                    cell = ASAPPBubbleViewCell(style: .Default, reuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE_CUSTOMER, stateDataSource: stateDataSource)
                } else {
                    cell = ASAPPBubbleViewCell(style: .Default, reuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE, stateDataSource: stateDataSource)
                }
                
                cell.setEvent(event, isNew: isNew)
                cell.layoutSubviews()
                
                return cell
            }
            
            return UITableViewCell()
        }
    }
}
