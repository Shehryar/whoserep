//
//  JSONParser.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 8/15/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

protocol JSONObject {
    static func instanceWithJSON(_ json: [String : AnyObject]?) -> JSONObject?
}

class JSONParser: NSObject {
    // TODO: Parsing json array using generics
}
