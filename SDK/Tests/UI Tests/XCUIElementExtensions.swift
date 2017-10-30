//
//  XCUIElementExtensions.swift
//  UI Tests
//
//  Created by Hans Hyttinen on 10/25/17.
//  Copyright © 2017 ASAPP. All rights reserved.
//

import XCTest

extension XCUIElement {
    func forceTap() {
        if self.isHittable {
            tap()
        } else {
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0, dy:0))
            coordinate.tap()
        }
    }
}
