//
//  SRSFillerView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/2/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSFillerView: UIView {

    var fillerSize: CGFloat = 16.0
    
    // MARK: Layout
    
    override func sizeThatFits(size: CGSize) -> CGSize {
        return CGSize(width: size.width, height: fillerSize)
    }
}
