//
//  UILabelExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 10/26/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

extension UILabel {
    var numberOfVisibleLines: Int {
        let size = sizeThatFits(CGSize(width: frame.size.width, height: CGFloat.greatestFiniteMagnitude))
        return Int(max(size.height / font.lineHeight, 0))
    }
}
