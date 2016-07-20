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
    
    var heightForRowAtIndexPath: [Int: AnyObject] = [:]
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
    }
    
    convenience init(stateDataSource: ASAPPStateDataSource, eventCenter: ASAPPStateEventCenter) {
        self.init()
        self.eventCenter = eventCenter
        self.stateDataSource = stateDataSource
        self.delegate = self
        
        eventSource = ASAPPChatDataSource()
        eventSource.stateDataSource = self.stateDataSource
        self.dataSource = eventSource
        
        self.separatorColor = UIColor.clearColor()
        self.separatorStyle = .None
        self.allowsSelection = false
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
            
            guard var eInfo = info as? [String: AnyObject],
                let event = eInfo["event"] as? Event,
                let isNew = eInfo["isNew"] as? Bool
                else {
                    return
            }
            
            if !event.shouldDisplay {
                return
            }
            
            if let source = self?.dataSource as? ASAPPChatDataSource {
                let shouldScroll = self?.isNearBottom(10)
                if !shouldScroll! {
                    eInfo["isNew"] = false
                }
                
                self?.beginUpdates()
                source.addObject(eInfo)
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
            
            self?.calculateHeightForAllCells()
            self?.scrollToBottomIfNeeded(false)
        }
    }
    
    func calculateHeightForAllCells() {
        for i in 0 ..< self.numberOfRowsInSection(0) {
            if let cell = eventSource.cellAtIndexRow(self, row: i) as? ASAPPBubbleViewCell {
                let size = cell.sizeThatFits(CGSizeMake(self.bounds.size.width, CGFloat.max))
                heightForRowAtIndexPath[i] = cell.holderHeight + cell.BUBBLE_OFFSET
            }
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
        if let height = heightForRowAtIndexPath[indexPath.row] as? CGFloat {
            return height
        } else {
            return UITableViewAutomaticDimension
        }
    }
    
    func tableView(tableView: UITableView, willDisplayCell cell: UITableViewCell, forRowAtIndexPath indexPath: NSIndexPath) {
        if let tableDataSource = tableView.dataSource as? ASAPPChatDataSource {
            guard var eventInfo = tableDataSource.events.objectAtIndex(indexPath.row) as? [String: AnyObject],
                let event = eventInfo["event"] as? Event,
                let isNew = eventInfo["isNew"] as? Bool else {
                    ASAPPLoge("ERROR: Invalid event info")
                    return
            }
            
            if let bubbleCell = cell as? ASAPPBubbleViewCell {
                heightForRowAtIndexPath[indexPath.row] = cell.frame.size.height
                
                if !isNew {
                    return
                }
                
                eventInfo["isNew"] = false
                tableDataSource.events.replaceObjectAtIndex(indexPath.row, withObject: eventInfo)
                
                bubbleCell.animate()
            }
        }
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
            return cellAtIndexRow(tableView, row: indexPath.row)
        }
        
        func cellAtIndexRow(tableView: UITableView, row: Int) -> UITableViewCell {
            guard let eventInfo = events.objectAtIndex(row) as? [String: AnyObject],
                let event = eventInfo["event"] as? Event,
                let isNew = eventInfo["isNew"] as? Bool else {
                    ASAPPLoge("ERROR: Invalid event info")
                    return UITableViewCell()
            }
            
            return cellForEvent(tableView, event: event, isNew: isNew)
        }
        
        func cellForEvent(tableView: UITableView, event: Event, isNew: Bool) -> UITableViewCell {
            if event.isMessageEvent {
                var cell: ASAPPBubbleViewCell = ASAPPBubbleViewCell()
                var reuseIdentifier: String? = nil
                
                if stateDataSource.isMyEvent(event) {
                    reuseIdentifier = ASAPPChatTableView.CELL_IDENT_MSG_SEND
                } else if !stateDataSource.isCustomer() && event.isCustomerEvent {
                    reuseIdentifier = ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE_CUSTOMER
                } else {
                    reuseIdentifier = ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE
                }
                
                if let reuseCell = tableView.dequeueReusableCellWithIdentifier(reuseIdentifier!) as? ASAPPBubbleViewCell {
                    cell = reuseCell
                } else {
                    cell = ASAPPBubbleViewCell(style: .Default, reuseIdentifier: reuseIdentifier, stateDataSource: stateDataSource)
                }
                
                cell.setEvent(event, isNew: isNew)
                return cell
            }
            
            return UITableViewCell()
        }
    }
}
