//
//  DebugLogger.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/22/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

func DebugLog(_ message: String) {
    if ASAPP.debugLogLevel == .debug {
        NSLog("[ASAPP] \(message)\n")
    }
}

func DebugLogError(_ message: String) {
    if ASAPP.debugLogLevel == .debug || ASAPP.debugLogLevel == .errors {
        NSLog("[ASAPP] ERROR: \(message)\n")
    }
}
