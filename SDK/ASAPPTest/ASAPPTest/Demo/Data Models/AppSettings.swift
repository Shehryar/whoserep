//
//  AppSettings.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 10/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit
import ASAPP

class AppSettings: NSObject {
    
    enum Key: String {
        case apiHostName = "asapp_api_host_name"
        case appId = "asapp_app_id"
        case customerIdentifier = "asapp_customer_identifier"
        case userName = "asapp_user_name"
        case userImageName = "asapp_user_image_name"
        case brandingType = "asapp_branding"
        
        case apiHostNameList = "asapp_api_host_name_list"
        case appIdList = "asapp_app_id_list"
        case customerIdentifierList = "asapp_customer_identifier_list"
    }
    
    // MARK: Shared Instance
    
    static let shared = AppSettings()
    
    // MARK:- Properties
    
    var apiHostName: String {
        return AppSettings.getString(forKey: Key.apiHostName,
                                     defaultValue: AppSettings.defaultAPIHostName)
    }
    
    var appId: String {
        return AppSettings.getString(forKey: Key.appId,
                                     defaultValue: AppSettings.defaultAppId)
    }
    
    var customerIdentifier: String {
        return AppSettings.getString(forKey: Key.customerIdentifier,
                                     defaultValue: AppSettings.getRandomCustomerIdentifier())
    }
    
    var userName: String {
        return AppSettings.getString(forKey: Key.userName,
                                     defaultValue: AppSettings.defaultUserName)
    }
    
    var userImageName: String {
        return AppSettings.getString(forKey: Key.userImageName,
                                     defaultValue: AppSettings.defaultUserImageName)
    }
    
    var branding: Branding {
        didSet {
            AppSettings.saveObject(branding.brandingType.rawValue, forKey: Key.brandingType)
        }
    }
    
    var apiHostNames: [String] {
        return AppSettings.getStringArray(forKey: Key.apiHostNameList) ?? AppSettings.getDefaultAPIHostNames()
    }
    
    var appIds: [String] {
        return AppSettings.getStringArray(forKey: Key.appIdList) ?? AppSettings.getDefaultAppIds()
    }
    
    var customerIdentifiers: [String] {
        return AppSettings.getStringArray(forKey: Key.customerIdentifierList) ?? AppSettings.getDefaultCustomerIdentifiers()
    }
    
    var userImageNames: [String] {
        return AppSettings.getDefaultImageNames()
    }
    
    let versionString: String
    
    //
    // MARK:- Init
    //
    
    override init() {
        let brandingType = BrandingType.from(AppSettings.getString(forKey: Key.brandingType)) ?? AppSettings.defaultBrandingType
        self.branding = Branding(brandingType: brandingType)
    
        let version = Bundle.main.object(forInfoDictionaryKey: "CFBundleShortVersionString") as! String
        let build = Bundle.main.object(forInfoDictionaryKey: kCFBundleVersionKey as String) as! String
        self.versionString = "\(version) (\(build))"
        
        super.init()
    }
    
    deinit {
        NotificationCenter.default.removeObserver(self)
    }
}

// MARK:- Defaults

