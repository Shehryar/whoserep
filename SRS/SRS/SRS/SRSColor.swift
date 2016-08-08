//
//  File.swift
//  SRS
//
//  Created by Vicky Sehrawat on 6/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

class SRSColor: NSObject {
    static let frameworkBundle = NSBundle(forClass: SRSContent.self)
    
    static let buttonNormalBg = UIColor(red: 227/255, green: 230/255, blue: 237/255, alpha: 1)
    static let buttonDarkBg = UIColor(red: 121/255, green: 127/255, blue: 144/255, alpha: 1)
    static let buttonLightBg = UIColor(red: 248/255, green: 249/255, blue: 252/255, alpha: 1)
    static let buttonDisabledBg = UIColor(patternImage: UIImage(named: "dash", inBundle: SRSColor.frameworkBundle, compatibleWithTraitCollection: nil)!)
    
    static let buttonNormalText = UIColor(red: 121/255, green: 127/255, blue: 144/255, alpha: 1)
    static let buttonDarkText = UIColor.whiteColor()
    static let buttonLightText = UIColor(red: 121/255, green: 127/255, blue: 144/255, alpha: 1)
    static let buttonDisabledText = UIColor(red: 121/255, green: 127/255, blue: 144/255, alpha: 0.4)
    
    static let label = UIColor(red: 91/255, green: 101/255, blue: 126/255, alpha: 1)
    static let key = UIColor(red: 121/255, green: 127/255, blue: 144/255, alpha: 1)
    static let value = UIColor(red: 91/255, green: 101/255, blue: 126/255, alpha: 1)
    static let valueRed = UIColor(red: 237/255, green: 102/255, blue: 85/255, alpha: 1)
    static let valueGreen = UIColor(red: 79/255, green: 190/255, blue: 30/255, alpha: 1)
}