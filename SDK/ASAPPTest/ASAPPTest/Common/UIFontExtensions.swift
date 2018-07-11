//
//  UIFontExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 7/10/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import UIKit

extension UIFont {
    func changingOnlySize(_ size: CGFloat) -> UIFont {
        return UIFont(descriptor: self.fontDescriptor, size: size)
    }
}