fileprivate extension AppSettings {
    
    static let defaultAPIHostName = getDefaultAPIHostNames().first!
    
    static let defaultAppId = getDefaultAppIds().first!
    
    static let defaultUserName = "Jon"
    
    static let defaultUserImageName = "user-anonymous"
    
    static let defaultBrandingType = BrandingType.asapp
    
    class func getDefaultAPIHostNames() -> [String] {
        return [
            "sprint.preprod.asapp.com",
            "comcast.preprod.asapp.com",
            "demo.asapp.com"
        ]
    }
    
    class func getDefaultAppIds() -> [String] {
        return [
            "boost",
            "comcast",
            "asapp",
            "company1",
            "company2",
            "company3",
            "company4",
            "company5",
            "company6",
            "company7",
            "company8",
            "company9",
            "company10",
            "company11",
        ]
    }
    
    class func getDefaultCustomerIdentifiers() -> [String] {
        return [
            "test_customer_1",
            "test_customer_2",
            "+13126089137",
            "+13473040637",
            "+19179911056",
            "+19176646758",
            "+19084337447",
            "+19173708897",
            "+19173241544",
            "+17038638070",
            "+19134818010",
            "+16173317845",
            "+12152065821",
            "+16173317845"
        ]
    }
    
    class func getDefaultImageNames() -> [String] {
        return [
            "user-gustavo",
            "user-jane",
            "user-alan",
            "user-joshua",
            "user-susan",
            "user-tim",
            "user-tony",
            "user-lori",
            "user-sandy",
            "user-rachel",
            "user-max"
        ]
    }
}

// MARK:- Storage

extension AppSettings {
    
    class func saveObject(_ object: Any, forKey key: Key, async: Bool = true) {
        let saveBlock = {
            print("Saving object: \(object), for key: \(key.rawValue), async = \(async)")
            
            UserDefaults.standard.set(object, forKey: key.rawValue)
            UserDefaults.standard.synchronize()
        }
        
        if async {
            DispatchQueue.global(qos: .background).async(execute: saveBlock)
        } else {
            saveBlock()
        }
    }
    
    class func addStringToArray(_ stringValue: String, forKey key: Key) {
        var stringArray = getStringArray(forKey: key) ?? [String]()
        stringArray.append(stringValue)
        saveObject(stringArray, forKey: key)
    }
    
    class func getString(forKey key: Key, defaultValue: String) -> String {
        var stringValue = UserDefaults.standard.string(forKey: key.rawValue)
        if let stringValue = stringValue {
            print("Found string: \(stringValue), for key: \(key.rawValue)")
            return stringValue
        }
        
        print("Using default string: \(defaultValue), for key: \(key.rawValue)")
        saveObject(defaultValue, forKey: key)
        
        return defaultValue
    }
    
    class func getString(forKey key: Key) -> String? {
        let stringValue = UserDefaults.standard.string(forKey: key.rawValue)

        print("Found string: \(stringValue ?? "nil"), for key: \(key.rawValue)")
        
        return stringValue
    }

    class func getStringArray(forKey key: Key) -> [String]? {
        let stringArray = UserDefaults.standard.stringArray(forKey: key.rawValue)
        
        print("Found string array: \(String(describing: stringArray)), for key: \(key.rawValue)")
        
        return stringArray ?? getDefaultStringArray(forKey: key)
    }
    
    private class func getDefaultStringArray(forKey key: Key) -> [String]? {
        switch key {
        case .apiHostNameList: return getDefaultAPIHostNames()
        case .appIdList: return getDefaultAppIds()
        case .customerIdentifierList: return getDefaultCustomerIdentifiers()
        default: return nil
        }
    }
}

// MARK:- Custom Vaues

extension AppSettings {
    
    func addAPIHostName(_ value: String) {
        AppSettings.addStringToArray(value, forKey: Key.apiHostNameList)
    }
    
    func addAppId(_ value: String) {
        AppSettings.addStringToArray(value, forKey: Key.appIdList)
    }
    
    func addCustomerIdentifier(_ value: String) {
        AppSettings.addStringToArray(value, forKey: Key.customerIdentifierList)
    }
    
    class func getRandomCustomerIdentifier() -> String {
        return "test-token-\(Int(Date().timeIntervalSince1970))"
    }
}

// MARK:- Auth + Context

extension AppSettings {
    
    func getContext() -> [String : Any] {
        return [
            ASAPP.AUTH_KEY_ACCESS_TOKEN : "asapp_ios_fake_access_token",
            "fake_context_key_1" : "fake_context_value_1",
            "fake_context_key_2" : "fake_context_value_2"
        ]
    }
}
