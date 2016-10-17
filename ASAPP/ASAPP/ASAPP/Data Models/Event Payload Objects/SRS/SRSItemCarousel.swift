//
//  SRSCarouselItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSItemCarousel: NSObject, JSONObject {
    
    var message: String
    
    var pages: [SRSItemList]
    
    var currentPage: Int = 0
    
    var buttonItems: [SRSButtonItem]? {
        if currentPage >= 0 && currentPage < pages.count {
            return pages[currentPage].buttonItems
        }
        return nil
    }
    
    // MARK: Init
    
    init(message: String, pages: [SRSItemList]) {
        self.message = message
        self.pages = pages
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json else {
            return nil
        }

        guard let message = json["message"] as? String else {
            return nil
        }
        
        if let pagesJSON = json["pages"] as? [[String : AnyObject]] {
            var pages = [SRSItemList]()
            for pageJSON in pagesJSON {
                if let page = SRSItemList.instanceWithJSON(pageJSON) as? SRSItemList {
                    pages.append(page)
                }
            }
            
            if pages.count > 0 {
                let itemCarousel = SRSItemCarousel(message: message, pages: pages)
                return itemCarousel
            }
        }
        
        return nil
    }
}
