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
        case jane
        case alan
        case joshua
        case susan
        case tim
        case tony
        case lori
        case sandy
        case rachel
        case max
        case rachelBoost
        
        static let all = [
            gustavo,
            jane,
            alan,
            joshua,
            susan,
            tim,
            tony,
            lori,
            sandy,
            rachel,
            max,
            rachelBoost
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
            
        case .jane: return UserAccount(name: "Jane",
                                       imageName: "user-jane",
                                       company: "company2",
                                       userToken: "+13473040637")
            
        case .alan:return UserAccount(name: "Alan",
                                      imageName: "user-alan",
                                      company: "company3",
                                      userToken: "+19179911056")
            
        case .joshua: return UserAccount(name: "Joshua",
                                         imageName: "user-joshua",
                                         company: "company4",
                                         userToken: "+19176646758")
            
        case .susan: return UserAccount(name: "Susan",
                                        imageName: "user-susan",
                                        company: "company5",
                                        userToken: "+19084337447")
            
        case .tim: return UserAccount(name: "Tim",
                                     imageName: "user-tim",
                                     company: "company6",
                                     userToken: "+19173708897")
            
        case .tony: return UserAccount(name: "Tony",
                                       imageName: "user-tony",
                                       company: "company7",
                                       userToken: "+19173241544")
            
        case .lori: return UserAccount(name: "Lori",
                                       imageName: "user-lori",
                                       company: "company8",
                                       userToken: "+17038638070")
            
        case .sandy: return UserAccount(name: "Sandy",
                                        imageName: "user-sandy",
                                        company: "company9",
                                        userToken: "+19134818010")
            
        case .rachel: return UserAccount(name: "Rachel",
                                         imageName: "user-rachel",
                                         company: "company10",
                                         userToken: "+16173317845")
            
        case .max: return UserAccount(name: "Max",
                                      imageName: "user-max",
                                      company: "company11",
                                      userToken: "+12152065821")
            
        case .rachelBoost: return UserAccount(name: "Rachel (Boost)",
                                              imageName: "user-rachel",
                                              company: "boost",
                                              userToken: "+16173317845")
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
        guard let savedAccountJSON = UserDefaults.standard.object(forKey: key) as? [String : String] else {
            DemoLog("No Account JSON found with key: \(key)")
            return nil
        }
        guard let savedAccount  = UserAccount.accountWith(json: savedAccountJSON) else {
            DemoLog("Unable to create account from saved json with key \(key):\n\(savedAccountJSON)")
            return nil
        }
        
        DemoLog("Found account with key \(key): [\(savedAccount.name):\(savedAccount.company):\(savedAccount.userToken)]")
        return savedAccount
    }
}
