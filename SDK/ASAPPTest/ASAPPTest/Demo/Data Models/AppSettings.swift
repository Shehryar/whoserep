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
        case regionCode = "asapp_region_code"
        case customerIdentifier = "asapp_customer_identifier"
        case authToken = "asapp_auth_token"
        case userName = "asapp_user_name"
        case userImageName = "asapp_user_image_name"
        case brandingType = "asapp_branding"
        
        case apiHostNameList = "asapp_api_host_name_list"
        case appIdList = "asapp_app_id_list"
        case regionCodeList = "asapp_region_code_list"
        case customerIdentifierList = "asapp_customer_identifier_list"
        
        case spearPin = "asapp_spear_pin"
        case spearEnvironment = "asapp_spear_environment"
        
        case tetrisPassword = "asapp_tetris_password"
        case tetrisEnvironment = "asapp_tetris_environment"
    }
    
    // MARK: Shared Instance
    
    static let shared = AppSettings()
    
    // MARK: - Properties
    
    var apiHostName: String {
        return AppSettings.getString(forKey: .apiHostName,
                                     defaultValue: AppSettings.defaultAPIHostName)
    }
    
    var appId: String {
        return AppSettings.getString(forKey: .appId,
                                     defaultValue: AppSettings.defaultAppId)
    }
    
    var regionCode: String {
        return AppSettings.getString(forKey: .regionCode,
                                     defaultValue: AppSettings.defaultRegionCode)
    }
    
    var customerIdentifier: String? {
        return AppSettings.getString(forKey: .customerIdentifier)
    }
    
    var authToken: String {
        return AppSettings.getString(forKey: .authToken,
                                     defaultValue: "asapp_ios_fake_access_token")
    }
    
    var userName: String {
        return AppSettings.getString(forKey: .userName,
                                     defaultValue: AppSettings.defaultUserName)
    }
    
    var userImageName: String {
        return AppSettings.getString(forKey: .userImageName,
                                     defaultValue: AppSettings.defaultUserImageName)
    }
    
    var branding: Branding {
        didSet {
            AppSettings.saveObject(branding.brandingType.rawValue, forKey: .brandingType)
        }
    }
    
    var userImageNames: [String] {
        return AppSettings.getDefaultImageNames()
    }
    
    var spearPin: String? {
        return AppSettings.getString(forKey: .spearPin)
    }
    
    var spearEnvironment: SpearEnvironment {
        if let savedValue = AppSettings.getString(forKey: .spearEnvironment),
            let savedEnvironment = SpearEnvironment(rawValue: savedValue) {
            return savedEnvironment
        }
        return SpearEnvironment.defaultValue
    }
    
    var tetrisPassword: String? {
        return AppSettings.getString(forKey: .tetrisPassword)
    }
    
    var tetrisEnvironment: TetrisEnvironment {
        if let savedValue = AppSettings.getString(forKey: .tetrisEnvironment),
            let savedEnvironment = TetrisEnvironment(rawValue: savedValue) {
            return savedEnvironment
        }
        return TetrisEnvironment.defaultValue
    }
    
    let versionString: String
    
    //
    // MARK: - Init
    //
    
    override init() {
        let brandingType = BrandingType.from(AppSettings.getString(forKey: .brandingType)) ?? AppSettings.defaultBrandingType
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

// MARK: - Defaults

fileprivate extension AppSettings {
    
    static let defaultAPIHostName = getDefaultAPIHostNames().first!
    
    static let defaultAppId = getDefaultAppIds().first!
    
    static let defaultRegionCode = getDefaultRegionCodes().first!
    
    static let defaultAuthToken = ""
    
    static let defaultUserName = "Jessie"
    
    static let defaultUserImageName = "user-anonymous"
    
    static let defaultBrandingType = BrandingType.asapp
    
    class func getDefaultAPIHostNames() -> [String] {
        return [
            "demo.asapp.com",
            "sprint.preprod.asapp.com",
            "comcast.preprod.asapp.com",
            "tetris.test.asapp.com"
        ]
    }
    
    class func getDefaultAppIds() -> [String] {
        return [
            "asapp",
            "boost",
            "comcast",
            "tetris"
        ]
    }
    
    class func getDefaultRegionCodes() -> [String] {
        return [
            "US",
            "AU"
        ]
    }
    
    class func getDefaultCustomerIdentifiers() -> [String] {
        return [
            "test_customer_1",
            "test_customer_2",
            "outage_soon",
            "appointment_soon",
            "new_customer",
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
            "+12122561114",
            "+14167622262"
        ]
    }
    
    class func getDefaultImageNames() -> [String] {
        return [
            "user-anonymous",
            "user-gustavo",
            "user-mitch",
            "user-alan",
            "user-joshua",
            "user-susan",
            "user-tim",
            "user-tony",
            "user-lori",
            "user-rachel",
            "user-max"
        ]
    }
}

// MARK: - Storage

extension AppSettings {
    
    class func deleteObject(forKey key: Key, async: Bool = false) {
        let saveBlock = {
            UserDefaults.standard.removeObject(forKey: key.rawValue)
            UserDefaults.standard.synchronize()
        }
        
        if async {
            DispatchQueue.global(qos: .background).async(execute: saveBlock)
        } else {
            saveBlock()
        }
    }
    
    class func saveObject(_ object: Any, forKey key: Key, async: Bool = false) {
        let saveBlock = {
            // DemoLog("Saving object: \(object), for key: \(key.rawValue), async = \(async)")
            
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
    
    class func deleteStringFromArray(_ stringValue: String, forKey key: Key) {
        var stringArray = getStringArray(forKey: key) ?? [String]()
        if let index = stringArray.index(of: stringValue) {
            stringArray.remove(at: index)
            saveObject(stringArray, forKey: key)
        }
    }
    
    class func getString(forKey key: Key, defaultValue: String) -> String {
        if let stringValue = UserDefaults.standard.string(forKey: key.rawValue) {
            // DemoLog("Found string: \(stringValue), for key: \(key.rawValue)")
            return stringValue
        }
        
        // DemoLog("Using default string: \(defaultValue), for key: \(key.rawValue)")
        saveObject(defaultValue, forKey: key)
        
        return defaultValue
    }
    
    class func getString(forKey key: Key) -> String? {
        let stringValue = UserDefaults.standard.string(forKey: key.rawValue)

        // DemoLog("Found string: \(stringValue ?? "nil"), for key: \(key.rawValue)")
        
        return stringValue
    }

    class func getStringArray(forKey key: Key) -> [String]? {
        let stringArray = UserDefaults.standard.stringArray(forKey: key.rawValue)
        
        // DemoLog("Found string array: \(String(describing: stringArray)), for key: \(key.rawValue)")
        
        return getDefaultStringArray(forKey: key)?.union(stringArray ?? [])
    }
    
    private class func getDefaultStringArray(forKey key: Key) -> [String]? {
        switch key {
        case .apiHostNameList: return getDefaultAPIHostNames()
        case .appIdList: return getDefaultAppIds()
        case .regionCodeList: return getDefaultRegionCodes()
        case .customerIdentifierList: return getDefaultCustomerIdentifiers()
        default: return nil
        }
    }
}

// MARK: - Custom Vaues

extension AppSettings {
    
    func addAPIHostName(_ value: String) {
        AppSettings.addStringToArray(value, forKey: .apiHostNameList)
    }
    
    func addAppId(_ value: String) {
        AppSettings.addStringToArray(value, forKey: .appIdList)
    }
    
    func addRegionCode(_ value: String) {
        AppSettings.addStringToArray(value, forKey: .regionCodeList)
    }
    
    func addCustomerIdentifier(_ value: String) {
        AppSettings.addStringToArray(value, forKey: .customerIdentifierList)
    }
    
    class func getRandomCustomerIdentifier() -> String {
        return "test-token-\(Int(Date().timeIntervalSince1970))"
    }
}

// MARK: - Auth + Context

extension AppSettings {
    
    func getContext() -> [String: Any] {
        return [
            ASAPP.authTokenKey: AppSettings.shared.authToken,
            "fake_context_key_1": "fake_context_value_1",
            "fake_context_key_2": "fake_context_value_2"
        ]
    }
}
