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
    
    var transparentInsetTop: CGFloat {
        return closeButtonSize / 2.0 - separatorTopStroke / 2.0
    }
    
    private var buttonItems: [SRSButtonItem]? {
        didSet {
            tableView.reloadData()
            tableView.setContentOffset(CGPoint.zero, animated: false)
        }
    }
    
    var delegate: ChatSuggestedRepliesViewDelegate?
    
    // MARK: Private Properties
    
    private let closeButtonSize: CGFloat = 46.0
    
    private let separatorTopStroke: CGFloat = 2.0
    
    private let closeButton = Button()
    
    private let separatorTopView = UIView()
    
    private let patternBackgroundView = UIView()
    
    private let patternView = UIView()
    
    private let tableView = UITableView(frame: CGRectZero, style: .Plain)
    
    private let CellReuseId = "CellReuseId"
    
    private let replySizingCell = ChatSuggestedReplyCell()
    
    // MARK: Initialization
    
    func commonInit() {
        patternBackgroundView.addSubview(patternView)
        addSubview(patternBackgroundView)
        
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
        
        addSubview(separatorTopView)
        
        closeButton.image = Images.iconSmallX()
        closeButton.imageSize = CGSize(width: 11, height: 11)
        closeButton.foregroundColor = Colors.mediumTextColor()
        closeButton.onTap = { [weak self] in
            if let blockSelf = self {
                blockSelf.delegate?.chatSuggestedRepliesViewDidCancel(blockSelf)
            }
        }
        addSubview(closeButton)
        
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
        
        closeButton.setForegroundColor(styles.foregroundColor1, forState: .Normal)
        closeButton.setForegroundColor(styles.foregroundColor1.highlightColor(), forState: .Normal)
        closeButton.setBackgroundColor(styles.backgroundColor1, forState: .Normal)
        closeButton.setBackgroundColor(styles.backgroundColor2, forState: .Highlighted)
        closeButton.layer.borderColor = styles.separatorColor1.CGColor
        closeButton.layer.borderWidth = 2
        closeButton.clipsToBounds = true
        
        separatorTopView.backgroundColor = styles.separatorColor1
        
        patternBackgroundView.backgroundColor = styles.backgroundColor2
        patternView.backgroundColor = Colors.patternBackgroundColor()
    
        tableView.reloadData()
    }
}

// MARK:- Layout

extension ChatSuggestedRepliesView {
    override func layoutSubviews() {
        super.layoutSubviews()
        
        let closeButtonLeft = CGRectGetWidth(bounds) - closeButtonSize - 15
        closeButton.frame = CGRect(x: closeButtonLeft, y: 0.0, width: closeButtonSize, height: closeButtonSize)
        closeButton.layer.cornerRadius = closeButtonSize / 2.0
        
        let separatorTop = closeButton.center.y - separatorTopStroke / 2.0
        separatorTopView.frame = CGRect(x: 0.0, y: separatorTop, width: CGRectGetWidth(bounds), height: separatorTopStroke)
        
        let tableViewTop = CGRectGetMaxY(separatorTopView.frame)
        let tableViewHeight = CGRectGetHeight(bounds) - tableViewTop
        tableView.frame = CGRect(x: 0.0, y: tableViewTop, width: CGRectGetWidth(bounds), height: tableViewHeight)
        patternBackgroundView.frame = tableView.frame
        patternView.frame = patternBackgroundView.bounds
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
        cell.backgroundColor = styles.backgroundColor2
        cell.selectedBackgroundColor = styles.backgroundColor2.highlightColor()
        cell.separatorBottomColor = styles.separatorColor1
        cell.textLabel?.text = buttonItemForIndexPath(indexPath)?.title.uppercaseString
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

