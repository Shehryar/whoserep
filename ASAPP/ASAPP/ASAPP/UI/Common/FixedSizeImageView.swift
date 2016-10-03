//
//  FixedSizeImageView.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class FixedSizeImageView: UIImageView {

    var fixedImageSize: CGSize = CGSize.zero {
        didSet {
            invalidateIntrinsicContentSize()
        }
    }
    
    override var intrinsicContentSize : CGSize {
        return fixedImageSize
    }
}
