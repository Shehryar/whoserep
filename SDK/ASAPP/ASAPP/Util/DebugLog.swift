//
//  DebugLog.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

/**
 Represents the verbosity level of the debugging log.
 */
@objc public enum ASAPPLogLevel: Int {
    /// Silence.
    case none = 0
    
    /// Prints only errors.
    case errors = 1
    
    /// Prints only warnings.
    case warning = 2
    
    /// Prints most debugging information.
    case debug = 3
    
    /// The highest level. Prints everything, including very long messages.
    case info = 4
}

class DebugLog: NSObject {
    
    private class func getStringForLogLevel(_ logLevel: ASAPPLogLevel) -> String {
        switch logLevel {
        case .none: return "none"
        case .errors: return "errors"
        case .warning: return "warning"
        case .debug: return "debug"
        case .info: return "info"
        }
    }
    
    private class func getStringForClass(_ classObject: Any?) -> String? {
        guard let classObject = classObject else {
            return nil
        }
        return String(describing: type(of: classObject))
    }
    
    private class func log(classObject: Any? = nil, logLevel: ASAPPLogLevel, message: String) {
        guard ASAPP.debugLogLevel.rawValue >= logLevel.rawValue else {
            return
        }
        
        print("\(getStringForClass(classObject) ?? "ASAPP") [\(getStringForLogLevel(logLevel))]: \(message)\n")
    }
    
    // MARK: - Public API
    
    // Info
    class func i(caller: Any? = nil, _ messages: String...) {
        log(classObject: caller, logLevel: .info, message: messages.joined(separator: " "))
    }
    
    // Debug
    class func d(caller: Any? = nil, _ messages: String...) {
        log(classObject: caller, logLevel: .debug, message: messages.joined(separator: " "))
    }
    
    // Warning
    class func w(caller: Any? = nil, _ messages: String...) {
        log(classObject: caller, logLevel: .warning, message: messages.joined(separator: " "))
    }
    
    // Error
    class func e(caller: Any? = nil, _ messages: String...) {
        log(classObject: caller, logLevel: .errors, message: messages.joined(separator: " "))
    }
    
    class func e(caller: Any? = nil, _ error: Error) {
        log(classObject: caller, logLevel: .errors, message: error.localizedDescription)
    }
}
