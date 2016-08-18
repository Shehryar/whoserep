//
//  ChatMessagesViewCellMaster.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/17/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesViewCellMaster: NSObject, ASAPPStyleable {

    // MARK: Public Properties

    let tableView: UITableView
    
    // MARK: Private Properties
    
    private var cellHeightCache = [Event : CGFloat]()
    
    private var timeHeaderHeightCache = [Double : CGFloat]()
    
    private var cachedTypingIndicatorCellHeight: CGFloat?
    
    private var cachedTableViewWidth: CGFloat = 0.0 {
        didSet {
            if oldValue != cachedTableViewWidth {
                clearCache()
            }
        }
    }
    
    // MARK: Sizing Cells / Views
    
    private let timeHeaderSizingView = ChatMessagesTimeHeaderView()
    private let textMessageSizingCell = ChatTextMessageCell()
    private let pictureMessageSizingCell = ChatPictureMessageCell()
    private let typingIndicatorSizingCell = ChatTypingIndicatorCell()
    private let typingPreviewSizingCell = ChatTypingPreviewCell()
    private let infoTextSizingCell = ChatInfoTextCell()
    
    // MARK: Reuse IDs
    
    private let TimeHeaderViewReuseId = "TimeHeaderViewReuseId"
    
    private let TextMessageCellReuseId = "TextMessageCellReuseId"
    private let PictureMessageCellReuseId = "PictureMessageCellReuseId"
    private let TypingIndicatorCellReuseId = "TypingIndicatorCellReuseId"
    private let TypingPreviewCellReuseId = "TypingPreviewCellReuseId"
    private let InfoTextCellReuseId = "InfoTextCellReuseId"
    
    // MARK: Init
    
    required init(withTableView tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        pictureMessageSizingCell.disableImageLoading = true
        
        // Register Header
        tableView.registerClass(ChatMessagesTimeHeaderView.self, forHeaderFooterViewReuseIdentifier: TimeHeaderViewReuseId)
        
        // Register Cells
        tableView.registerClass(ChatTextMessageCell.self, forCellReuseIdentifier: TextMessageCellReuseId)
        tableView.registerClass(ChatPictureMessageCell.self, forCellReuseIdentifier: PictureMessageCellReuseId)
        tableView.registerClass(ChatTypingIndicatorCell.self, forCellReuseIdentifier: TypingIndicatorCellReuseId)
        tableView.registerClass(ChatTypingPreviewCell.self, forCellReuseIdentifier: TypingPreviewCellReuseId)
        tableView.registerClass(ChatInfoTextCell.self, forCellReuseIdentifier: InfoTextCellReuseId)
    }
    
    // MARK: ASAPPStyleable
    
    private(set) var styles = ASAPPStyles()
    
    func applyStyles(styles: ASAPPStyles) {
        self.styles = styles
        clearCache()
    }
}

// MARK:- Private Methods

extension ChatMessagesViewCellMaster {
    
    func clearCache() {
        cellHeightCache.removeAll()
        timeHeaderHeightCache.removeAll()
        cachedTypingIndicatorCellHeight = nil
    }
}

// MARK:- Header/Footer

extension ChatMessagesViewCellMaster {
    
    func timeStampHeaderView(withTimeStamp timeStamp: Double) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterViewWithIdentifier(TimeHeaderViewReuseId) as? ChatMessagesTimeHeaderView
        headerView?.applyStyles(styles)
        headerView?.timeStampInSeconds = timeStamp
        return headerView
    }
    
    func heightForTimeStampHeaderView(withTimeStamp timeStamp: Double?) -> CGFloat {
        guard let timeStamp = timeStamp else { return 0.0 }
        
        cachedTableViewWidth = CGRectGetWidth(tableView.bounds)
        
        if let cachedHeight = timeHeaderHeightCache[timeStamp] {
            return cachedHeight
        }
        
        timeHeaderSizingView.applyStyles(styles)
        timeHeaderSizingView.timeStampInSeconds = timeStamp
        
        let height = heightForStyledView(timeHeaderSizingView, width: cachedTableViewWidth)
        timeHeaderHeightCache[timeStamp] = height
        
        return height
    }
}

// MARK:- Cell Creation

extension ChatMessagesViewCellMaster {

