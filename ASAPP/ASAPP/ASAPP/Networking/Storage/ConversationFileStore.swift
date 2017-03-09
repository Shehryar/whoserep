//
//  ConversationFileStore.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/21/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class ConversationFileStore: NSObject {
    
    let credentials: Credentials
    
    fileprivate let fileName: String
    
    fileprivate var filePath: URL?
    
    fileprivate let maxWriteQueueSize = 50
    
    fileprivate var writeQueue = [String]()
    
    fileprivate var needsWriteToFile = false
    
    fileprivate let debugLoggingEnabled = false
    
    // MARK: Init
    
    required init(credentials: Credentials) {
        self.credentials = credentials
        self.fileName = "\(credentials.hashKey(withPrefix: "Stored-Events_")).txt"
        super.init()
        
        if let dir = NSSearchPathForDirectoriesInDomains(FileManager.SearchPathDirectory.documentDirectory, FileManager.SearchPathDomainMask.allDomainsMask, true).first {
            filePath = NSURL(fileURLWithPath: dir).appendingPathComponent(fileName)
            
            if filePath == nil {
                DebugLogError("Unable to create filePath for ConversationFileStore")
            }
        }
        
        NotificationCenter.default.addObserver(self, selector: #selector(didObserveNotification), name: Notification.Name.UIApplicationWillResignActive, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didObserveNotification), name: Notification.Name.UIApplicationWillTerminate, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didObserveNotification), name: Notification.Name.UIApplicationDidEnterBackground, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(didObserveNotification), name: Notification.Name.UIApplicationDidReceiveMemoryWarning, object: nil)
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
    
    // MARK:- Observing Notifications
    
    func didObserveNotification() {
        save()
    }
    
    // MARK:- Debug Logging
    
    fileprivate func _debugLog(message: String) {
        if debugLoggingEnabled {
            DebugLog(message)
        }
    }
}

// MARK:- Generic File Operations

extension ConversationFileStore {
    
    // MARK: Reading
    
    fileprivate func readStringFromFile() -> String? {
        guard let filePath = filePath else { return nil }

        if let stringOnFile = try? String(contentsOf: filePath, encoding: String.Encoding.utf8) {
            _debugLog(message: "Successfully read string from filePath: \(filePath)")
            return stringOnFile
        } else {
            _debugLog(message: "Unable to read string from filePath: \(filePath)")
        }
        
        return nil
    }
    
    // MARK: Writing
    
    fileprivate func writeStringToFile(stringToWrite: String) -> Bool {
        guard let filePath = filePath else { return false }
        
        var successfullyWroteToDisk = false
        
        if let stringData = stringToWrite.data(using: String.Encoding.utf8) {
            do {
                try stringData.write(to: filePath, options: [Data.WritingOptions.completeFileProtection, Data.WritingOptions.atomic])
                
                successfullyWroteToDisk = true
            } catch _ {
                _debugLog(message: "Unable to write string to filePath: \(filePath)")
            }
        } else {
            _debugLog(message: "Unable to generate data from string: \(stringToWrite)")
        }
        
        return successfullyWroteToDisk
    }
}

// MARK:- Utility Methods

extension ConversationFileStore {
    
    fileprivate func stringForJSONObject(jsonObject: [String : AnyObject]) -> String? {
        if let jsonData = try? JSONSerialization.data(withJSONObject: jsonObject, options: JSONSerialization.WritingOptions.prettyPrinted) {
            if let jsonString = String(data: jsonData, encoding: String.Encoding.utf8) {
                return jsonString
            }
        }
        return nil
    }
    
    fileprivate func trimWriteQueueIfNecessary() {
        guard writeQueue.count > maxWriteQueueSize else {
            return
        }
        
        let mostRecentItems = Array(writeQueue.suffix(maxWriteQueueSize))
    
        _debugLog(message: "Trimmed writeQueue from \(writeQueue.count) down to \(mostRecentItems.count)")
        
        writeQueue = mostRecentItems
    }
}

// MARK:- Fetching Events 

extension ConversationFileStore {
    
    private func getStoredEventsJSONArray() -> [[String : AnyObject]]? {
        if let stringOnFile = readStringFromFile() {
            
            let storedEventsJSONString = "[\(stringOnFile)]"
            
            if let data = storedEventsJSONString.data(using: String.Encoding.utf8) {
                if let storedEventsArray = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [[String : AnyObject]] {
                    return storedEventsArray
                } else {
                    _debugLog(message: "Unable to serialize array from events json string:\n\(storedEventsJSONString)")
                }
            } else {
                _debugLog(message: "Unable to create data from events json string:\n\(storedEventsJSONString)")
            }
        }
        
        return nil
    }
    
    func getSavedEvents() -> [Event]? {
        if let storedJSONArray = getStoredEventsJSONArray() {
            
            var events = [Event]()
            for eventJSON in storedJSONArray {
                if let event = Event.fromJSON(eventJSON) {
                    events.append(event)
                }
            }
            _debugLog(message: "Successfully fetched \(events.count) events from file store")
            
            return events
        }
        
        _debugLog(message: "No events fetched from file store")
        
        return nil
    }
    
    func getSavedEventsWithCompletion(completion: @escaping (([Event]?) -> Void)) {
        Dispatcher.performOnBackgroundThread {
            let events = self.getSavedEvents()
            
            Dispatcher.performOnMainThread {
                completion(events)
            }
        }
    }
}

// MARK:- Adding Events

extension ConversationFileStore {
    
    // MARK: Private
    
    private func addEventJSONSynchronous(eventJSON: [String : AnyObject]) {
        if let eventJSONString = stringForJSONObject(jsonObject: eventJSON) {
            addEventJSONStringSynchronous(eventJSONString: eventJSONString)
        }
    }
    
    private func addEventJSONStringSynchronous(eventJSONString: String) {
        writeQueue.append(eventJSONString)
        needsWriteToFile = true
    }
    
    private func replaceEventsWithJSONArraySynchronous(eventsJSONArray: [[String : AnyObject]]) {
        writeQueue.removeAll()
        
        for eventJSON in eventsJSONArray {
            if let eventJSONString = stringForJSONObject(jsonObject: eventJSON) {
                writeQueue.append(eventJSONString)
            }
        }
        trimWriteQueueIfNecessary()
        needsWriteToFile = true
    }
    
    // MARK: Public
    
    func addEventJSON(eventJSON: [String : AnyObject]?) {
        guard let eventJSON = eventJSON else { return }
        
        Dispatcher.performOnBackgroundThread {
            self.addEventJSONSynchronous(eventJSON: eventJSON)
        }
    }
    
    func addEventJSONString(eventJSONString: String?) {
        guard let eventJSONString = eventJSONString else { return }
        
        Dispatcher.performOnBackgroundThread {
            self.addEventJSONStringSynchronous(eventJSONString: eventJSONString)
        }
    }
    
    func replaceEventsWithJSONArray(eventsJSONArray: [[String : AnyObject]]) {
        Dispatcher.performOnBackgroundThread {
            self.replaceEventsWithJSONArraySynchronous(eventsJSONArray: eventsJSONArray)
        }
    }
}

// MARK:- Saving

extension ConversationFileStore {
    
    // MARK: Saving Events to Disk
    
    private func writeEventJSONStringsToDisk() {
        guard needsWriteToFile && writeQueue.count > 0 else { return }
        
        needsWriteToFile = false
        
        trimWriteQueueIfNecessary()
        
        let stringToWrite = writeQueue.joined(separator: ",\n")
        
        if writeStringToFile(stringToWrite: stringToWrite) {
            _debugLog(message: "Successfully wrote \(writeQueue.count) events to disk.")
        } else {
            _debugLog(message: "Failed to write \(writeQueue.count) events to disk.")
        }
    }
    
    // MARK: Public
    
    public func save(async: Bool = true) {
        guard needsWriteToFile else { return }
        
        if async {
            Dispatcher.performOnBackgroundThread {
                self.writeEventJSONStringsToDisk()
            }
        } else {
            writeEventJSONStringsToDisk()
        }
    }
}
