//
//  UserAccount.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class UserAccount: NSObject {
    var name: String
    var imageName: String
    var userToken: String
    
    required init(name: String, imageName: String, userToken: String) {
        self.name = name
        self.imageName = imageName
        self.userToken = userToken
        super.init()
    }

    // MARK: Class
    
    class var all: [UserAccount] {
        return [
            UserAccount(name: "Gustavo", imageName: "user-gustavo", userToken: ""),
            UserAccount(name: "Josh", imageName: "user-josh", userToken: ""),
            UserAccount(name: "Jane", imageName: "user-jane", userToken: ""),
            UserAccount(name: "Rachel", imageName: "user-rachel", userToken: ""),
            UserAccount(name: "Vicky", imageName: "user-vicky", userToken: ""),
            UserAccount(name: "Mitch", imageName: "user-mitch", userToken: ""),
        ]
    }
    
    class func account(forName name: String) -> UserAccount? {
        let allAccounts = all
        for account in allAccounts {
            if account.name == name {
                return account
            }
        }
        return nil
    }
}
