//
//  ChatActionableMessageView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatActionableMessageView: UIView, ASAPPStyleable {

    var srsResponse: SRSResponse? {
        didSet {
            selectedButtonItem = nil
            buttonItems = srsResponse?.itemList?.buttonItems
        }
    }
    
    private(set) var selectedButtonItem: SRSButtonItem?
    
    var onButtonItemSelection: ((SRSButtonItem) -> Void)?
    
    private(set) var buttonItems: [SRSButtonItem]? {
        didSet {
            tableView.reloadData()
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    
    private let CellReuseId = "CellReuseId"
    
    private let replySizingCell = ChatSuggestedReplyCell()
    
    // MARK: Initialization
    
    func commonInit() {
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        tableView.alwaysBounceVertical = true
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.tableFooterView = UIView()
        tableView.registerClass(ChatSuggestedReplyCell.self,
                                forCellReuseIdentifier: CellReuseId)
        addSubview(tableView)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    deinit {
        tableView.dataSource = nil
        tableView.delegate = nil
    }
    
    // MARK:- ASAPPStyleable
    
    private(set) var styles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        tableView.reloadData()
    }
    
    // MARK:- Layout
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        tableView.frame = bounds
    }
}

// MARK:- UITableViewDataSource

extension ChatActionableMessageView: UITableViewDataSource {
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        if let buttonItems = buttonItems {
            return buttonItems.count
        }
        return 0
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        if let cell = tableView.dequeueReusableCellWithIdentifier(CellReuseId) as? ChatSuggestedReplyCell {
            styleSuggestedReplyCell(cell, atIndexPath: indexPath)
            return cell
        }
        return UITableViewCell()
    }
    
    // Mark: Utility
    
    func buttonItemForIndexPath(indexPath: NSIndexPath) -> SRSButtonItem? {
        if let buttonItems = buttonItems {
            if indexPath.row >= 0 && indexPath.row < buttonItems.count {
                return buttonItems[indexPath.row]
            }
        }
        return nil
    }
    
    func styleSuggestedReplyCell(cell: ChatSuggestedReplyCell, atIndexPath indexPath: NSIndexPath) {
        cell.textLabel?.textColor = styles.foregroundColor1
        cell.textLabel?.font = styles.buttonFont
        cell.backgroundColor = styles.backgroundColor2
        cell.selectedBackgroundColor = styles.backgroundColor2.highlightColor()
        cell.separatorBottomColor = styles.separatorColor1
        cell.textLabel?.text = buttonItemForIndexPath(indexPath)?.title.uppercaseString
        
        if selectedButtonItem != nil {
            if selectedButtonItem == buttonItemForIndexPath(indexPath) {
                cell.textLabel?.alpha = 1
            } else {
                cell.textLabel?.alpha = 0.3
            }
        } else {
            cell.textLabel?.alpha = 1
        }
    }
}

// MARK:- UITableViewDelegate

extension ChatActionableMessageView: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        styleSuggestedReplyCell(replySizingCell, atIndexPath: indexPath)
        let height = replySizingCell.sizeThatFits(CGSize(width: CGRectGetWidth(tableView.bounds), height: 0)).height
        return height
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let buttonItem = buttonItemForIndexPath(indexPath) {
            selectedButtonItem = buttonItem
            onButtonItemSelection?(buttonItem)
            
            
            UIView.animateWithDuration(0.3, animations: { 
                for cell in tableView.visibleCells {
                    if let cell = cell as? ChatSuggestedReplyCell,
                        let cellIdxPath = tableView.indexPathForCell(cell) {
                        self.styleSuggestedReplyCell(cell, atIndexPath: cellIdxPath)
                    }
                }
            })
        }
    }
}

// MARK:- Instance Methods

extension ChatActionableMessageView {
    func clearSelection() {
        selectedButtonItem = nil
        tableView.reloadData()
    }
}
