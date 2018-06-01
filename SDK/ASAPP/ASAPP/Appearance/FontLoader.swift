//
//  FontLoader.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 9/27/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import CoreGraphics
import CoreText
import Foundation
import UIKit

internal class FontLoader {
    private enum SupportedFontExtensions: String {
        case trueTypeFont = ".ttf"
        case openTypeFont = ".otf"
    }
    
    private typealias FontPath = String
    private typealias FontName = String
    private typealias FontExtension = String
    private typealias Font = (path: FontPath, name: FontName, ext: FontExtension)
    
    class func load(bundle: Bundle = Bundle.main, completion: (([String]) -> Void)? = nil) {
        let path = bundle.bundlePath
        let loadedFonts = loadFontsForBundle(withPath: path)
        completion?(Array(loadedFonts))
    }
}

/// :nodoc:
extension FontLoader {
    private class var existingFonts: [FontName] {
        var fontNames = [FontName]()
        for family in UIFont.familyNames {
            for font in UIFont.fontNames(forFamilyName: family) {
                fontNames.append(font)
            }
        }
        return fontNames
    }
    
    private class func loadFontsForBundle(withPath path: String) -> Set<String> {
        var loaded: Set<String> = []
        
        do {
            let fileNames = try FileManager.default.contentsOfDirectory(atPath: path) as [String]
            let foundFonts = fonts(fromPath: path, withFileNames: fileNames)
            let existing = existingFonts
            if !foundFonts.isEmpty {
                for font in foundFonts
                where !existing.contains(font.name) {
                    if let loadedName = loadFont(font: font) {
                        loaded.insert(loadedName)
                    }
                }
            } else {
                DebugLog.e("No fonts were found in the bundle path: \(path).")
            }
        } catch {
            DebugLog.e("There was an error loading fonts from the bundle. \nPath: \(path).\nError: \(error)")
        }
        
        return loaded
    }
    
    private class func loadFont(font: Font) -> String? {
        let fontPath: FontPath = font.path
        let fontName: FontName = font.name
        let fontExtension: FontExtension = font.ext
        let fontFileURL = URL(fileURLWithPath: fontPath).appendingPathComponent(fontName).appendingPathExtension(fontExtension)
        
        var fontError: Unmanaged<CFError>?
        if let fontData = try? Data(contentsOf: fontFileURL) as CFData,
        let dataProvider = CGDataProvider(data: fontData) {
            _ = UIFont()
            if let fontRef = CGFont(dataProvider),
            CTFontManagerRegisterGraphicsFont(fontRef, &fontError),
            let postScriptName = fontRef.postScriptName {
                return String(postScriptName)
            } else if let fontError = fontError?.takeRetainedValue() {
                let errorDescription = CFErrorCopyDescription(fontError)
                DebugLog.e("Failed to load font '\(fontName)': \(String(describing: errorDescription))")
            }
        } else {
            guard let fontError = fontError?.takeRetainedValue() else {
                DebugLog.e("Failed to load font '\(fontName)'")
                return nil
            }
            
            let errorDescription = CFErrorCopyDescription(fontError)
            DebugLog.e("Failed to load font '\(fontName)': \(String(describing: errorDescription))")
        }
        
        return nil
    }
    
    private class func fonts(fromPath path: String, withFileNames fileNames: [String]) -> [Font] {
        var fonts = [Font]()
        
        for name in fileNames
        where name.contains(SupportedFontExtensions.trueTypeFont.rawValue)
        || name.contains(SupportedFontExtensions.openTypeFont.rawValue) {
            let parsedFont = FontLoader.font(fromName: name)
            let font: Font = (path, parsedFont.0, parsedFont.1)
            fonts.append(font)
        }
        
        return fonts
    }
    
    private class func font(fromName name: String) -> (FontName, FontExtension) {
        let components = name.split { $0 == "." }.map { String($0) }
        return (components[0], components[1])
    }
}
