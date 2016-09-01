//
//  SRSResponse.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 9/1/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import Foundation

enum SRSResponseType: String {
    case Inline = "inline"
    case Modal = "modal"
}

class SRSResponse: NSObject, JSONObject {
    var type: SRSResponseType
    var title: String?
    var classification: String?
    var itemList: SRSItemList?
    
    init(type: SRSResponseType) {
        self.type = type
        super.init()
    }
    
    // MARK: JSONObject
    
    class func instanceWithJSON(json: [String : AnyObject]?) -> JSONObject? {
        guard let json = json else {
//            let typeString = json["display"] as? String,
//            let type = SRSResponseType(rawValue: typeString) else {
                return nil
        }
        
        var response = SRSResponse(type: .Modal) // MITCH MITCH MITCH
        response.title = json["title"] as? String
        response.classification = json["classification"] as? String
        response.itemList = SRSItemList.instanceWithJSON(json["content"] as? [String : AnyObject]) as? SRSItemList
        
        return response
    }
}
