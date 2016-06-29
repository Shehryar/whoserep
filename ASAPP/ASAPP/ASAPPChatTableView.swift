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
    
    static let CELL_IDENT_MSG_SEND: String = "asappCellMsgSend"
    static let CELL_IDENT_MSG_RECEIVE: String = "asappCellMsgReceive"
    static let CELL_IDENT_MSG_RECEIVE_CUSTOMER: String = "asappCellMsgReceiveCustomer"
    
    var eventSource: ASAPPChatDataSource!
    
    override init(frame: CGRect, style: UITableViewStyle) {
        super.init(frame: frame, style: style)
        self.delegate = self
        
        self.registerClass(ASAPPBubbleViewCell.self, forCellReuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_SEND)
        self.registerClass(ASAPPBubbleViewCell.self, forCellReuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE)
        self.registerClass(ASAPPBubbleViewCell.self, forCellReuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE_CUSTOMER)
        
        eventSource = ASAPPChatDataSource()
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
        ASAPP.instance.state.on(.Event, observer: self) { [weak self] (info) in
            guard self != nil else {
                return
            }
            
            guard let eInfo = info as? [String: AnyObject],
                let event = eInfo["event"] as? ASAPPEvent
                else {
                    return
            }
            
            if !event.shouldDisplay() {
                return
            }
            
            if let source = self?.dataSource as? ASAPPChatDataSource {
                source.addObject(info!)
                let indexPath = NSIndexPath(forRow: source.events.count - 1, inSection: 0)
                self?.insertRowsAtIndexPaths([indexPath], withRowAnimation: UITableViewRowAnimation.Automatic)
            }
        }
    }
    
    func didClearEventLog() {
        if let source = self.dataSource as? ASAPPChatDataSource {
            source.clearAll()
            self.reloadData()
        }
    }
    
    override func insertRowsAtIndexPaths(indexPaths: [NSIndexPath], withRowAnimation animation: UITableViewRowAnimation) {
        super.insertRowsAtIndexPaths(indexPaths, withRowAnimation: .None)
    }
    
    // MARK: - DataSource
    
    class ASAPPChatDataSource: NSObject, UITableViewDataSource {
        
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
                if event.isMyEvent() {
                    cell = ASAPPBubbleViewCell(style: .Default, reuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_SEND)
                } else if !ASAPP.isCustomer() && event.isCustomerEvent() {
                    cell = ASAPPBubbleViewCell(style: .Default, reuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE_CUSTOMER)
                } else {
                    cell = ASAPPBubbleViewCell(style: .Default, reuseIdentifier: ASAPPChatTableView.CELL_IDENT_MSG_RECEIVE)
                }
                
                cell.setEvent(event)
                cell.layoutSubviews()
                
                return cell
            }
            
            return UITableViewCell()
        }
    }
}
