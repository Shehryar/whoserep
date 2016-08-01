//
//  ConversationStore.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import RealmSwift

class ConversationStore: NSObject {

    // MARK: Properties
    
    private(set) var credentials: Credentials
    
    // MARK: Private Properties
    
    private var realmFileURL: NSURL
    
    private var realm: Realm?
    
    private var conversation: Conversation?
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        
        let filePaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let fileName = String(format: "/ASAPP_%@_%@.realm", credentials.companyMarker, credentials.isCustomer)
        let filePath = filePaths[0].stringByAppendingString(fileName)
        self.realmFileURL = NSURL(fileURLWithPath: filePath)

        super.init()
        
        self.realm = createRealmObject()
        self.conversation = getStoredOrNewConversation()
    }
}

// MARK:- Realm Setup

extension ConversationStore {
    private func createRealmObject() -> Realm? {
        DebugLog("Loading Realm with FileURL: \(realmFileURL.path)")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(realmFileURL.path!) {
            let success = NSFileManager.defaultManager().createFileAtPath(realmFileURL.path!, contents: nil, attributes: nil)
            DebugLog("REALM created file: \(success)")
        }
        
        let realm = try? Realm(fileURL: realmFileURL)
        if let realm = realm {
            DebugLog("REALM initialized with file: \(realm.configuration.fileURL)")
        } else {
            DebugLog("Failed to initialize REALM with file URL: \(realmFileURL)")
        }
        
        return realm
    }
    
    private func getStoredOrNewConversation() -> Conversation? {
        guard let realm = realm else { return nil }
        
        let storedConversation = realm.objects(Conversation.self).filter({ (conversation) -> Bool in
            return (conversation.company == self.credentials.companyMarker &&
                conversation.isCustomer == self.credentials.isCustomer &&
                conversation.userToken == self.credentials.userToken &&
                conversation.targetCustomerToken == self.credentials.targetCustomerToken
            )
        }).last
        
        if storedConversation != nil {
            DebugLog("Fetched stored conversation.")
            return storedConversation
        }
        
        DebugLog("Creating new conversation.")
        
        let newConversation = Conversation(withCredentials: self.credentials)
        do {
            try realm.write({
                realm.add(newConversation, update: true)
            })
        } catch {
            DebugLogError("Failed to save conversation: \(conversation)")
        }
        
        return newConversation
    }
}

// MARK:- Making Changes

extension ConversationStore {
    func getMessageEvents() -> [Event] {
        guard let conversation = conversation else {   return [] }
        
        var messageEvents = [Event]()
        for messageEvent in conversation.messageEvents {
            messageEvents.append(messageEvent)
        }
        return messageEvents
    }
    
    func updateWithRecentMessageEvents(events: [Event]) {
        guard let realm = realm, let conversation = conversation else { return }
        
        do {
            try realm.write({ 
                conversation.messageEvents.removeAll()
                conversation.messageEvents.appendContentsOf(events)
            })
        } catch {
            DebugLogError("Failed to update conversation with \(events.count) recent events.")
        }
    }
    
    func addEvent(event: Event) {
        guard let realm = realm, let conversation = conversation else { return }
        
        do {
            try realm.write {
                conversation.messageEvents.append(event)
            }
        } catch {
            DebugLogError("Failed to write event: \(event)")
        }
    }
}
