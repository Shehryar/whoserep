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
    
    private let secondsBetweenSections: TimeInterval = (4 * 60)
    
    private(set) var allMessages = [ChatMessage]()
    
    private var sections = [[ChatMessage]]()
}

// MARK: - Accessing Content

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
    
    private func getMessages(in section: Int) -> [ChatMessage]? {
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
            
            for (row, currMessage) in messages.enumerated().reversed()
            where currMessage.metadata.eventId == message.metadata.eventId {
                return IndexPath(row: row, section: section)
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
    
    func getLastIndexPath() -> IndexPath? {
        guard !sections.isEmpty else {
            return nil
        }
        
        let section = max(0, sections.count - 1)
        
        guard !sections[section].isEmpty else {
            return nil
        }
        
        let row = max(0, sections[section].count - 1)
        return IndexPath(row: row, section: section)
    }
    
    func isEmpty() -> Bool {
        return getLastMessage() == nil
    }
    
    // MARK: Private
    
    private func getIndex(of message: ChatMessage?) -> Int? {
        guard let message = message else {
            return nil
        }
        
        for (idx, currMessage) in allMessages.enumerated()
        where currMessage.metadata.eventId == message.metadata.eventId {
            return idx
        }
        return nil
    }
}

// MARK: - Changing Content

extension ChatMessagesViewDataSource {
    
    func reloadWithEvents(_ events: [Event]) {
        allMessages.removeAll()
        sections.removeAll()
        
        let sortedEvents = events.sorted { (event1, event2) -> Bool in
            return event1.eventLogSeq < event2.eventLogSeq
        }
        
        for event in sortedEvents {
            if let message = event.chatMessage {
                addMessage(message)
            }
        }
    }
    
    @discardableResult
    func addMessage(_ message: ChatMessage) -> IndexPath? {
        allMessages.append(message)
        
        // Empty case: Insert at beginning
        
        guard let lastMessage = getLastMessage() else {
            sections.append([message])
            return IndexPath(row: 0, section: 0)
        }
     
        // Insert at end
        
        let maxTimeForSameSection = lastMessage.metadata.sendTime.timeIntervalSinceReferenceDate + secondsBetweenSections
     
        if message.metadata.sendTime.timeIntervalSinceReferenceDate < maxTimeForSameSection {
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
        message.metadata.updateSendTime(toMatchMessage: messageToUpdate)

        // Switch out the messages
        allMessages[index] = message
        sections[indexPath.section][indexPath.row] = message
        
        return indexPath
    }
    
    func appendMessages(_ messages: [ChatMessage]) {
        for message in messages {
            addMessage(message)
        }
    }
    
    func insertMessages(_ messages: [ChatMessage]) {
        var sectionsToAdd: [[ChatMessage]] = []
        var newSection: [ChatMessage] = []
        var earliestTime = allMessages.first?.metadata.sendTime.timeIntervalSinceReferenceDate ?? Date().timeIntervalSinceReferenceDate
        
        allMessages.insert(contentsOf: messages, at: 0)
        
        for message in messages.reversed() {
            let earliestTimeForEarliestSection = earliestTime - secondsBetweenSections
            if message.metadata.sendTime.timeIntervalSinceReferenceDate > earliestTimeForEarliestSection {
                newSection.append(message)
            } else {
                sectionsToAdd.append(newSection)
                newSection = []
                newSection.append(message)
            }
            
            earliestTime = message.metadata.sendTime.timeIntervalSinceReferenceDate
        }
        
        if !newSection.isEmpty {
            sectionsToAdd.append(newSection)
            newSection = []
        }
        
        if !sectionsToAdd.isEmpty {
            let addToExistingFirstSection = Array(sectionsToAdd.removeFirst().reversed())
            sections[0].insert(contentsOf: addToExistingFirstSection, at: 0)
        }
        
        for section in sectionsToAdd {
            sections.insert(section.reversed(), at: 0)
        }
    }
}
