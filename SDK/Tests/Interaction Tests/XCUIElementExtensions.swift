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
            let coordinate: XCUICoordinate = self.coordinate(withNormalizedOffset: CGVector(dx: 0, dy: 0))
            coordinate.tap()
        }
    }
    
    func scrollToElement() {
        while !isVisible {
           XCUIApplication().swipeUp()
        }
    }
    
    var isVisible: Bool {
        guard exists && !frame.isEmpty else { return false }
        return XCUIApplication().windows.element(boundBy: 0).frame.contains(frame)
    }
}

extension XCTestCase {
    @discardableResult func findElementContaining(type: XCUIElement.ElementType, name: String) -> XCUIElement {
        let elements = XCUIApplication().descendants(matching: type).containing(type, identifier: name)
        return elements.element(boundBy: 0)
    }
}
