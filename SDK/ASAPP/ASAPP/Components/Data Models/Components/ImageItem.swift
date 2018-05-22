//
//  ImageItem.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 5/16/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

class ImageItem: Component {
    enum ScaleType: String {
        case aspectFit
        case aspectFill
    }
    
    enum JSONKey: String {
        case url
        case scaleType
        case description
    }
    
    override var viewClass: UIView.Type {
        return ImageView.self
    }
    
    let url: URL
    private(set) var scaleType = ScaleType.aspectFit
    private(set) var descriptionText = ""
    
    required init?(id: String? = nil,
                   name: String? = nil,
                   value: Any? = nil,
                   isChecked: Bool? = nil,
                   isRequired: Bool? = nil,
                   style: ComponentStyle,
                   styles: [String: Any]? = nil,
                   content: [String: Any]? = nil) {
        
        guard let urlString = content?.string(for: JSONKey.url.rawValue),
              let url = URL(string: urlString) else {
            DebugLog.w(caller: ImageItem.self, "Missing URL: \(String(describing: content))")
            return nil
        }
        self.url = url
        
        if let scaleTypeString = content?.string(for: JSONKey.scaleType.rawValue), let scaleType = ScaleType(rawValue: scaleTypeString) {
            self.scaleType = scaleType
        }
        
        if let description = content?.string(for: JSONKey.description.rawValue) {
            self.descriptionText = description
        }
        
        super.init(id: id,
                   name: name,
                   value: value,
                   isChecked: isChecked,
                   isRequired: isRequired,
                   style: style,
                   styles: styles,
                   content: content)
    }
}
