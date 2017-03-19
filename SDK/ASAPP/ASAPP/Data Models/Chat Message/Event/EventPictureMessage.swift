//
//  EventPictureMessage.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/9/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class EventPictureMessage: NSObject {

    let imageURL: URL
    let width: Int
    let height: Int
    
    /// Returns the aspect ratio (w/h) or 1 if either width/height == 0
    var aspectRatio: Double {
        if width <= 0 || height <= 0 {
            return 1
        }
        return Double(width) / Double(height)
    }
    
    // MARK:- Init
    
    init(imageURL: URL, width: Int, height: Int) {
        self.imageURL = imageURL
        self.width = width
        self.height = height
    }
    
    // MARK:- Parsing
    
    class func fromEventJSON(_ eventJSON: [String : AnyObject]?,
                             eventCustomerId: Int,
                             eventCompanyId: Int) -> EventPictureMessage? {
        guard let eventJSON = eventJSON,
            let fileBucket = eventJSON["FileBucket"] as? String,
            let fileSecret = eventJSON["FileSecret"] as? String,
            let mimeType = eventJSON["MimeType"] as? String,
            let width = eventJSON["PicWidth"] as? Int,
            let height = eventJSON["PicHeight"] as? Int else {
                return nil
        }
        
        let imageSuffix = mimeType.components(separatedBy: "/").last ?? "jpg"
        let urlString = "https://\(fileBucket).s3.amazonaws.com/customer/\(eventCustomerId)/company/\(eventCompanyId)/\(fileSecret)-\(width)x\(height).\(imageSuffix)"
        guard let imageURL = URL(string: urlString) else {
            return nil
        }
        
        
        return EventPictureMessage(imageURL: imageURL, width: width, height: height)
    }
}
