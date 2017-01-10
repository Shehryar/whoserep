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
        case alan
        case joshua
        case susan
        case tim
        case tony
        case lori
        case sandy
        case rachel
        case max
        case jane
        
        static let all = [
            gustavo,
            alan,
            joshua,
            susan,
            tim,
            tony,
            lori,
            sandy,
            rachel,
            max,
            jane
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
                                          company: "company1",
                                          userToken: "+13126089137")
            
        case .alan:return UserAccount(name: "Alan",
                                      imageName: "user-alan",
                                      company: "company2",
                                      userToken: "test-user-alan")
            
        case .joshua: return UserAccount(name: "Joshua",
                                         imageName: "user-joshua",
                                         company: "company3",
                                         userToken: "test-user-joshua")
            
        case .susan: return UserAccount(name: "Susan",
                                        imageName: "user-susan",
                                        company: "company4",
                                        userToken: "test-user-susan")
            
        case .tim: return UserAccount(name: "Tim",
                                     imageName: "user-tim",
                                     company: "company5",
                                     userToken: "test-user-tim")
            
        case .tony: return UserAccount(name: "Tony",
                                       imageName: "user-tony",
                                       company: "company6",
                                       userToken: "test-user-tony")
            
        case .lori: return UserAccount(name: "Lori",
                                       imageName: "user-lori",
                                       company: "company7",
                                       userToken: "test-user-lori")
            
        case .sandy: return UserAccount(name: "Sandy",
                                        imageName: "user-sandy",
                                        company: "company8",
                                        userToken: "test-user-sandy")
            
        case .rachel: return UserAccount(name: "Rachel",
                                         imageName: "user-rachel",
                                         company: "company9",
                                         userToken: "test-user-rachel")
            
        case .max: return UserAccount(name: "Max",
                                      imageName: "user-max",
                                      company: "company10",
                                      userToken: "test-user-max")
            
        case .jane: return UserAccount(name: "Jane",
                                       imageName: "user-jane",
                                       company: "company11",
                                       userToken: "test-user-jane")
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
