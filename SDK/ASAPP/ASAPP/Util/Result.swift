//
//  Result.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 10/9/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

enum Result<V, E: Error> {
    case success(V)
    case failure(E)
}
