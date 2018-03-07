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
        NSTimeZone.default = TimeZone(identifier: "America/New_York")!
        let config = ASAPPConfig(appId: "test", apiHostName: "test.example.com", clientSecret: "test")
        ASAPP.initialize(with: config)
        ASAPP.user = ASAPPUser(userIdentifier: "test", requestContextProvider: {
            return [:]
        })
    }
    
    @discardableResult
    class func createStyle() -> ComponentStyle {
        ASAPP.styles = ASAPPStyles()
        ASAPP.styles.textStyles.body = ASAPPTextStyle(font: Fonts.default.regular, size: 15, letterSpacing: 0.5, color: .blue)
        ASAPP.styles.colors.controlSecondary = .blue
        ASAPP.styles.colors.controlTint = .brown
        
        ASAPP.styles.colors.navBarBackground = UIColor.white
        ASAPP.styles.colors.navBarTitle = UIColor(red: 57.0 / 255.0, green: 61.0 / 255.0, blue: 71.0 / 255.0, alpha: 0.95)
        ASAPP.styles.colors.navBarButton = UIColor(red: 0.355, green: 0.394, blue: 0.494, alpha: 1)
        ASAPP.styles.colors.navBarButtonForeground = UIColor(red: 0.264, green: 0.278, blue: 0.316, alpha: 1)
        ASAPP.styles.colors.navBarButtonBackground = UIColor(red: 0.866, green: 0.878, blue: 0.907, alpha: 1)
        ASAPP.styles.colors.backgroundPrimary = UIColor.white
        ASAPP.styles.colors.backgroundSecondary = UIColor(red: 0.972, green: 0.969, blue: 0.968, alpha: 1)
        ASAPP.styles.colors.textPrimary = UIColor(red: 57.0 / 255.0, green: 61.0 / 255.0, blue: 71.0 / 255.0, alpha: 1)
        ASAPP.styles.colors.textSecondary = UIColor(red: 0.42, green: 0.43, blue: 0.45, alpha: 1)
        ASAPP.styles.colors.separatorPrimary = UIColor(red: 0.59, green: 0.60, blue: 0.62, alpha: 1)
        ASAPP.styles.colors.separatorSecondary = UIColor(red: 0.816, green: 0.824, blue: 0.847, alpha: 0.5)
        ASAPP.styles.colors.controlSelectedBackground = UIColor(red: 0.953, green: 0.957, blue: 0.965, alpha: 1)
        ASAPP.styles.colors.positiveSelectedBackground = UIColor(red: 0.11, green: 0.65, blue: 0.43, alpha: 1)
        ASAPP.styles.colors.negativeSelectedBackground = UIColor(red: 0.82, green: 0.11, blue: 0.26, alpha: 1)
        ASAPP.styles.colors.textButtonPrimary = ASAPPButtonColors(textColor: UIColor(red: 0.125, green: 0.714, blue: 0.931, alpha: 1))
        ASAPP.styles.colors.textButtonSecondary = ASAPPButtonColors(textColor: UIColor(red: 0.663, green: 0.686, blue: 0.733, alpha: 1))
        ASAPP.styles.colors.buttonPrimary = ASAPPButtonColors(backgroundColor: UIColor(red: 0.204, green: 0.698, blue: 0.925, alpha: 1))
        ASAPP.styles.colors.buttonSecondary = ASAPPButtonColors(
            backgroundNormal: UIColor(red: 0.953, green: 0.957, blue: 0.965, alpha: 1),
            backgroundHighlighted: UIColor(red: 0.903, green: 0.907, blue: 0.915, alpha: 1),
            backgroundDisabled: UIColor(red: 0.6, green: 0.6, blue: 0.6, alpha: 1),
            textNormal: UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 1.0),
            textHighlighted: UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 1),
            textDisabled: UIColor(red: 0.357, green: 0.396, blue: 0.494, alpha: 0.8),
            border: UIColor(red: 0.886, green: 0.890, blue: 0.906, alpha: 1))
        
        ASAPP.styles.colors.messagesListBackground = UIColor.ASAPP.alabasterWhite
        ASAPP.styles.colors.messageText = UIColor(red: 0.476, green: 0.498, blue: 0.565, alpha: 1)
        ASAPP.styles.colors.messageBackground = UIColor.white
        ASAPP.styles.colors.messageBorder = UIColor(red: 0.86, green: 0.87, blue: 0.88, alpha: 1)
        ASAPP.styles.colors.replyMessageText = UIColor(red: 0.264, green: 0.278, blue: 0.316, alpha: 1)
        ASAPP.styles.colors.replyMessageBackground = UIColor(red: 0.92, green: 0.93, blue: 0.94, alpha: 1)
        ASAPP.styles.colors.replyMessageBorder = UIColor(red: 0.80, green: 0.81, blue: 0.84, alpha: 1)
        ASAPP.styles.colors.quickRepliesBackground = UIColor(red: 0.98, green: 0.98, blue: 0.98, alpha: 1)
        ASAPP.styles.colors.quickReplyButton = ASAPPButtonColors(
            backgroundColor: UIColor(red: 0.972, green: 0.969, blue: 0.968, alpha: 1),
            textColor: UIColor(red: 91.0 / 255.0, green: 101.0 / 255.0, blue: 126.0 / 255.0, alpha: 1))
        
        ASAPP.styles.colors.chatInput = ASAPPInputColors(
            background: UIColor.white,
            text: UIColor(red: 0.283, green: 0.290, blue: 0.307, alpha: 1),
            placeholderText: UIColor(red: 0.535, green: 0.557, blue: 0.586, alpha: 1),
            tint: UIColor(red: 0.682, green: 0.682, blue: 0.682, alpha: 1),
            border: UIColor(red: 0.937, green: 0.945, blue: 0.949, alpha: 1),
            primaryButton: UIColor(red: 0.476, green: 0.498, blue: 0.565, alpha: 1),
            secondaryButton: UIColor(red: 0.535, green: 0.557, blue: 0.586, alpha: 1))
        
        ASAPP.styles.colors.helpButtonText = UIColor.white
        ASAPP.styles.colors.helpButtonBackground = UIColor(red: 0.374, green: 0.392, blue: 0.434, alpha: 1)
        
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
