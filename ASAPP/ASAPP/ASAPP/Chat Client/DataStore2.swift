//
//  DataStore.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/20/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import RealmSwift

class DataStore2: NSObject {

    // MARK: Private Properties
    
    private var realm: Realm?
    
    var mCredentials: Results<Credentials>?
    var mEventLog: Results<Event>?
    
    // MARK:- Initialization
    
    public func loadOrCreate(withCompany company: String, userToken: String? = nil, isCustomer: Bool = true) {
        ASAPPLog("Updating Store")
        
        realm = loadOrCreateRealm(withCompany: company, isCustomer: isCustomer)
        mCredentials = loadOrCreateCredentials(withCompany: company, userToken: userToken, isCustomer: isCustomer)
        mEventLog = loadOrCreateEventLog()
    }
    
    // MARK: Realm Utility
    
    private func createFileURL(forCompany company: String, isCustomer: Bool) -> NSURL {
        let filePaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let fileName = String(format: "/ASAPP_%@_%@.realm", company, isCustomer)
        let filePath = filePaths[0].stringByAppendingString(fileName)
        return NSURL(fileURLWithPath: filePath)
    }
    
    private func loadOrCreateRealm(withCompany company: String, isCustomer: Bool = true) -> Realm {
        let fileURL = createFileURL(forCompany: company, isCustomer: isCustomer)
        
        ASAPPLog("Loading Realm with FileURL: ", fileURL.path)
        
        if !NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            let success = NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: nil, attributes: nil)
            ASAPPLog("REALM created file: ", success)
        }

        let realm = try! Realm(fileURL: fileURL)
        
        ASAPPLog("REALM initialized with file:", realm.configuration.fileURL)
        
        return realm
    }
    
    private func loadOrCreateCredentials(withCompany company: String,
                                             userToken: String? = nil,
                                             isCustomer: Bool = true) -> Results<Credentials>? {
        guard let realm = realm else {
            ASAPPLoge("Unable to load/create credentials because realm is nil")
            return nil
        }
        
        var storedCredentials = realm.objects(Credentials.self)
        if storedCredentials.count == 0 {
            
            var credentials = Credentials()
            credentials.companyMarker = company
            credentials.userToken = userToken
            credentials.isCustomer = isCustomer
            try! realm.write({
                realm.add(credentials)
            })
        }

        return storedCredentials
    }
    
    private func loadOrCreateEventLog() -> Results<Event>? {
        guard let realm = realm else {
            ASAPPLoge("Unable to load/create event log because realm is nil")
            return nil
        }
        
        return realm.objects(Event.self)
    }
    
    // MARK:- Instance Methods
    
    func addEvent(event: Event) {
        guard let realm = realm else {
            ASAPPLoge("Realm not properly initialized")
            return
        }
        
        try! realm.write({
            realm.add(event, update: true)
        })
    }
}
