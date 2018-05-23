//
//  ChatMessageImage.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/14/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class ChatMessageImage: NSObject {
    let url: URL
    let width: CGFloat
    let height: CGFloat
    let aspectRatio: CGFloat
    
    // MARK: - Init
    
    init(url: URL, width: CGFloat, height: CGFloat) {
        self.url = url
        self.width = width
        self.height = height
        self.aspectRatio = height > 0 ? width / height : 1
        super.init()
    }
}

// MARK: - JSON Parsing

extension ChatMessageImage {
    
    class func from(_ dict: [String: Any]?) -> ChatMessageImage? {
        guard let dict = dict else {
            return nil
        }
        
        guard let urlString = dict["url"] as? String,
              let url = URL(string: urlString),
              let width = dict["width"] as? CGFloat,
              let height = dict["height"] as? CGFloat else {
            DebugLog.w(caller: self, "url, width, and height required: \(dict)")
            return nil
        }
        
        return ChatMessageImage(url: url, width: width, height: height)
    }
}
