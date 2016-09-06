//
//  ChatSuggestedRepliesView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol ChatSuggestedRepliesViewDelegate {
    func chatSuggestedRepliesViewDidCancel(repliesView: ChatSuggestedRepliesView)
    func chatSuggestedRepliesView(replies: ChatSuggestedRepliesView, didTapSRSButtonItem buttonItem: SRSButtonItem)
}


// TODO: Handle Accessibility

class ChatSuggestedRepliesView: UIView, ASAPPStyleable {

    // MARK: Public Properties
    
    var actionableMessage: SRSResponse? {
        didSet {
            buttonItems = actionableMessage?.itemList?.buttonItems
        }
    }
    
    private var buttonItems: [SRSButtonItem]? {
        didSet {
            tableView.reloadData()
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    var delegate: ChatSuggestedRepliesViewDelegate?
    
    // MARK: Private Properties
    
    private let topBarView = UIView()
    
    private let closeButton = Button()
    
    private let separatorTop = UIView()
    
    private let separatorMiddle = UIView()
    
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    
    private let CellReuseId = "CellReuseId"
    
    private let replySizingCell = ChatSuggestedReplyCell()
    
    // MARK: Initialization
    
    func commonInit() {
        tableView.backgroundColor = UIColor.clearColor()
        tableView.scrollsToTop = false
        tableView.alwaysBounceVertical = false
        tableView.dataSource = self
        tableView.delegate = self
        tableView.separatorStyle = .None
        tableView.tableFooterView = UIView()
        tableView.registerClass(ChatSuggestedReplyCell.self,
                                forCellReuseIdentifier: CellReuseId)
        addSubview(tableView)
        
        closeButton.image = Images.xLightIcon()
        closeButton.imageSize = CGSize(width: 16, height: 16)
        closeButton.foregroundColor = Colors.mediumTextColor()
        closeButton.onTap = { [weak self] in
            if let blockSelf = self {
                blockSelf.delegate?.chatSuggestedRepliesViewDidCancel(blockSelf)
            }
        }
        topBarView.addSubview(closeButton)
        
        topBarView.addSubview(separatorTop)
        topBarView.addSubview(separatorMiddle)
        
        addSubview(topBarView)
        
        applyStyles(styles)
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
    
    // MARK: ASAPPStyleable
    
    private(set) var styles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        
        backgroundColor = styles.backgroundColor1
        topBarView.backgroundColor = styles.backgroundColor2
        closeButton.setForegroundColor(styles.foregroundColor2,
                                       forState: .Normal)
        closeButton.setForegroundColor(styles.foregroundColor2.highlightColor(),
                                       forState: .Normal)
        separatorTop.backgroundColor = styles.separatorColor2
        separatorMiddle.backgroundColor = styles.separatorColor2
        
        tableView.backgroundColor = styles.backgroundColor1
        
        tableView.reloadData()
    }
}

// MARK:- Layout

extension ChatSuggestedRepliesView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let topBarHeight: CGFloat  = 44.0
        topBarView.frame = CGRect(x: 0.0, y: 0.0, width: CGRectGetWidth(bounds), height: topBarHeight)
        
        let separatorStroke: CGFloat = 1.0
        separatorTop.frame = CGRect(x: 0.0, y: 0.0, width: CGRectGetWidth(bounds), height: separatorStroke)
        separatorMiddle.frame = CGRect(x: 0.0, y: CGRectGetHeight(topBarView.bounds) - separatorStroke, width: CGRectGetWidth(topBarView.bounds), height: separatorStroke)
        
        let closeButtonSize: CGFloat = 50.0
        let closeButtonLeft = CGRectGetWidth(topBarView.bounds) - closeButtonSize
        closeButton.frame = CGRect(x: closeButtonLeft, y: 0.0, width: closeButtonSize, height: topBarHeight)
        
        let tableViewHeight = CGRectGetHeight(bounds) - topBarHeight
        tableView.frame = CGRect(x: 0.0, y: topBarHeight, width: CGRectGetWidth(bounds), height: tableViewHeight)
    }
}

// MARK:- UITableViewDataSource

extension ChatSuggestedRepliesView: UITableViewDataSource {
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
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
        cell.textLabel?.font = styles.buttonFont
        cell.textLabel?.textColor = styles.foregroundColor1
        cell.backgroundColor = styles.backgroundColor1
        cell.selectedBackgroundColor = styles.backgroundColor2
        cell.separatorBottomColor = styles.separatorColor1
        cell.textLabel?.text = buttonItemForIndexPath(indexPath)?.title
    }
}

extension ChatSuggestedRepliesView: UITableViewDelegate {
    func tableView(tableView: UITableView, heightForRowAtIndexPath indexPath: NSIndexPath) -> CGFloat {
        styleSuggestedReplyCell(replySizingCell, atIndexPath: indexPath)
        let cellHeight = ceil(replySizingCell.sizeThatFits(CGSize(width: CGRectGetWidth(tableView.bounds), height: 0)).height)
        
        return cellHeight
    }
    
    func tableView(tableView: UITableView, didSelectRowAtIndexPath indexPath: NSIndexPath) {
        tableView.deselectRowAtIndexPath(indexPath, animated: true)
        
        if let buttonItem = buttonItemForIndexPath(indexPath) {
            delegate?.chatSuggestedRepliesView(self, didTapSRSButtonItem: buttonItem)
        }
    }
}

