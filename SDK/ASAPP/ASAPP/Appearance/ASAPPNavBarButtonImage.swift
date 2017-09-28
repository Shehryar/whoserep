//
//  ASAPPNavBarButtonImage.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

@objcMembers
public class ASAPPNavBarButtonImage: NSObject {
    
    // MARK: Properties
    
    public var image: UIImage
    
    public var size: CGSize
    
    public var insets: UIEdgeInsets
    
    // MARK: Init
    
    public init(image: UIImage, size: CGSize, insets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)) {
        self.image = image
        self.size = size
        self.insets = insets
        super.init()
    }
}
