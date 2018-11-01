//
//  Action.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 3/23/17.
//  Copyright © 2017 asappinc. All rights reserved.
//

import UIKit

class Action: NSObject {
    typealias Metadata = [String: AnyCodable]
    
    // MARK: Properties
    
    enum JSONKey: String {
        case data
        case metadata
    }

    private(set) var data: [String: Any]?
    let metadata: Metadata?
    let performImmediately: Bool
    
    // MARK: Init
    
    required init?(content: Any?, performImmediately: Bool = false) {
        if let content = content as? [String: Any] {
            self.data = content[JSONKey.data.rawValue] as? [String: Any]
            self.metadata = content.codableDict(for: JSONKey.metadata.rawValue, type: Metadata.self)
        } else {
            self.data = nil
            self.metadata = nil
        }
        
        self.performImmediately = performImmediately
        
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
