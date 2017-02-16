//
//  ChatMessagesViewCellMaster.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/17/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesViewCellMaster: NSObject {

    let supportedEventTypes: Set<EventType> = [.textMessage, .pictureMessage, .srsResponse, .newRep, .conversationEnd]
    
    // MARK: Public Properties

    let tableView: UITableView
    
    let styles: ASAPPStyles
    
    // MARK: Private Properties
    
    fileprivate let dateFormatter = DateFormatter()
    
    fileprivate var cellHeightCache = [Event : CGFloat]()
    
    fileprivate var timeHeaderHeightCache = [Double : CGFloat]()
    
    fileprivate var cachedTypingIndicatorCellHeight: CGFloat?
    
    fileprivate var cachedTableViewWidth: CGFloat = 0.0 {
        didSet {
            if oldValue != cachedTableViewWidth {
                clearCache()
            }
        }
    }
    
    // MARK: Sizing Cells / Views
    
    fileprivate let timeHeaderSizingView = ChatMessagesTimeHeaderView(reuseIdentifier: nil)
    fileprivate let textMessageSizingCell = ChatTextMessageCell(style: .default, reuseIdentifier: nil)
    fileprivate let pictureMessageSizingCell = ChatPictureMessageCell(style: .default, reuseIdentifier: nil)
    fileprivate let typingIndicatorSizingCell = ChatTypingIndicatorCell(style: .default, reuseIdentifier: nil)
    fileprivate let srsItemListViewSizingCell = ChatSRSItemListViewCell(style: .default, reuseIdentifier: nil)
    
    // MARK: Reuse IDs
    
    fileprivate let TimeHeaderViewReuseId = "TimeHeaderViewReuseId"
    
    fileprivate let TextMessageCellReuseId = "TextMessageCellReuseId"
    fileprivate let PictureMessageCellReuseId = "PictureMessageCellReuseId"
    fileprivate let TypingIndicatorCellReuseId = "TypingIndicatorCellReuseId"
    fileprivate let SRSResponseCellReuseId = "SRSResponseCellReuseId"
    
    // MARK: Init
    
    required init(withTableView tableView: UITableView, styles: ASAPPStyles) {
        self.tableView = tableView
        self.styles = styles
        super.init()
        
        pictureMessageSizingCell.disableImageLoading = true
        
        // Register Header
        tableView.register(ChatMessagesTimeHeaderView.self, forHeaderFooterViewReuseIdentifier: TimeHeaderViewReuseId)
        
        // Register Cells
        tableView.register(ChatTextMessageCell.self, forCellReuseIdentifier: TextMessageCellReuseId)
        tableView.register(ChatPictureMessageCell.self, forCellReuseIdentifier: PictureMessageCellReuseId)
        tableView.register(ChatTypingIndicatorCell.self, forCellReuseIdentifier: TypingIndicatorCellReuseId)
        tableView.register(ChatSRSItemListViewCell.self, forCellReuseIdentifier: SRSResponseCellReuseId)
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
    
    private func styleTimeHeaderView(_ view: ChatMessagesTimeHeaderView?, withTime timeStamp: Double) {
        view?.applyStyles(styles)
        view?.timeStampInSeconds = timeStamp
    }
    
    func timeStampHeaderView(withTimeStamp timeStamp: Double) -> UIView? {
        let headerView = tableView.dequeueReusableHeaderFooterView(withIdentifier: TimeHeaderViewReuseId) as? ChatMessagesTimeHeaderView
        styleTimeHeaderView(headerView, withTime: timeStamp)
        return headerView
    }
    
    func heightForTimeStampHeaderView(withTimeStamp timeStamp: Double?) -> CGFloat {
        guard let timeStamp = timeStamp else { return 0.0 }
        
        cachedTableViewWidth = tableView.bounds.width
        if let cachedHeight = timeHeaderHeightCache[timeStamp] {
            return cachedHeight
        }
        
        styleTimeHeaderView(timeHeaderSizingView, withTime: timeStamp)
        
        let height = heightForStyledView(timeHeaderSizingView, width: cachedTableViewWidth)
        timeHeaderHeightCache[timeStamp] = height
        
        return height
    }
}

// MARK:- Cell Creation

extension ChatMessagesViewCellMaster {

    private func getCell(with identifier: String, at indexPath: IndexPath) -> UITableViewCell {
        return tableView.dequeueReusableCell(withIdentifier: identifier, for: indexPath)
    }
    
    func typingIndicatorCell(forIndexPath indexPath: IndexPath) -> UITableViewCell? {
        let cell = getCell(with: TypingIndicatorCellReuseId, at: indexPath) as? ChatTypingIndicatorCell
        styleTypingIndicatorCell(cell)
        return cell
    }
    
