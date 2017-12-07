//
//  Color.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 12/7/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

struct Color {
    typealias RGBA = (red: CGFloat, green: CGFloat, blue: CGFloat, alpha: CGFloat)
    
    var rgba: RGBA
}

extension Color {
    init?(uiColor: UIColor) {
        guard let components = uiColor.cgColor.components else {
            return nil
        }
        
        let red, green, blue, alpha: CGFloat
        
        if components.count == 2 {
            red = components[0]
            green = red
            blue = red
            alpha = components[1]
        } else {
            red = components[0]
            green = components[1]
            blue = components[2]
            alpha = components[3]
        }
        
        self.init(rgba: RGBA(red: red, green: green, blue: blue, alpha: alpha))
    }
    
    var uiColor: UIColor {
        return UIColor(red: rgba.red, green: rgba.green, blue: rgba.blue, alpha: rgba.alpha)
    }
}

extension Color: Codable {
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let red = try container.decode(CGFloat.self)
        let green = try container.decode(CGFloat.self)
        let blue = try container.decode(CGFloat.self)
        let alpha = try container.decode(CGFloat.self)
        rgba = RGBA(red: red, green: green, blue: blue, alpha: alpha)
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        try container.encode(rgba.red)
        try container.encode(rgba.green)
        try container.encode(rgba.blue)
        try container.encode(rgba.alpha)
    }
}

extension Color: Equatable {
    static func == (lhs: Color, rhs: Color) -> Bool {
        return lhs.rgba == rhs.rgba
    }
}

extension Color: Hashable {
    var hashValue: Int {
        return rgba.red.hashValue ^ rgba.green.hashValue ^ rgba.blue.hashValue ^ rgba.alpha.hashValue
    }
}
