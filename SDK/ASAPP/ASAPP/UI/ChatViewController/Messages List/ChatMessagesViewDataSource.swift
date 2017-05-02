//
//  ChatMessagesViewDataSource.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ChatMessagesViewDataSource: NSObject {

    // MARK: Properties
    
    fileprivate let secondsBetweenSections: TimeInterval = (4 * 60)
    
    fileprivate(set) var allMessages = [ChatMessage]()
    
    fileprivate var sections = [[ChatMessage]]()
}

// MARK:- Accessing Content

extension ChatMessagesViewDataSource {
    
    func numberOfSections() -> Int {
        return sections.count
    }
    
    func numberOfRowsInSection(_ section: Int) -> Int {
        guard section >= 0 && section < sections.count else {
            return 0
        }
        return sections[section].count
    }
    
    func getMessages(in section: Int) -> [ChatMessage]? {
        guard section >= 0 && section < sections.count else {
            return nil
        }
        return sections[section]
    }
    
    func getMessage(in section: Int, at row: Int) -> ChatMessage? {
        if let messagesInSection = getMessages(in: section) {
            if row >= 0 && row < messagesInSection.count {
                return messagesInSection[row]
            }
        }
        return nil
    }
    
    func getMessage(for indexPath: IndexPath) -> ChatMessage? {
        return getMessage(in: indexPath.section, at: indexPath.row)
    }
    
    func getIndexPath(of message: ChatMessage?) -> IndexPath? {
        guard let message = message else {
            return nil
        }
        
        for (section, messages) in sections.enumerated().reversed() {
            
            // Could skip over arrays here if the message happened before the first message's time
            
            for (row, currMessage) in messages.enumerated().reversed() {
                
                if currMessage.metadata.eventId == message.metadata.eventId {
                    return IndexPath(row: row, section: section)
                }
            }
        }
        return nil
    }
    
    func getHeaderTime(for section: Int) -> Date? {
        guard let message = getMessage(in: section, at: 0) else {
            return nil
        }
        return message.metadata.sendTime
    }
    
    func getLastMessage() -> ChatMessage? {
        return sections.last?.last
    }
    
    func isEmpty() -> Bool {
        return getLastMessage() == nil
    }
    
    // MARK: Private
    
    fileprivate func getIndex(of message: ChatMessage?) -> Int? {
        guard let message = message else {
            return nil
        }
        
        for (idx, currMessage) in allMessages.enumerated() {
            if currMessage.metadata.eventId == message.metadata.eventId {
                return idx
            }
        }
        return nil
    }
}

// MARK:- Changing Content

extension ChatMessagesViewDataSource {
    
    func reloadWithEvents(_ events: [Event]) {
        allMessages.removeAll()
        sections.removeAll()
        
        let sortedEvents = events.sorted { (event1, event2) -> Bool in
            return event1.eventLogSeq < event2.eventLogSeq
        }
        for event in sortedEvents {
            if let message = event.chatMessage {
                _ = addMessage(message)
            }
        }
    }
    
    func addMessage(_ message: ChatMessage) -> IndexPath? {
        allMessages.append(message)
        
        // Empty case: Insert at beginning
        
        guard let lastMessage = getLastMessage() else {
            sections.append([message])
            return IndexPath(row: 0, section: 0)
        }
     
        // Insert at end
        
        let maxTimeForSameSection = lastMessage.sendTime.timeIntervalSinceReferenceDate + secondsBetweenSections
     
        if message.sendTime.timeIntervalSinceReferenceDate < maxTimeForSameSection {
            sections[sections.count - 1].append(message)
        } else {
            sections.append([message])
        }
        
        return getIndexPath(of: message)
    }
    
    func updateMessage(_ message: ChatMessage) -> IndexPath? {
        guard let index = getIndex(of: message),
            let indexPath = getIndexPath(of: message) else {
                DebugLog.w(caller: self, "Unable to locate message for updating.")
                return nil
        }

        // Update the updatedMessage's times to the original times
        let messageToUpdate = allMessages[index]
        message.metadata.updateSendTime(toMatch: messageToUpdate)

        // Switch out the messages
        allMessages[index] = message
        sections[indexPath.section][indexPath.row] = message
        
        return indexPath
    }
}
