//
//  Image.swift
//  ASAPPTest
//
//  Created by Hans Hyttinen on 12/7/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

struct Image {
    let id: String
    let uiImage: UIImage
}

extension Image: Codable {
    enum ImageError: Error {
        case couldNotDecode
        case couldNotEncode
    }
    
    init(from decoder: Decoder) throws {
        var container = try decoder.unkeyedContainer()
        let id = try container.decode(String.self)
        let data = try container.decode(Data.self)
        guard let image = UIImage(data: data) else {
            throw ImageError.couldNotDecode
        }
        
        self.id = id
        self.uiImage = image
    }
    
    func encode(to encoder: Encoder) throws {
        var container = encoder.unkeyedContainer()
        guard let data = UIImagePNGRepresentation(uiImage) else {
            throw ImageError.couldNotEncode
        }
        
        try container.encode(id)
        try container.encode(data)
    }
}
