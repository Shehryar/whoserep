//
//  UIGestureRecognizerExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 12/6/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation
import UIKit

extension UIGestureRecognizer {
    func gestureWas(in view: UIView) -> Bool {
        let point = location(in: view)
        return view.bounds.contains(point)
    }
}
