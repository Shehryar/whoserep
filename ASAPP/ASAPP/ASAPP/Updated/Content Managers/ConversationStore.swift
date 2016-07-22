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
   
    public var fullCredentials: FullCredentials? {
        return fullCredentialsResults?.last
    }
    
    public var messageEvents: [Event]? {
        return nil
    }
    
    // MARK: Private Properties
    
    private var realm: Realm?
    
    private var fullCredentialsResults: Results<FullCredentials>?
    
    private var messageEventsResults: Results<Event>?
    
    // MARK: Initialization
    
    init(withCredentials credentials: Credentials) {
        self.credentials = credentials
        super.init()
        
        self.realm = loadOrCreateRealm(withCredentials: self.credentials)
        self.fullCredentialsResults = loadOrCreateFullCredentialsResults(withCredentials: self.credentials)
        self.messageEventsResults = loadOrCreateMessageEventResults()
    }
}

// MARK:- Realm Setup Utilities

extension ConversationStore {
    // MARK: Utility
    
    func realmFileURL(withCredentials credentials: Credentials) -> NSURL {
        let filePaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let fileName = String(format: "/ASAPP_%@_%@.realm", credentials.companyMarker, credentials.isCustomer)
        let filePath = filePaths[0].stringByAppendingString(fileName)
        return NSURL(fileURLWithPath: filePath)
    }
    
    // MARK: Creation
    
    func loadOrCreateRealm(withCredentials credentials: Credentials) -> Realm? {
        let fileURL = realmFileURL(withCredentials: credentials)
        
        ASAPPLog("Loading Realm with FileURL: ", fileURL.path)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            let success = NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: nil, attributes: nil)
            ASAPPLog("REALM created file: ", success)
        }
        
        let realm = try? Realm(fileURL: fileURL)
        if let realm = realm {
            ASAPPLog("REALM initialized with file:", realm.configuration.fileURL)
        } else {
            ASAPPLoge("Failed to initialize REALM")
        }
        
        return realm
    }
    
    func loadOrCreateFullCredentialsResults(withCredentials credentials: Credentials) -> Results<FullCredentials>? {
        guard let realm = realm else {
            ASAPPLoge("Realm was not properly created.")
            return nil
        }
        
        var storedFullCredentials = realm.objects(FullCredentials.self)
        if storedFullCredentials.count == 0 {
            var newFullCredentials = FullCredentials(withCredentials: self.credentials)
            try! realm.write({
                realm.add(newFullCredentials)
            })
            storedFullCredentials = realm.objects(FullCredentials.self)
        }
        return storedFullCredentials
    }
    
    func loadOrCreateMessageEventResults() -> Results<Event>? {
        guard let realm = realm else {
            ASAPPLoge("Realm was not properly created.")
            return nil
        }
        
        return realm.objects(Event.self)
    }
} 

// MARK:- Making Changes

extension ConversationStore {
    func updateFullCredentials(value: AnyObject?, forKeyPath keyPath: String) {
        guard let realm = realm else {
            return
        }
        
        try! realm.write({
            fullCredentialsResults?.setValue(value, forKeyPath: keyPath)
        })
    }
    
    func addEvent(event: Event) {
        guard let realm = realm else {
            return
        }
        
        try! realm.write({
            realm.add(event, update: true)
        })
    }
}
