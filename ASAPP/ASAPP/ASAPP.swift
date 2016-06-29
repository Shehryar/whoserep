//
//  ASAPP.swift
//  ASAPP
//
//  Created by Vicky Sehrawat on 6/13/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation
import SnapKit

public class ASAPP: NSObject {
    
    static var instance: ASAPP!
    var state: ASAPPState!
    
    var mUserToken: String!
    var mIsCustomer: Bool!
    var mTargetCustomerToken: String!
    
    // Public APIs
    override public init() {
        super.init()
        loadFonts()
    }
    
    public convenience init(userToken: String, isCustomer: Bool) {
        self.init()
        mIsCustomer = isCustomer
        mUserToken = userToken
        
        ASAPP.instance = self
        state = ASAPPState()
    }
    
    public func viewControllerForChat() -> UIViewController {
        return ASAPPChatViewController()
    }
    
    public func targetCustomerToken(targetCustomerToken: String) {
        if ASAPP.isCustomer() {
            ASAPPLoge("ERROR: Cannot set targetCustomer for Customer chat session.")
            return
        }
        
        if mTargetCustomerToken != nil && mTargetCustomerToken == targetCustomerToken {
            ASAPPLoge("WARNING: Same targetCustomerToken provided.")
            return
        }
        
        mTargetCustomerToken = targetCustomerToken
        state.reloadStateForRep(targetCustomerToken)
    }
    
    // MARK: - Helper Functions
    
    static func isCustomer() -> Bool {
        if ASAPP.instance == nil || ASAPP.instance.mIsCustomer == nil {
            return true
        }
        
        return ASAPP.instance.mIsCustomer
    }
    
    static func myId() -> UInt? {
        if ASAPP.instance == nil || ASAPP.instance.state == nil {
            return nil
        }
        
        return ASAPP.instance.state.mMyId
    }
}