    func typingIndicatorCell(forIndexPath indexPath: NSIndexPath) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier(TypingIndicatorCellReuseId) as? ChatTypingIndicatorCell
        cell?.applyStyles(styles, isReply: true)
        cell?.listPosition = .Default
        return cell ?? UITableViewCell()
    }
    
    func typingPreviewCell(forIndexPath indexPath: NSIndexPath, withText text: String?) -> UITableViewCell? {
        let cell = tableView.dequeueReusableCellWithIdentifier(TypingPreviewCellReuseId) as? ChatTypingPreviewCell
        cell?.messageText = text
        cell?.applyStyles(styles, isReply: true)
        return cell
    }
    
    func cellForEvent(event: Event, isReply: Bool, listPosition: MessageListPosition, atIndexPath: NSIndexPath) -> UITableViewCell? {
        
        // Picture Message
        if event.eventType == .PictureMessage {
            let cell = tableView.dequeueReusableCellWithIdentifier(PictureMessageCellReuseId) as? ChatPictureMessageCell
            cell?.applyStyles(styles, isReply: isReply)
            cell?.listPosition = listPosition
            cell?.event = event
            return cell
        }
        
        // Text Message
        if event.eventType == .TextMessage {
            let cell = tableView.dequeueReusableCellWithIdentifier(TextMessageCellReuseId) as? ChatTextMessageCell
            cell?.applyStyles(styles, isReply: isReply)
            cell?.listPosition = listPosition
            cell?.messageText = event.textMessage?.text
            return cell
        }
        
        // Actionable Message (same UI as Text Message)
        if event.eventType == .ActionableMessage {
            let cell = tableView.dequeueReusableCellWithIdentifier(TextMessageCellReuseId) as? ChatTextMessageCell
            cell?.applyStyles(styles, isReply: isReply)
            cell?.listPosition = listPosition
            cell?.messageText = event.actionableMessage?.message
            return cell
        }
        
        // Info Cell
        if [EventType.CRMCustomerLinked, EventType.NewIssue, EventType.NewRep].contains(event.eventType) {
            let cell = tableView.dequeueReusableCellWithIdentifier(InfoTextCellReuseId) as? ChatInfoTextCell
            cell?.applyStyles(styles)
            
            // TODO: Localization
            
            switch event.eventType {
            case .CRMCustomerLinked:
                cell?.infoText = "Customer Linked"
                break
                
            case .NewIssue:
                cell?.infoText = "New Issue: \(event.newIssue?.issueId ?? 0)"
                break
                
            case .NewRep:
                cell?.infoText = "New Rep: \(event.newRep?.name ?? String(event.newRep?.repId))"
                break
                
            default:  // Other cases not handled
                break
            }
            
            return cell ?? UITableViewCell()
        }

        
        return nil
    }
}

// MARK:- Cell Heights

extension ChatMessagesViewCellMaster {
    
    func heightForTypingIndicatorCell() -> CGFloat {
        if let cachedHeight = cachedTypingIndicatorCellHeight {
            return cachedHeight
        }

        typingIndicatorSizingCell.applyStyles(styles, isReply: true)
        cachedTableViewWidth = CGRectGetWidth(tableView.bounds)
        cachedTypingIndicatorCellHeight = heightForStyledView(typingIndicatorSizingCell, width: cachedTableViewWidth)
        
        return cachedTypingIndicatorCellHeight ?? 0.0
    }
    
    func heightForTypingPreviewCell(withText text: String?) -> CGFloat {
        typingPreviewSizingCell.applyStyles(styles, isReply: true)
        typingPreviewSizingCell.messageText = text
        
        return heightForStyledView(typingPreviewSizingCell, width: CGRectGetWidth(tableView.bounds))
    }
    
    func heightForCellWithEvent(event: Event?, isReply: Bool, listPosition: MessageListPosition) -> CGFloat {
        guard let event = event else { return 0.0 }
        
        cachedTableViewWidth = CGRectGetWidth(tableView.bounds)
        
        if let cachedHeight = cellHeightCache[event] {
//            print("Cached Height: \(cachedHeight)")
            return cachedHeight
        }
        
        // Calculate height
        let height: CGFloat = calculateHeightForCellWithEvent(event,
                                                              isReply: isReply,
                                                              listPosition: listPosition,
                                                              width: cachedTableViewWidth)
        cellHeightCache[event] = height
//        print("Calculated Height: \(height)")
        
        return height
    }
    
    private func calculateHeightForCellWithEvent(event: Event,
                                                 isReply: Bool,
                                                 listPosition: MessageListPosition,
                                                 width: CGFloat) -> CGFloat {
        
        // Picture Message
        if event.eventType == .PictureMessage {
            pictureMessageSizingCell.applyStyles(styles, isReply: isReply)
            pictureMessageSizingCell.listPosition = listPosition
            pictureMessageSizingCell.event = event
            return heightForStyledView(pictureMessageSizingCell, width: width)
        }
        
        // Text Message
        if event.eventType == .TextMessage {
            textMessageSizingCell.applyStyles(styles, isReply: isReply)
            textMessageSizingCell.listPosition = listPosition
            textMessageSizingCell.messageText = event.textMessage?.text
            return heightForStyledView(textMessageSizingCell, width: width)
        }
        
        // Actionable Message (same UI as Text Message)
        if event.eventType == .ActionableMessage {
            textMessageSizingCell.applyStyles(styles, isReply: isReply)
            textMessageSizingCell.listPosition = listPosition
            textMessageSizingCell.messageText = event.actionableMessage?.message
            return heightForStyledView(textMessageSizingCell, width: width)
        }
        
        // Info Cell
        if [EventType.CRMCustomerLinked, EventType.NewIssue, EventType.NewRep].contains(event.eventType) {
            infoTextSizingCell.applyStyles(styles)
            
            // TODO: Localization
            
            switch event.eventType {
            case .CRMCustomerLinked:
                infoTextSizingCell.infoText = "Customer Linked"
                break
                
            case .NewIssue:
                infoTextSizingCell.infoText = "New Issue: \(event.newIssue?.issueId ?? 0)"
                break
                
            case .NewRep:
                infoTextSizingCell.infoText = "New Rep: \(event.newRep?.name ?? String(event.newRep?.repId))"
                break
                
            default:  // Other cases not handled
                break
            }
            
            return heightForStyledView(infoTextSizingCell, width: width)
        }
        
        return 0.0
    }
    
    private func heightForStyledView(view: UIView, width: CGFloat) -> CGFloat {
        guard width > 0 else { return 0.0 }
        
        return ceil(view.sizeThatFits(CGSize(width: width, height: CGFloat.max)).height)
    }
}
