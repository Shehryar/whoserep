//
//  SRSCarouselItem.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/10/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

class SRSItemCarousel: NSObject {
    
    var messageText: String
    
    var pages: [SRSItemList]
    
    var currentPage: Int = 0
    
    var buttonItems: [SRSButtonItem]? {
        if currentPage >= 0 && currentPage < pages.count {
            return pages[currentPage].buttonItems
        }
        return nil
    }
    
    // MARK: Init
    
    init(messageText: String, pages: [SRSItemList]) {
        self.messageText = messageText
        self.pages = pages
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(_ json: [String : AnyObject]?) -> SRSItemCarousel? {
        guard let json = json else {
            return nil
        }

        guard let messageText = json["message"] as? String else {
            return nil
        }
        
        if let pagesJSON = json["pages"] as? [[String : AnyObject]] {
            var pages = [SRSItemList]()
            for pageJSON in pagesJSON {
                if let page = SRSItemList.fromJSON(pageJSON) {
                    pages.append(page)
                }
            }
            
            if pages.count > 0 {
                let itemCarousel = SRSItemCarousel(messageText: messageText, pages: pages)
                return itemCarousel
            }
        }
        
        return nil
    }
}
