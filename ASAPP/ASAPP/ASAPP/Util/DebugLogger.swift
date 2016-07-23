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
        print("\(message)\n")
    }
}

func DebugLogError(message: String) {
    if DebugLoggingEnabled {
        print("ERROR: \(message)\n")
    }
}

func DebugLogWarning(message: String) {
    if DebugLoggingEnabled {
        print("WARNING: \(message)\n")
    }
}
