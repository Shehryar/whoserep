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
    
    class func fromJSON(_ json: [String : AnyObject]?) -> ChatMessageImage? {
        guard let json = json else {
            return nil
        }
        
        guard let urlString = json["url"] as? String,
            let url = URL(string: urlString),
            let width = json["width"] as? CGFloat,
            let height = json["height"] as? CGFloat else {
                DebugLog.w(caller: self, "url, width, and height required: \(json)")
                return nil
        }
        
        return ChatMessageImage(url: url, width: width, height: height)
    }
}
