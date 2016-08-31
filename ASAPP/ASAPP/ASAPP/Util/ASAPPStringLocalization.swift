//
//  ASAPPStringLocalization.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

func ASAPPLocalizedString(key: String, comment: String? = nil) -> String {
    return NSLocalizedString(key, tableName: nil, bundle: ASAPPBundle, comment: comment ?? "")
}
