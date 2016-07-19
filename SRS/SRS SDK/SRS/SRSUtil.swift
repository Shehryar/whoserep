//
//  SRSUtil.swift
//  SRS
//
//  Created by Vicky Sehrawat on 5/31/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

let framework = NSBundle(forClass: SRS.self)

func loadFonts() {
    loadFont("XFINITYSans-Reg", type: "otf")
    loadFont("XFINITYSansTT-Bold", type: "ttf")
    loadFont("XFINITYSansTT-BoldCond", type: "ttf")
}

func loadFont(name: String, type: String) {
    let path = framework.pathForResource(name, ofType: type)
    let data = NSData(contentsOfFile: path!)
    var err: Unmanaged<CFError>?
    let provider = CGDataProviderCreateWithCFData(data)
    if let font = CGFontCreateWithDataProvider(provider) {
        CTFontManagerRegisterGraphicsFont(font, &err)
        if err != nil {
            print(err)
        }
    }
}