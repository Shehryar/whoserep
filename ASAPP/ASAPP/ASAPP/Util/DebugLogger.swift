//
//  DebugLogger.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

func DebugLog(_ message: String) {
    if DEBUG_LOG_LEVEL == .Debug {
        NSLog("[ASAPP] \(message)\n")
    }
}

func DebugLogError(_ message: String) {
    if DEBUG_LOG_LEVEL == .Debug || DEBUG_LOG_LEVEL == .Errors {
        NSLog("[ASAPP] ERROR: \(message)\n")
    }
}
