//
//  DebugLogger.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

func DebugLogInfo(_ message: String) {
    if ASAPP.debugLogLevel.rawValue >= ASAPPLogLevel.info.rawValue {
        print("[ASAPP] Info: \(message)\n")
    }
}

func DebugLog(_ message: String) {
    if ASAPP.debugLogLevel.rawValue >= ASAPPLogLevel.debug.rawValue {
        print("[ASAPP] \(message)\n")
    }
}

func DebugLogError(_ message: String) {
    if ASAPP.debugLogLevel == .debug || ASAPP.debugLogLevel == .errors {
        print("[ASAPP] ERROR: \(message)\n")
    }
}


