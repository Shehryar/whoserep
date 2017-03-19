//
//  SystemVersionChecker.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/19/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SystemVersionChecker: NSObject {
    
    class func majorVersion() -> Int {
        return ProcessInfo().operatingSystemVersion.majorVersion
    }
    
    class func is8orEarlier() -> Bool {
        return majorVersion() <= 8
    }
}
