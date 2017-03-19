//
//  SRSImageItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSImageItem: NSObject {
    
    let imageURL: URL
    
    // Width / Height
    var aspectRatio: CGFloat = 1.0
    
    init(imageURL: URL) {
        self.imageURL = imageURL
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> SRSImageItem? {
        guard let json = json,
            let imageURLString = json["image_url"] as? String,
            let imageURL = URL(string: imageURLString) else {
                return nil
        }
       
        let imageItem = SRSImageItem(imageURL: imageURL)
        
        if let aspectRatio = json["aspect_ratio"] as? CGFloat {
            if aspectRatio > 0 {
                imageItem.aspectRatio = aspectRatio
            }
        }
        
        return SRSImageItem(imageURL: imageURL)
    }
}
