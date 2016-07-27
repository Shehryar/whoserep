//
//  Reference.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/27/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class Reference: NSObject {
    
    var targetCustomerToken: String?
    
    var myId: Int = 0
    
    var isCustomer: Bool = false
    
    // MARK:- isMyEvent
    
    func isMyEvent(event:Event) -> Bool {
        if isCustomer && event.isCustomerEvent {
            return true
        } else if !isCustomer && myId == event.repId {
            return true
        }
        return false
    }
    
    // MARK:- TargetCustomerToken
    
    func updateForTargetCustomerToken(newTargetCustomerToken: String) {
        if isCustomer {
            return
        }
        if newTargetCustomerToken == targetCustomerToken {
            return
        }
        
        targetCustomerToken = newTargetCustomerToken
        
        // WAIT FOR AUTH TO SUCCEED BEFORE CALLING THE FOLLWING
        
        updateCustomerByCRMCustomerId(withTargetCustomerToken: targetCustomerToken)
    }
    
    func updateCustomerByCRMCustomerId(withTargetCustomerToken targetCustomerToken: String?) {
        guard let targetCustomerToken = targetCustomerToken else { return }
        
        let path = "rep/GetCustomerByCRMCustomerId"
        let params: [String: AnyObject] = [ "CRMCustomerId" : targetCustomerToken ]
        
        sendRequest(withPath: path, params: params, context: nil) { (response) in
            guard let response = response else { return }
            
            if let customerId = (response["Customer"] as? [String: AnyObject])?["CustomerId"] as? Int {
                self.participateInIssueForCustomer(customerId)
            }
        }
    }
    
    func participateInIssueForCustomer(customerId: Int) {
        let path = "rep/ParticipateInIssueForCustomer"
        let params = [String : AnyObject]()
        let context: [String: AnyObject] = [ "CustomerId": customerId ]
        
        sendRequest(withPath: path, params: params, context: nil) { (response) in
            guard let response = response else { return }
            
            if let issueId = response["IssueId"] as? Int {
                
                // SAVE issueID
            }
        }
    }
    
    func sendRequest(withPath path: String,
                              params: [String : AnyObject]?,
                              context: [String : AnyObject]?,
                              completion: ((response: [String : AnyObject]?) -> Void)) {
        
        // Here so code logic is more accurate above
    }
}
