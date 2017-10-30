//
//  IdentifiableTestCase.swift
//  Tests
//
//  Created by Hans Hyttinen on 10/25/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

protocol IdentifiableTestCase: class {
    static var testCaseIdentifier: String { get }
}
