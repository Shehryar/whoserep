//
//  ASAPPStore.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 7/6/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation
import RealmSwift

class ASAPPStore: NSObject {
    
    var realm: Realm!
    
    var mState: Results<ASAPPStateModel>!
    var mEventLog: Results<ASAPPEvent>!
    
    func loadOrCreate(company: String, userToken: String?, isCustomer: Bool) {
        ASAPPLog("Initializing Store")
        
        let filePaths = NSSearchPathForDirectoriesInDomains(.DocumentDirectory, .UserDomainMask, true)
        let fileName = String(format: "/ASAPP_%@_%@.realm", company, isCustomer)
        let filePath = filePaths[0].stringByAppendingString(fileName)
        let fileURL = NSURL(fileURLWithPath: filePath)
        
        ASAPPLog(fileURL.path)
        if !NSFileManager.defaultManager().fileExistsAtPath(fileURL.path!) {
            ASAPPLog("REALM create file:", NSFileManager.defaultManager().createFileAtPath(fileURL.path!, contents: nil, attributes: nil))
        }
        
        realm = try! Realm(fileURL: fileURL)
        ASAPPLog("REALM initialized with file:", realm.configuration.fileURL)
        
        // Load state if found, otherwise create
        mState = realm.objects(ASAPPStateModel.self)
        if mState.count == 0 {
            let stateModel = ASAPPStateModel()
            stateModel.companyMarker = company
            stateModel.userToken = userToken
            stateModel.isCustomer = isCustomer
            try! realm.write({ 
                realm.add(stateModel)
            })
        }
        
        // Load events for eventlog
        mEventLog = realm.objects(ASAPPEvent.self)
    }
    
    func stateProperty(keyPath: String) -> AnyObject? {
        if mState.last == nil {
            return nil
        }
        
        return mState.last?.valueForKeyPath(keyPath)
    }
    
    func updateState(value: AnyObject?, forKeyPath: String) {
        try! realm.write({
            // NOTE: There should be only one object for state.
            // Thus, it is fine to update all the objects of results.
            mState.setValue(value, forKeyPath: forKeyPath)
        })
    }
    
    func addEvent(event: ASAPPEvent) {
        try! realm.write({ 
            realm.add(event, update: true)
        })
    }
}