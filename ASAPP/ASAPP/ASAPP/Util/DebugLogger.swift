//
//  DebugLogger.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

var DebugLoggingEnabled = true

func DebugLog(message: String) {
    if DebugLoggingEnabled {
        print("[ASAPP] \(message)\n")
    }
}

func DebugLogError(message: String) {
    if DebugLoggingEnabled {
        print("[ASAPP] ERROR: \(message)\n")
    }
}

func DebugLogWarning(message: String) {
    if DebugLoggingEnabled {
        print("[ASAPP] WARNING: \(message)\n")
    }
}
