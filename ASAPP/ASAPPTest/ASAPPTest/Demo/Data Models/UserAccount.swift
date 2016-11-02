//
//  UserAccount.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class UserAccount: NSObject {
    
    enum PresetAccount {
        case gustavo
        case josh
        case jane
        case rachel
        case vicky
        case mitch
        
        static let all = [
            gustavo,
            josh,
            jane,
            rachel,
            vicky,
            mitch
        ]
    }
    
    var name: String
    var imageName: String
    var userToken: String
    
    fileprivate static let defaultImageName = "user-anonymous"
    
    required init(name: String, imageName: String, userToken: String) {
        self.name = name
        self.imageName = imageName
        self.userToken = userToken
        super.init()
    }
}

// MARK:- Preset Accounts

extension UserAccount {
    
    class func account(forPresetAccount presetAccount: PresetAccount) -> UserAccount {
        switch presetAccount {
        case .gustavo: return UserAccount(name: "Gustavo",
                                          imageName: "user-gustavo",
                                          userToken: "+13126089137")
            
        case .josh: return UserAccount(name: "Josh",
                                       imageName: "user-josh",
                                       userToken: "test-token-josh")
            
        case .jane: return UserAccount(name: "Jane",
                                       imageName: "user-jane",
                                       userToken: "test-token-jane")
            
        case .rachel: return UserAccount(name: "Rachel",
                                         imageName: "user-rachel",
                                         userToken: "test-token-rachel")
            
        case .vicky: return UserAccount(name: "Vicky",
                                        imageName: "user-vicky",
                                        userToken: "test-token-vicky")
            
        case .mitch: return UserAccount(name: "Mitch",
                                        imageName: "user-mitch",
                                        userToken: "test-token-mitch")
        }
    }
    
    class func allPresetAccounts() -> [UserAccount] {
        var userAccounts = [UserAccount]()
        for preset in PresetAccount.all {
            userAccounts.append(account(forPresetAccount: preset))
        }
        return userAccounts
    }
}

// MARK:- Creating New Accounts

extension UserAccount {
    
    class func newRandomAccount() -> UserAccount {
        let name = RandomNameGenerator.firstName()
        let userToken = "test-token-\(Int(Date().timeIntervalSince1970))"
        
        return UserAccount(name: name,
                           imageName: UserAccount.defaultImageName,
                           userToken: userToken)
    }
}

// MARK:- JSON

extension UserAccount {

    static let keyName = "name"
    static let keyUserToken = "user_token"
    static let keyImageName = "image_name"
    
    class func accountWith(json: [String : String]?) -> UserAccount? {
        guard let json = json,
            let name = json[keyName],
            let userToken = json[keyUserToken]
            else {
                return nil
        }
        
        let account = UserAccount(name: name,
                                  imageName: json[keyImageName] ?? defaultImageName,
                                  userToken: userToken)
        
        return account
    }
 
    func toJSON() -> [String : String] {
        return [
            UserAccount.keyName : name,
            UserAccount.keyUserToken : userToken,
            UserAccount.keyImageName : imageName
        ]
    }
}

// MARK:- Saving

extension UserAccount {
    
    func save(withKey key: String) {
        DemoLog("Saving account with key \(key):\n\(toJSON())\n")
        
        UserDefaults.standard.set(toJSON(), forKey: key)
    }
    
    class func getSavedAccount(withKey key: String) -> UserAccount? {
        if let savedAccountJSON = UserDefaults.standard.object(forKey: key) as? [String : String],
            let savedAccount = UserAccount.accountWith(json: savedAccountJSON) {
            DemoLog("Found account with key \(key):\n\(savedAccount.toJSON())")
            return savedAccount
        }
        DemoLog("No account found with key \(key)")
        return nil
    }
}
