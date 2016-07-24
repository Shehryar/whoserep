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
    
    public var messageEvents: [Event]? {
        var messageEvents = [Event]()
        if let messageEventsResults = messageEventsResults {
            for event in messageEventsResults {
                messageEvents.append(event)
            }
        }
        return messageEvents
    }
    
    // MARK: Private Properties
    
    private var realm: Realm?
    
    private var messageEventsResults: Results<Event>?
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        super.init()
        
        self.realm = loadOrCreateRealm(withCredentials: self.credentials)
        self.messageEventsResults = self.realm?.objects(Event.self)
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
    func addEvent(event: Event) {
        guard let realm = realm else {
            return
        }
        
        do {
            try realm.write({
                realm.add(event, update: true)
            })
        } catch {
            // Handle error
        }
    }
}
