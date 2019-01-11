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
        case pushServiceIdentifier = "asapp_push_service_identifier"
        
        case apiHostNameList = "asapp_api_host_name_list"
        case appIdList = "asapp_app_id_list"
        case regionCodeList = "asapp_region_code_list"
        case accountList = "asapp_account_list"
        case appearanceConfigList = "asapp_appearance_config_list"
        case mostRecentAccountPerApiHostNameAndAppId = "asapp_most_recent_account_dict"
    }
    
    // MARK: Shared Instance
    
    static let shared = AppSettings()
    
    // MARK: - Properties
    
    var apiHostName: String {
        return AppSettings.getString(forKey: .apiHostName, defaultValue: AppSettings.defaultAPIHostName)
    }
    
    var appId: String {
        return AppSettings.getString(forKey: .appId, defaultValue: AppSettings.defaultAppId).lowercased()
    }
    
    var regionCode: String {
        return AppSettings.getString(forKey: .regionCode, defaultValue: AppSettings.defaultRegionCode)
    }
    
    var customerIdentifier: String? {
        return AppSettings.getString(forKey: .customerIdentifier)
    }
    
    var authToken: String? {
        return AppSettings.getString(forKey: .authToken)
    }
    
    var pushServiceIdentifier: [String: Any] {
        return AppSettings.getDict(forKey: .pushServiceIdentifier, defaultValue: AppSettings.defaultPushIdentifier)
    }
    
    var branding = Branding(appearanceConfig: AppSettings.defaultAppearanceConfig)
    
    var appearanceConfig: AppearanceConfig {
        let decoder = JSONDecoder()
        guard let string = AppSettings.getString(forKey: .appearanceConfig),
              let data = string.data(using: .utf8),
              let config = try? decoder.decode(AppearanceConfig.self, from: data),
              config.isValid else {
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

extension AppSettings {
    
    static let defaultAPIHostName = defaultAPIHostNames.first!
    
    static let defaultAppId = defaultAppIds.first!
    
    static let defaultRegionCode = defaultRegionCodes.first!
    
    static let defaultAuthToken = ""
    
    static let defaultUserName = "Jessie"
    
    static let defaultUserImageName = "user-anonymous"
    
    static let defaultAppearanceConfig = defaultAppearanceConfigs.first!
    
    static let defaultPushIdentifier: [String: Any] = ["Service": 0, "key": "dummyToken"]
    
    class var defaultAPIHostNames: [String] {
        return [
            "demo.asapp.com",
            "sprint.preprod.asapp.com"
        ]
    }
    
    class var defaultAppIds: [String] {
        return [
            "asapp",
            "boost",
            "fios",
            "spectrum-cable",
            "spectrum-mobile",
            "company1",
            "company2",
            "company3",
            "company4",
            "company5",
            "company6",
            "company7",
            "company8",
            "company9"
        ]
    }
    
    class var defaultRegionCodes: [String] {
        return [
            "US"
        ]
    }
    
    class var defaultAccounts: [Account] {
        return [
            Account(username: "test_customer_1", password: nil),
            Account(username: "test_customer_2", password: nil),
            Account(username: "outage_soon", password: nil),
            Account(username: "appointment_soon", password: nil),
            Account(username: "new_customer", password: nil),
            Account(username: "+13126089137", password: nil),
            Account(username: "+13473040637", password: nil),
            Account(username: "+19179911056", password: nil),
            Account(username: "+19176646758", password: nil),
            Account(username: "+19084337447", password: nil),
            Account(username: "+19173708897", password: nil),
            Account(username: "+19173241544", password: nil),
            Account(username: "+17038638070", password: nil),
            Account(username: "+19134818010", password: nil),
            Account(username: "+16173317845", password: nil),
            Account(username: "+12152065821", password: nil),
            Account(username: "+12122561114", password: nil),
            Account(username: "+14167622262", password: nil)
        ]
    }
    
    class var defaultImageNames: [String] {
        return [
            "user-anonymous",
            "user-gustavo",
            "user-mitch",
            "user-joshua",
            "user-tony",
            "user-rachel",
            "user-max"
        ]
    }
    
    class var defaultAppearanceConfigs: [AppearanceConfig] {
        let boostOrange = Color(uiColor: UIColor(hexString: "#f7901e")!)!
        let telstraBlue = Color(uiColor: UIColor(red: 0, green: 0.6, blue: 0.89, alpha: 1))!
        let verizonBlue = Color(uiColor: UIColor(red: 0.22, green: 0.55, blue: 0.98, alpha: 1))!
        let spectrumBlue = Color(uiColor: UIColor(red: 0, green: 0.45, blue: 0.82, alpha: 1))!
        let spectrumNavy = Color(uiColor: UIColor(red: 0, green: 0.18, blue: 0.34, alpha: 1))!
        let black = Color(uiColor: .black)!
        
        return [
            AppearanceConfig.create(name: "ASAPP", brand: .asapp, logo: Image(id: "asapp", uiImage: #imageLiteral(resourceName: "asapp-logo")), colors: [:], strings: [:], fontFamilyName: .asapp),
            
            AppearanceConfig.create(name: "Spear", brand: .boost, logo: Image(id: "boost", uiImage: #imageLiteral(resourceName: "boost-logo-light")), colors: [
                .demoNavBar: black,
                .primary: boostOrange,
                .dark: black
            ], strings: [
                .helpButton: "CHAT"
            ], fontFamilyName: .system, segue: .present),
            
            AppearanceConfig.create(name: "Tetris", brand: .telstra, logo: Image(id: "telstra", uiImage: #imageLiteral(resourceName: "telstra-logo")), colors: [
                .primary: telstraBlue,
                .dark: black
            ], strings: [
                .chatTitle: "24x7 Chat"
            ], fontFamilyName: .asapp),
            
            AppearanceConfig.create(name: "Rome", brand: .verizon, logo: Image(id: "verizon", uiImage: #imageLiteral(resourceName: "fios-logo")), colors: [
                .primary: verizonBlue,
                .dark: black
            ], strings: [:], fontFamilyName: .system),
            
            AppearanceConfig.create(name: "Cairo", brand: .cairo, logo: Image(id: "cairo", uiImage: #imageLiteral(resourceName: "spectrum-mobile-logo")), colors: [
                .demoNavBar: spectrumNavy,
                .primary: spectrumBlue,
                .dark: spectrumNavy
            ], strings: [:], fontFamilyName: .system)
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
            DispatchQueue.global(qos: .utility).async(execute: saveBlock)
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
            DispatchQueue.global(qos: .utility).async(execute: saveBlock)
        } else {
            saveBlock()
        }
    }
    
    class func addStringToArray(_ stringValue: String, forKey key: Key) {
        var stringArray = getStringArray(forKey: key) ?? [String]()
        guard !stringArray.contains(stringValue) else {
            return
        }
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
    
    class func getDict(forKey key: Key, defaultValue: [String: Any]) -> [String: Any] {
        if let dictionary = UserDefaults.standard.dictionary(forKey: key.rawValue) {
            return dictionary
        }
        return defaultValue
    }
    
    class func getDefaultStringArray(forKey key: Key) -> [String]? {
        switch key {
        case .apiHostNameList: return defaultAPIHostNames
        case .appIdList: return defaultAppIds
        case .regionCodeList: return defaultRegionCodes
        case .accountList: return defaultAccounts.map {
            let encoder = JSONEncoder()
            guard let data = try? encoder.encode($0) else {
                return nil
            }
            return String.init(data: data, encoding: .utf8)
        }.compactMap { $0 }
        default: return nil
        }
    }
}

// MARK: - Generic Codable storage

extension AppSettings {
    class func addCodableToArray<T: Codable>(_ codable: T, key: Key) {
        let encoder = JSONEncoder()
        guard
            let data = try? encoder.encode(codable),
            let string = String.init(data: data, encoding: .utf8)
        else {
            return
        }
        addStringToArray(string, forKey: key)
    }
    
    class func getCodableArray<T: Codable>(key: Key, defaults: [T]) -> [T] {
        let stringArray = UserDefaults.standard.stringArray(forKey: key.rawValue)
        
        let codableArray = try? (stringArray?.map { (string: String) -> T? in
            let decoder = JSONDecoder()
            guard let data = string.data(using: .utf8) else {
                return nil
            }
            return try decoder.decode(T.self, from: data)
        } ?? []).compactMap { $0 }
        
        return defaults.union(codableArray ?? [])
    }
    
    class func saveCodable<T: Codable>(_ codable: T, key: Key) {
        let encoder = JSONEncoder()
        guard
            let data = try? encoder.encode(codable),
            let string = String.init(data: data, encoding: .utf8)
        else {
            return
        }
        saveObject(string, forKey: key)
    }
    
    class func clearCodableArray(key: Key) {
        saveObject("", forKey: key)
    }
    
    class func removeCodableFromArray<T: Codable & Equatable>(_ codable: T, key: Key) {
        guard let stringArray = UserDefaults.standard.stringArray(forKey: key.rawValue) else {
            return
        }
        
        let codableArray = try? stringArray.map { (string: String) -> T? in
            let decoder = JSONDecoder()
            guard let data = string.data(using: .utf8) else {
                return nil
            }
            return try decoder.decode(T.self, from: data)
        }.compactMap { $0 }
        
        let filteredArray = codableArray?.filter { $0 != codable }
        let encoder = JSONEncoder()
        let encodedArray: [String] = (filteredArray?.map { config in
            guard
                let data = try? encoder.encode(config),
                let string = String.init(data: data, encoding: .utf8)
            else {
                return ""
            }
            return string
        } ?? []).compactMap { $0 }
        
        saveObject(encodedArray, forKey: key)
    }
}

// MARK: - Appearance Config storage

extension AppSettings {
    class func getAppearanceConfigArray() -> [AppearanceConfig] {
        return getCodableArray(key: .appearanceConfigList, defaults: defaultAppearanceConfigs).filter {
            $0.isValid
        }
    }
    
    class func clearAppearanceConfigArray() {
        clearCodableArray(key: .appearanceConfigList)
    }
    
    class func addAppearanceConfigToArray(_ appearanceConfig: AppearanceConfig) {
        addCodableToArray(appearanceConfig, key: .appearanceConfigList)
    }
    
    class func removeAppearanceConfigFromArray(_ appearanceConfig: AppearanceConfig) {
        removeCodableFromArray(appearanceConfig, key: .appearanceConfigList)
    }
    
    class func saveAppearanceConfig(_ appearanceConfig: AppearanceConfig) {
        saveCodable(appearanceConfig, key: .appearanceConfig)
    }
}

// MARK: - Account storage

extension AppSettings {
    class func getAccountArray() -> [Account] {
        return getCodableArray(key: .accountList, defaults: defaultAccounts)
    }
    
    class func clearAccountArray() {
        clearCodableArray(key: .accountList)
    }
    
    class func addAccountToArray(_ account: Account) {
        addCodableToArray(account, key: .accountList)
    }
    
    class func removeAccountFromArray(_ account: Account) {
        removeCodableFromArray(account, key: .accountList)
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
    
    class func getRandomCustomerIdentifier() -> String {
        return "test-token-\(Int(Date().timeIntervalSince1970))"
    }
}

// MARK: - Most Recent Account storage

extension AppSettings {
    private static func mostRecentAccountKey(appId: String, apiHostName: String) -> String {
        return [appId, apiHostName].joined(separator: ",")
    }
    
    class func setMostRecentAccount(_ account: Account, appId: String, apiHostName: String) {
        let key = Key.mostRecentAccountPerApiHostNameAndAppId
        let accountKey = mostRecentAccountKey(appId: appId, apiHostName: apiHostName)
        let dict = UserDefaults.standard.dictionary(forKey: key.rawValue) as? [String: String]
        let newDict: [String: String]
        
        let encoder = JSONEncoder()
        guard
            let data = try? encoder.encode(account),
            let string = String.init(data: data, encoding: .utf8)
        else {
            return
        }
        
        if var dict = dict {
            dict[accountKey] = string
            newDict = dict
        } else {
            newDict = [accountKey: string]
        }
        
        saveObject(newDict, forKey: key)
    }
    
    class func getMostRecentAccount(appId: String, apiHostName: String) -> Account? {
        guard
            let dict = UserDefaults.standard.dictionary(forKey: Key.mostRecentAccountPerApiHostNameAndAppId.rawValue),
            let string = dict[mostRecentAccountKey(appId: appId, apiHostName: apiHostName)] as? String
        else {
            return nil
        }
        
        let decoder = JSONDecoder()
        guard let data = string.data(using: .utf8) else {
            return nil
        }
        return try? decoder.decode(Account.self, from: data)
    }
    
    class func clearMostRecentAccount(appId: String, apiHostName: String) {
        let key = Key.mostRecentAccountPerApiHostNameAndAppId
        let accountKey = mostRecentAccountKey(appId: appId, apiHostName: apiHostName)
        let dict = UserDefaults.standard.dictionary(forKey: key.rawValue) as? [String: String]
        let newDict: [String: String]
        
        if var dict = dict {
            dict.removeValue(forKey: accountKey)
            newDict = dict
        } else {
            newDict = [:]
        }
        
        saveObject(newDict, forKey: key)
    }
}

// MARK: - Auth + Context

extension AppSettings {
    
    func getContext() -> [String: Any] {
        if let token = AppSettings.shared.authToken {
            return [
                ASAPP.authTokenKey: token,
                "fake_context_key_1": "fake_context_value_1",
                "fake_context_key_2": "fake_context_value_2"
            ]
        } else {
            return [:]
        }
        
    }
}
