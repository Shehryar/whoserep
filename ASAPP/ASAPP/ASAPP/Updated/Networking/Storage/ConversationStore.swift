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
    
    private(set) public var credentials: Credentials
    
    private(set) public var conversation: Conversation?
    
    public var messageEvents: [Event] {
        var messageEvents = [Event]()
        if let conversation = conversation {
            for messageEvent in conversation.messageEvents {
                messageEvents.append(messageEvent)
            }
        }
        return messageEvents
    }
    
    // MARK: Private Properties
    
    private var realm: Realm?
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        super.init()
        
        self.realm = loadOrCreateRealm(withCredentials: self.credentials)
        
        var storedConversation = self.realm?.objects(Conversation.self).filter({ (conversation) -> Bool in
            return (conversation.company == credentials.companyMarker &&
                conversation.isCustomer == credentials.isCustomer &&
                conversation.userToken == credentials.userToken &&
                conversation.targetCustomerToken == credentials.targetCustomerToken
            )
        }).last
        
        if storedConversation != nil {
            self.conversation = storedConversation
        } else {
            self.conversation = Conversation(withCredentials: self.credentials)
            saveConversation()
        }
    }
}

// MARK:- Realm Setup Utilities

extension ConversationStore {
    
    func realmFileURL(withCredentials credentials: Credentials) -> NSURL {
        let filePaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let fileName = String(format: "/ASAPP_%@_%@.realm", credentials.companyMarker, credentials.isCustomer)
        let filePath = filePaths[0].stringByAppendingString(fileName)
        return NSURL(fileURLWithPath: filePath)
    }
    
    func loadOrCreateRealm(withCredentials credentials: Credentials) -> Realm? {
        let fileURL = realmFileURL(withCredentials: credentials)
        
        DebugLog("Loading Realm with FileURL: \(fileURL.path)")
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            let success = NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: nil, attributes: nil)
            DebugLog("REALM created file: \(success)")
        }
        
        let realm = try? Realm(fileURL: fileURL)
        if let realm = realm {
            DebugLog("REALM initialized with file: \(realm.configuration.fileURL)")
        } else {
            DebugLog("Failed to initialize REALM")
        }
        
        return realm
    }
} 

// MARK:- Making Changes

extension ConversationStore {
    func saveConversation() {
        guard let conversation = conversation,
            let realm = realm else {
                return
        }
        
        do {
            try realm.write({
                realm.add(conversation, update: true)
            })
        } catch {
            DebugLogError("Failed to save conversation: \(conversation)")
        }
    }
    
    func addEvent(event: Event) {
        guard let conversation = conversation,
            let realm = realm else {
                return
        }
        
        do {
            try realm.write {
                conversation.messageEvents.append(event)
            }
        } catch {
            DebugLogError("Failed to write event: \(event)")
        }
    }
}
