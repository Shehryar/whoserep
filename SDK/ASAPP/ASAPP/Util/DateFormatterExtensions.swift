//
//  DateFormatterExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/28/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

extension DateFormatter {
    func date(from string: String?) -> Date? {
        if let string = string {
            return date(from: string)
        } else {
            return nil
        }
    }
}
