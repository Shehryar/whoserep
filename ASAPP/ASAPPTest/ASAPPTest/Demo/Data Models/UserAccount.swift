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
    var company: String
    var userToken: String
    
    fileprivate static let defaultImageName = "user-anonymous"
    
    required init(name: String, imageName: String, company: String, userToken: String) {
        self.name = name
        self.imageName = imageName
        self.company = company
        self.userToken = userToken
        super.init()
    }
}

// MARK:- Preset Accounts

extension UserAccount {
    
    class func account(forPresetAccount presetAccount: PresetAccount, company: String) -> UserAccount {
        switch presetAccount {
        case .gustavo: return UserAccount(name: "Gustavo",
                                          imageName: "user-gustavo",
                                          company: company,
                                          userToken: "+13126089137")
            
        case .josh: return UserAccount(name: "Josh",
                                       imageName: "user-josh",
                                       company: company,
                                       userToken: "test-token-josh")
            
        case .jane: return UserAccount(name: "Jane",
                                       imageName: "user-jane",
                                       company: company,
                                       userToken: "test-token-jane")
            
        case .rachel: return UserAccount(name: "Rachel",
                                         imageName: "user-rachel",
                                         company: company,
                                         userToken: "test-token-rachel")
            
        case .vicky: return UserAccount(name: "Vicky",
                                        imageName: "user-vicky",
                                        company: company,
                                        userToken: "test-token-vicky")
            
        case .mitch: return UserAccount(name: "Mitch",
                                        imageName: "user-mitch",
                                        company: company,
                                        userToken: "test-token-mitch")
        }
    }
    
    class func allPresetAccounts() -> [UserAccount] {
        var userAccounts = [UserAccount]()
        for preset in PresetAccount.all {
            userAccounts.append(account(forPresetAccount: preset, company: "asapp"))
        }
        return userAccounts
    }
}

// MARK:- Creating New Accounts

extension UserAccount {
    
    class func newRandomAccount(company: String) -> UserAccount {
        let name = RandomNameGenerator.firstName()
        let userToken = "test-token-\(Int(Date().timeIntervalSince1970))"
        
        return UserAccount(name: name,
                           imageName: UserAccount.defaultImageName,
                           company: company,
                           userToken: userToken)
    }
}

// MARK:- JSON

extension UserAccount {

    static let keyName = "name"
    static let keyCompany = "company"
    static let keyUserToken = "user_token"
    static let keyImageName = "image_name"
    
    class func accountWith(json: [String : String]?) -> UserAccount? {
        guard let json = json,
            let name = json[keyName],
            let userToken = json[keyUserToken],
            let company = json[keyCompany]
            else {
                return nil
        }
        
        let account = UserAccount(name: name,
                                  imageName: json[keyImageName] ?? defaultImageName,
                                  company: company,
                                  userToken: userToken)
        
        return account
    }
 
    func toJSON() -> [String : String] {
        return [
            UserAccount.keyName : name,
            UserAccount.keyCompany : company,
            UserAccount.keyUserToken : userToken,
            UserAccount.keyImageName : imageName
        ]
    }
}

// MARK:- Saving

extension UserAccount {
    
    func save(withKey key: String) {
        DemoLog("Saving account with key \(key): [\(name):\(company):\(userToken)]")
        
        UserDefaults.standard.set(toJSON(), forKey: key)
        UserDefaults.standard.synchronize()
    }
    
    class func getSavedAccount(withKey key: String) -> UserAccount? {
        if let savedAccountJSON = UserDefaults.standard.object(forKey: key) as? [String : String],
            let savedAccount = UserAccount.accountWith(json: savedAccountJSON) {
            DemoLog("Found account with key \(key): [\(savedAccount.name):\(savedAccount.company):\(savedAccount.userToken)]")
            return savedAccount
        }
        DemoLog("No account found with key \(key)")
        return nil
    }
}
