//
//  URLExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 10/8/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

extension URL {
    func replacingPath(with path: String) -> URL? {
        guard var components = URLComponents(url: self, resolvingAgainstBaseURL: false) else {
            return nil
        }
        
        components.path = path
        return components.url
    }
}
