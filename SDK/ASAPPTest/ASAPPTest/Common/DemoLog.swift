//
//  DemoLog.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

func demoLog(_ message: String) {
    print("[ASAPP TEST] \(message)\n")
}

func demoLog(_ messages: String...) {
    print("[ASAPP TEST] \(messages.joined(separator: " "))\n")
}