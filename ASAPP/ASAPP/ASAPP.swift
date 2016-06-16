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
    
    var customerToken: String!
    
    // Public APIs
    override public init() {
        super.init()
        
        ASAPP.instance = self
        loadFonts()
        
        state = ASAPPState()
    }
    
    convenience init(customerToken: String) {
        self.init()
        self.customerToken = customerToken
    }
    
    internal func openConversation() {
        
    }
    
    public func viewControllerForChat() -> UIViewController {
        return ASAPPChatViewController()
    }
}