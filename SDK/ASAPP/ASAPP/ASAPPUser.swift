//
//  ASAPPUser.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 4/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

public typealias ASAPPRequestContextProvider = (() -> [String : Any])

// MARK:- ASAPPUser

public class ASAPPUser: NSObject {

    public let userIdentifier: String
    
    public let requestContextProvider: ASAPPRequestContextProvider

    // MARK:- Init
    
    public init(userIdentifier: String,
                requestContextProvider: @escaping ASAPPRequestContextProvider) {
        self.userIdentifier = userIdentifier
        self.requestContextProvider = requestContextProvider
        super.init()
    }
}

// MARK:- Auth / Context Utilities

extension ASAPPUser {
    
    typealias ContextRequestCompletion = ((_ context: [String : Any]?, _ authToken: String?) -> Void)
    
    func getContext(completion: @escaping ContextRequestCompletion) {
        Dispatcher.performOnBackgroundThread { [weak self] in
            let context = self?.requestContextProvider()
            let authToken = context?[ASAPP.AUTH_KEY_ACCESS_TOKEN] as? String
            
            completion(context, authToken)
        }
    }
}
