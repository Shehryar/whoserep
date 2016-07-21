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
    
    var mState: ASAPPState!
    
    // Public APIs
    override public init() {
        super.init()
//        loadFonts()
    }
    
    public convenience init(company: String) {
        self.init(company: company, userToken: nil)
    }
    
    public convenience init(company: String, userToken: String?) {
        self.init(company: company, userToken: userToken, isCustomer: true)
    }
    
    public convenience init(company: String, userToken: String?, isCustomer: Bool) {
        self.init()
        mState = ASAPPState()
        mState.loadOrCreate(company, userToken: userToken, isCustomer: isCustomer)
    }
    
    public func viewControllerForChat() -> UIViewController {
        let vc = ASAPPChatViewController()
        vc.dataSource = mState
        return vc
    }
    
    public func targetCustomerToken(targetCustomerToken: String) {
        if mState.isCustomer() {
            ASAPPLoge("ERROR: Cannot set targetCustomer for Customer chat session.")
            return
        }
        
        if mState.targetCustomerToken() != nil && mState.targetCustomerToken() == targetCustomerToken {
            ASAPPLoge("WARNING: Same targetCustomerToken provided.")
            return
        }
        
        mState.reloadStateForRep(targetCustomerToken)
    }
}

public class ASAPPv2: NSObject {
    
    // MARK:- Instance Methods
    
    public func createChatViewController(withCompany company: String, userToken: String? = nil, isCustomer: Bool = false) -> UIViewController {
        let credentials = Credentials(withCompany: company,
                                      userToken: userToken,
                                      isCustomer: isCustomer)
        
        let viewController = ChatViewController(withCredentials: credentials)
        
        // TODO: remove this later
        let mState = ASAPPState()
        mState.loadOrCreate(company, userToken: userToken, isCustomer: isCustomer)
        viewController.dataSource = mState
        
        return viewController
    }
}


