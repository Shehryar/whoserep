//
//  BasicList.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/13/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class BasicList: NSObject {
    
    enum SeparatorStyle: String {
        case none = "none"
        case insetLine = "inset_line"
        case line = "line"
    }
    
    let sections: [BasicListSection]
    
    let separatorStyle: SeparatorStyle

    init(sections: [BasicListSection], separatorStyle: SeparatorStyle? = nil) {
        self.sections = sections
        self.separatorStyle = separatorStyle ?? .none
        super.init()
    }
}

// MARK:- JSON Parsing

extension BasicList {
    
    class func fromJSON(_ json: [String : AnyObject]?) -> BasicList? {
        guard let json = json else {
            return nil
        }
        
        guard let sectionsJSONArray = json["sections"] as? [[String : AnyObject]] else {
            DebugLog.i(caller: self, "Missing sections. Returning nil.")
            return nil
        }
        
        var sections = [BasicListSection]()
        for sectionJSON in sectionsJSONArray {
            if let section = BasicListSection.fromJSON(sectionJSON) {
                sections.append(section)
            }
        }
        
        guard sections.count > 0 else {
            DebugLog.i(caller: self, "Empty sections. Returning nil.")
            return nil
        }
        
        var separatorStyle = SeparatorStyle.none
        if let separatorStyleString = json["separator_style"] as? String,
            let separatorStyleEnum = SeparatorStyle(rawValue: separatorStyleString) {
            separatorStyle = separatorStyleEnum
        }
        
        return BasicList(sections: sections, separatorStyle: separatorStyle)
    }
}
