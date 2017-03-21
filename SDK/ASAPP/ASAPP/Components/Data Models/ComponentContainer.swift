//
//  ComponentContainer.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/21/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

struct ComponentContainer {

    static func component(from json: Any?) -> Component? {
        guard let json = json as? [String : Any] else {
            return nil
        }
        
        if let body = json["body"] as? [String : Any] {
            let styles = json["styles"] as? [String : Any]
            return ComponentFactory.component(with: json["body"], styles: styles)
        }
        
        return ComponentFactory.component(with: json, styles: nil)
    }
}
