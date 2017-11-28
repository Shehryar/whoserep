//
//  Action.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class Action: NSObject {
    
    // MARK: Properties
    
    enum JSONKey: String {
        case data
    }

    private(set) var data: [String: Any]?
    
    // MARK: Init
    
    required init?(content: Any?) {
        if let content = content as? [String: Any] {
            self.data = content[JSONKey.data.rawValue] as? [String: Any]
        } else {
            self.data = nil
        }
        super.init()
    }
}

// MARK: Data

extension Action {
    
    func getDataWithFormData(_ formData: [String: Any]?) -> [String: Any]? {
        var requestData = [String: Any]()
        requestData.add(data)
        requestData.add(formData)
        
        return requestData.isEmpty ? nil : requestData
    }
    
    func injectData(key: String, value: Any) {
        if data == nil {
            data = [String: Any]()
        }
        data?[key] = value
    }
}
