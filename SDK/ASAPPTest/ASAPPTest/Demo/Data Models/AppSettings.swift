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
        case appearanceConfig = "asapp_appearance_config"
        
        case apiHostNameList = "asapp_api_host_name_list"
        case appIdList = "asapp_app_id_list"
        case regionCodeList = "asapp_region_code_list"
        case customerIdentifierList = "asapp_customer_identifier_list"
        case appearanceConfigList = "asapp_appearance_config_list"
        
        case spearPin = "asapp_spear_pin"
        case spearEnvironment = "asapp_spear_environment"
        
        case tetrisPassword = "asapp_tetris_password"
        case tetrisEnvironment = "asapp_tetris_environment"
    }
    
    // MARK: Shared Instance
    
    static let shared = AppSettings()
    
    // MARK: - Properties
    
    var apiHostName: String {
        return AppSettings.getString(forKey: .apiHostName, defaultValue: AppSettings.defaultAPIHostName)
    }
    
    var appId: String {
        return AppSettings.getString(forKey: .appId, defaultValue: AppSettings.defaultAppId)
    }
    
    var regionCode: String {
        return AppSettings.getString(forKey: .regionCode, defaultValue: AppSettings.defaultRegionCode)
    }
    
    var customerIdentifier: String? {
        return AppSettings.getString(forKey: .customerIdentifier)
    }
    
    var authToken: String {
        return AppSettings.getString(forKey: .authToken, defaultValue: "asapp_ios_fake_access_token")
    }
    
    var branding = Branding(appearanceConfig: AppSettings.defaultAppearanceConfig)
    
    var appearanceConfig: AppearanceConfig {
        let decoder = JSONDecoder()
        guard let string = AppSettings.getString(forKey: .appearanceConfig),
              let data = string.data(using: .utf8),
              let config = try? decoder.decode(AppearanceConfig.self, from: data) else {
            return AppSettings.defaultAppearanceConfig
        }
        return config
    }
    
    var userName: String {
        return AppSettings.getString(forKey: .userName, defaultValue: AppSettings.defaultUserName)
    }
    
    var userImageName: String {
        return AppSettings.getString(forKey: .userImageName, defaultValue: AppSettings.defaultUserImageName)
    }
    
    var userImageNames: [String] {
        return AppSettings.defaultImageNames
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
    
    // MARK: - Init
    
    override init() {
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
    
    static let defaultAPIHostName = defaultAPIHostNames.first!
    
    static let defaultAppId = defaultAppIds.first!
    
    static let defaultRegionCode = defaultRegionCodes.first!
    
    static let defaultAuthToken = ""
    
    static let defaultUserName = "Jessie"
    
    static let defaultUserImageName = "user-anonymous"
    
    static let defaultAppearanceConfig = defaultAppearanceConfigs.first!
    
    class var defaultAPIHostNames: [String] {
        return [
            "demo.asapp.com",
            "sprint.preprod.asapp.com",
            "tetris.test.asapp.com"
        ]
    }
    
    class var defaultAppIds: [String] {
        return [
            "asapp",
            "boost",
            "tetris"
        ]
    }
    
    class var defaultRegionCodes: [String] {
        return [
            "US",
            "AU"
        ]
    }
    
    class var defaultCustomerIdentifiers: [String] {
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
    
    class var defaultImageNames: [String] {
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
    
    class var defaultAppearanceConfigs: [AppearanceConfig] {
        let boostOrange = Color(uiColor: UIColor(hexString: "#f7901e")!)!
        let boostGrey = Color(uiColor: UIColor(hexString: "#373737")!)!
        let telstraBlue = Color(uiColor: UIColor(red: 0, green: 0.6, blue: 0.89, alpha: 1))!
        let black = Color(uiColor: .black)!
        let white = Color(uiColor: .white)!
        
        return [
            AppearanceConfig(name: "ASAPP", brand: .asapp, logo: Image(id: "asapp", uiImage: #imageLiteral(resourceName: "asapp-logo")), colors: [:], strings: [
                .helpButton: "HELP"
            ], fontFamilyName: .asapp),
            
            AppearanceConfig(name: "Spear", brand: .boost, logo: Image(id: "boost", uiImage: #imageLiteral(resourceName: "boost-logo-light")), colors: [
                .demoNavBar: Color(uiColor: UIColor(white: 0.01, alpha: 1))!,
                .brandPrimary: boostOrange,
                .brandSecondary: boostGrey,
                .textDark: black,
                .textLight: white
            ], strings: [
                .helpButton: "CHAT"
            ], fontFamilyName: .boost),
            
            AppearanceConfig(name: "Tetris", brand: .telstra, logo: Image(id: "telstra", uiImage: #imageLiteral(resourceName: "telstra-logo")), colors: [
                .brandPrimary: telstraBlue,
                .brandSecondary: telstraBlue,
                .textDark: black,
                .textLight: white
            ], strings: [
                .helpButton: "HELP",
                .chatTitle: "24x7 Chat",
                .predictiveTitle: "24x7 Chat"
            ], fontFamilyName: .asapp)
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
        
        return (getDefaultStringArray(forKey: key) ?? []).union(stringArray ?? [])
    }
    
    private class func getDefaultStringArray(forKey key: Key) -> [String]? {
        switch key {
        case .apiHostNameList: return defaultAPIHostNames
        case .appIdList: return defaultAppIds
        case .regionCodeList: return defaultRegionCodes
        case .customerIdentifierList: return defaultCustomerIdentifiers
        default: return nil
        }
    }
}

// MARK: - Appearance Config Storage

extension AppSettings {
    class func getAppearanceConfigArray() -> [AppearanceConfig] {
        let stringArray = UserDefaults.standard.stringArray(forKey: AppSettings.Key.appearanceConfigList.rawValue)
        
        let appearanceConfigArray = try? (stringArray?.map { (string: String) -> AppearanceConfig? in
            let decoder = JSONDecoder()
            guard let data = string.data(using: .utf8) else {
                return nil
            }
            return try decoder.decode(AppearanceConfig.self, from: data)
        } ?? []).flatMap { $0 }
        
        return defaultAppearanceConfigs.union(appearanceConfigArray ?? [])
    }
    
    class func addAppearanceConfigToArray(_ appearanceConfig: AppearanceConfig) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(appearanceConfig),
              let string = String.init(data: data, encoding: .utf8) else {
            return
        }
        addStringToArray(string, forKey: .appearanceConfigList)
    }
    
    class func removeAppearanceConfigFromArray(_ appearanceConfig: AppearanceConfig) {
        let key = AppSettings.Key.appearanceConfigList
        guard let stringArray = UserDefaults.standard.stringArray(forKey: key.rawValue) else {
            return
        }
        
        let appearanceConfigArray = try? stringArray.map { (string: String) -> AppearanceConfig? in
            let decoder = JSONDecoder()
            guard let data = string.data(using: .utf8) else {
                return nil
            }
            return try decoder.decode(AppearanceConfig.self, from: data)
        }.flatMap { $0 }
        
        let filteredArray = appearanceConfigArray?.filter { $0 != appearanceConfig }
        let encoder = JSONEncoder()
        let encodedArray: [String] = (filteredArray?.map { config in
            guard let data = try? encoder.encode(config),
                  let string = String.init(data: data, encoding: .utf8) else {
                return ""
            }
            return string
        } ?? []).flatMap { $0 }
        
        saveObject(encodedArray, forKey: key)
    }
    
    class func saveAppearanceConfig(_ appearanceConfig: AppearanceConfig) {
        let encoder = JSONEncoder()
        guard let data = try? encoder.encode(appearanceConfig),
              let string = String.init(data: data, encoding: .utf8) else {
            return
        }
        saveObject(string, forKey: .appearanceConfig)
    }
}

// MARK: - Custom Values

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
