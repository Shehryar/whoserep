//
//  UIToolbarExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/28/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation
import UIKit

extension UIToolbar {
    static func createDefaultDoneBar(target: Any?, action: Selector?) -> UIToolbar {
        let toolbar = UIToolbar()
        toolbar.barStyle = .default
        let doneButton = UIBarButtonItem(title: ASAPPLocalizedString("Done"), style: .done, target: target, action: action)
        let space = UIBarButtonItem(barButtonSystemItem: .flexibleSpace, target: nil, action: nil)
        toolbar.items = [space, doneButton, space]
        toolbar.sizeToFit()
        return toolbar
    }
}