    func cellForEvent(_ event: Event, isReply: Bool, listPosition: MessageListPosition, detailsVisible: Bool, atIndexPath indexPath: IndexPath) -> UITableViewCell? {
        
        // Picture Message
        if event.eventType == .pictureMessage {
            let cell = getCell(with: PictureMessageCellReuseId, at: indexPath) as? ChatPictureMessageCell
            stylePictureMessageCell(cell, withEvent: event, isReply: isReply, listPosition: listPosition)
            return cell
        }
        
        // Text Message
        if event.eventType == .textMessage {
            let cell = getCell(with: TextMessageCellReuseId, at: indexPath) as? ChatTextMessageCell
            styleTextMessageCell(cell, withEvent: event, isReply: isReply, listPosition: listPosition, detailsVisible: detailsVisible)
            return cell
        }
        
        // SRS Response
        if [EventType.srsResponse, EventType.newRep, EventType.conversationEnd].contains(event.eventType) {
            let cell = getCell(with: SRSResponseCellReuseId, at: indexPath) as? ChatSRSItemListViewCell
            styleSRSItemListCell(cell, withEvent: event, isReply: isReply, listPosition: listPosition, detailsVisible: detailsVisible)
            return cell
        }
        
        return nil
    }
}

// MARK:- Cell Styling

extension ChatMessagesViewCellMaster {
    
    func styleTextMessageCell(_ cell: ChatTextMessageCell?,
                              withEvent event: Event,
                              isReply: Bool,
                              listPosition: MessageListPosition,
                              detailsVisible: Bool) {
        cell?.applyStyles(styles, isReply: isReply)
        cell?.listPosition = listPosition
        cell?.event = event
        cell?.messageText = event.textMessage?.text
        cell?.detailLabelHidden = !detailsVisible
    }
    
    func stylePictureMessageCell(_ cell: ChatPictureMessageCell?,
                                 withEvent event: Event,
                                 isReply: Bool,
                                 listPosition: MessageListPosition) {
        cell?.applyStyles(styles, isReply: isReply)
        cell?.listPosition = listPosition
        cell?.event = event
        cell?.detailLabelHidden = true
    }
    
    func styleSRSItemListCell(_ cell: ChatSRSItemListViewCell?,
                              withEvent event: Event,
                              isReply: Bool,
                              listPosition: MessageListPosition,
                              detailsVisible: Bool) {
        cell?.applyStyles(styles, isReply: isReply)
        cell?.listPosition = listPosition
        cell?.event = event
        cell?.response = event.srsResponse
        cell?.detailLabelHidden = !detailsVisible
    }
    
    func styleTypingIndicatorCell(_ cell: ChatTypingIndicatorCell?) {
        cell?.applyStyles(styles, isReply: true)
        cell?.listPosition = .default
    }
}

// MARK:- Cell Heights

extension ChatMessagesViewCellMaster {
    
    func heightForTypingIndicatorCell() -> CGFloat {
        if let cachedHeight = cachedTypingIndicatorCellHeight {
            return cachedHeight
        }

        cachedTableViewWidth = tableView.bounds.width
        styleTypingIndicatorCell(typingIndicatorSizingCell)
        cachedTypingIndicatorCellHeight = heightForStyledView(typingIndicatorSizingCell, width: cachedTableViewWidth)
        
        return cachedTypingIndicatorCellHeight ?? 0.0
    }
    
    func heightForCellWithEvent(_ event: Event?, isReply: Bool, listPosition: MessageListPosition, detailsVisible: Bool) -> CGFloat {
        guard let event = event else { return 0.0 }
        
        let canCacheHeight = !detailsVisible
        
        cachedTableViewWidth = tableView.bounds.width
        
        if canCacheHeight {
            if let cachedHeight = cellHeightCache[event] {
                return cachedHeight
            }
        }
        
        // Calculate height
        let height: CGFloat = calculateHeightForCellWithEvent(event,
                                                              isReply: isReply,
                                                              listPosition: listPosition,
                                                              detailsVisible: detailsVisible,
                                                              width: cachedTableViewWidth)
        if canCacheHeight {
            cellHeightCache[event] = height
        }
                
        return height
    }
    
    fileprivate func calculateHeightForCellWithEvent(_ event: Event,
                                                 isReply: Bool,
                                                 listPosition: MessageListPosition,
                                                 detailsVisible: Bool,
                                                 width: CGFloat) -> CGFloat {
        
        // Picture Message
        if event.eventType == .pictureMessage {
            stylePictureMessageCell(pictureMessageSizingCell,
                                    withEvent: event,
                                    isReply: isReply,
                                    listPosition: listPosition)
            return heightForStyledView(pictureMessageSizingCell, width: width)
        }
        
        // Text Message
        if event.eventType == .textMessage {
            styleTextMessageCell(textMessageSizingCell,
                                 withEvent: event,
                                 isReply: isReply,
                                 listPosition: listPosition,
                                 detailsVisible: detailsVisible)
            return heightForStyledView(textMessageSizingCell, width: width)
        }
        
        // SRS Response
        if [EventType.srsResponse, EventType.newRep, EventType.conversationEnd].contains(event.eventType) {
            if let srsResponse = event.srsResponse {
                styleSRSItemListCell(srsItemListViewSizingCell,
                                     withEvent: event,
                                     isReply: isReply,
                                     listPosition: listPosition,
                                     detailsVisible: detailsVisible)
                return heightForStyledView(srsItemListViewSizingCell, width: width)
            }
        }
        
        return 0.0
    }
    
    fileprivate func heightForStyledView(_ view: UIView, width: CGFloat) -> CGFloat {
        guard width > 0 else { return 0.0 }
        
        return ceil(view.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height)
    }
}
