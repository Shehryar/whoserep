//
//  TestUtil.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/25/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit
@testable import ASAPP

class TestUtil: NSObject {
    
    static let bundle = Bundle(for: TestUtil.self)
    
    // MARK: - JSON

    class func dictForFile(named fileName: String) -> [String: Any]? {
        guard let filePath = bundle.path(forResource: fileName, ofType: "json") else {
            log(caller: self, "Unable to generate filePath for file named: \(fileName)")
            return nil
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            log(caller: self, "Unable to parse data from file with path: \(filePath)")
            return nil
        }
        
        guard let dict = try? JSONSerialization.jsonObject(with: data, options: .allowFragments) as? [String: Any] else {
            log(caller: self, "Unable to parse JSON from data")
            return nil
        }
        
        return dict
    }
    
    class func stringForFile(named fileName: String) -> String? {
        guard let filePath = bundle.path(forResource: fileName, ofType: "json") else {
            log(caller: self, "Unable to generate filePath for file named: \(fileName)")
            return nil
        }
        
        guard let data = try? Data(contentsOf: URL(fileURLWithPath: filePath)) else {
            log(caller: self, "Unable to parse data from file with path: \(filePath)")
            return nil
        }
        
        guard let string = String(data: data, encoding: .utf8) else {
            log(caller: self, "Unable to parse string from data")
            return nil
        }
        
        return string
    }
    
    // MARK: - Logging
    
    class func log(caller: Any? = nil, _ message: String) {
        
        let prefix: String
        if let caller = caller {
            prefix = "ASAPPTests [\(String(describing: type(of: caller)))"
        } else {
            prefix = "ASAPPTests"
        }

        print("\(prefix): \(message)")
    }
    
    // MARK: - Test config
    
    class func setUpASAPP() {
        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test")
        ASAPP.initialize(with: config)
        ASAPP.user = ASAPPUser(userIdentifier: "test", requestContextProvider: {
            return [:]
        }, userLoginHandler: { _ in })
    }
    
    class func createStyle() -> ComponentStyle {
        ASAPP.styles = ASAPPStyles()
        ASAPP.styles.textStyles.body = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.5, color: .blue)
        ASAPP.styles.colors.controlSecondary = .blue
        ASAPP.styles.colors.controlTint = .brown
        
        var style = ComponentStyle()
        style.alignment = .center
        style.backgroundColor = .white
        style.borderColor = .red
        style.borderWidth = 1
        style.color = .blue
        style.cornerRadius = 10
        style.fontSize = 22
        style.letterSpacing = 0.5
        style.margin = UIEdgeInsets(top: 5, left: 5, bottom: 5, right: 5)
        style.padding = UIEdgeInsets(top: 15, left: 15, bottom: 15, right: 15)
        style.textType = .body
        
        return style
    }
}
