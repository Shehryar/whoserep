//
//  ASAPPCustomImage.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/6/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

/**
 Used to define an icon for a button.
 */
@objc(ASAPPCustomImage)
@objcMembers
public class ASAPPCustomImage: NSObject {
    
    // MARK: Properties
    
    /// The button image.
    public var image: UIImage
    
    /// The size of the image.
    public var size: CGSize
    
    /// The insets of the button.
    public var insets: UIEdgeInsets
    
    // MARK: Init
    
    /**
     Creates an instance of `ASAPPCustomImage` with the given parameters.
     
     - parameter image: The button image.
     - parameter size: The size of the image.
     - parameter insets: The button insets. Optional.
     */
    public init(image: UIImage, size: CGSize, insets: UIEdgeInsets = UIEdgeInsets(top: 4, left: 0, bottom: 4, right: 0)) {
        self.image = image
        self.size = size
        self.insets = insets
        super.init()
    }
}
