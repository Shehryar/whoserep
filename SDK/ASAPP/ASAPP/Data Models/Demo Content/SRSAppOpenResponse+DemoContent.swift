//
//  AppOpenResponse+DemoContent.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK: - Sample Data

extension AppOpenResponse {
    class func sampleResponse(forCompany company: String?) -> AppOpenResponse? {
        if let json = DemoUtils.jsonObjectForFile("predictive-response", company: company) {
            return AppOpenResponse.fromJSON(json)
        }
        return nil
    }
}
