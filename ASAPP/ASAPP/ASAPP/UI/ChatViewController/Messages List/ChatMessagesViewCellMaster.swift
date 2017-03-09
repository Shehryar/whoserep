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
    
    enum MessageCellType: String {
        case none = "none"
        case itemList = "itemList"
        case itemCarousel = "itemCarousel"
        case picture = "picture"
        case text = "text"
        
        static let allValidTypes = [
            itemList,
            itemCarousel,
            picture,
            text
        ]
        
        static func forEvent(_ event: Event?) -> MessageCellType {
            guard let event = event else {
                return none
            }
            
            if event.srsResponse?.itemList != nil {
                return itemList
            } else if event.eventType == .textMessage {
                return text
            } else if event.eventType == .pictureMessage {
                return picture
            } else if event.srsResponse?.itemCarousel != nil {
                return itemCarousel
            }
            
            return none
        }
        
        func getCellClass() -> AnyClass? {
            switch self {
            case .text: return ChatMessageCell.self
            case .itemList: return ChatItemListMessageCell.self
            case .itemCarousel: return ChatItemCarouselMessageCell.self
            case .picture: return ChatPictureMessageCell.self
            case .none: return nil
            }
        }
    }
    
    
    // MARK: Public Properties

    let tableView: UITableView
    
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
    fileprivate let textMessageSizingCell = ChatMessageCell(style: .default, reuseIdentifier: nil)
    fileprivate let pictureMessageSizingCell = ChatPictureMessageCell(style: .default, reuseIdentifier: nil)
    fileprivate let typingIndicatorSizingCell = ChatTypingIndicatorCell(style: .default, reuseIdentifier: nil)
    fileprivate let itemListViewSizingCell = ChatItemListMessageCell(style: .default, reuseIdentifier: nil)
    fileprivate let itemCarouselViewSizingCell = ChatItemCarouselMessageCell(style: .default, reuseIdentifier: nil)
    
    // MARK: Reuse IDs
    
    fileprivate let TimeHeaderViewReuseId = "TimeHeaderViewReuseId"
    fileprivate let TypingIndicatorCellReuseId = "TypingIndicatorCellReuseId"
    
    // MARK: Init
    
    required init(withTableView tableView: UITableView) {
        self.tableView = tableView
        super.init()
        
        pictureMessageSizingCell.pictureView.disableImageLoading = true
        
        // Register Header & Non-Message Cells
        tableView.register(ChatMessagesTimeHeaderView.self, forHeaderFooterViewReuseIdentifier: TimeHeaderViewReuseId)
        tableView.register(ChatTypingIndicatorCell.self, forCellReuseIdentifier: TypingIndicatorCellReuseId)
        
        // Register Message Cells
        for cellType in MessageCellType.allValidTypes {
            tableView.register(cellType.getCellClass(), forCellReuseIdentifier: cellType.rawValue)
        }
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
        return getCell(with: TypingIndicatorCellReuseId, at: indexPath) as? ChatTypingIndicatorCell
    }
    
    func cellForEvent(_ event: Event,
                      isReply: Bool,
                      listPosition: MessageListPosition,
                      detailsVisible: Bool,
                      atIndexPath indexPath: IndexPath) -> UITableViewCell? {
        let cellType = MessageCellType.forEvent(event)
        guard cellType != .none else {
            return nil
        }
        
        if let cell = getCell(with: cellType.rawValue, at: indexPath) as? ChatMessageCell {
            styleMessageCell(cell, withEvent: event, isReply: isReply, listPosition: listPosition, detailsVisible: detailsVisible)
            return cell
        }
        return nil
    }
}

// MARK:- Cell Styling

extension ChatMessagesViewCellMaster {
    
    func styleMessageCell(_ cell: ChatMessageCell?,
                          withEvent event: Event,
                          isReply: Bool,
                          listPosition: MessageListPosition,
                          detailsVisible: Bool) {
        cell?.messagePosition = listPosition
        cell?.event = event
        cell?.isReply = isReply
        cell?.isTimeLabelVisible = detailsVisible
    }
}

// MARK:- Cell Heights

extension ChatMessagesViewCellMaster {
    
    func heightForTypingIndicatorCell() -> CGFloat {
        if let cachedHeight = cachedTypingIndicatorCellHeight {
            return cachedHeight
        }

        cachedTableViewWidth = tableView.bounds.width
        cachedTypingIndicatorCellHeight = heightForStyledView(typingIndicatorSizingCell, width: cachedTableViewWidth)
        
        return cachedTypingIndicatorCellHeight ?? 0.0
    }
    
    func heightForCellWithEvent(_ event: Event?, isReply: Bool, listPosition: MessageListPosition, detailsVisible: Bool) -> CGFloat {
        guard let event = event else { return 0.0 }
        
        let canCacheHeight = !detailsVisible
        
        cachedTableViewWidth = tableView.bounds.width
        
//        if canCacheHeight {
//            if let cachedHeight = cellHeightCache[event] {
//                return cachedHeight
//            }
//        }
        
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
    
    private func getMessageSizingCellForEvent(_ event: Event) -> ChatMessageCell? {
        switch MessageCellType.forEvent(event) {
        case .itemList: return itemListViewSizingCell
        case .itemCarousel: return itemCarouselViewSizingCell
        case .picture: return pictureMessageSizingCell
        case .text: return textMessageSizingCell
        case .none: return nil
        }
    }
    
    fileprivate func calculateHeightForCellWithEvent(_ event: Event,
                                                     isReply: Bool,
                                                     listPosition: MessageListPosition,
                                                     detailsVisible: Bool,
                                                     width: CGFloat) -> CGFloat {
        if let sizingCell = getMessageSizingCellForEvent(event) {
            styleMessageCell(sizingCell, withEvent: event, isReply: isReply, listPosition: listPosition, detailsVisible: detailsVisible)
            return heightForStyledView(sizingCell, width: width)
        }
        return 0.0
    }
    
    fileprivate func heightForStyledView(_ view: UIView, width: CGFloat) -> CGFloat {
        guard width > 0 else { return 0.0 }
        
        return ceil(view.sizeThatFits(CGSize(width: width, height: CGFloat.greatestFiniteMagnitude)).height)
    }
}
