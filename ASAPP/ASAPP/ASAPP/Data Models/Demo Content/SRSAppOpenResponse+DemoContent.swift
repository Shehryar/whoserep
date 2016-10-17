//
//  SRSAppOpenResponse+DemoContent.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 10/9/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

// MARK:- Sample Data

extension SRSAppOpenResponse {
    class func sampleResponse(forCompany company: String?) -> SRSAppOpenResponse? {
        if let json = DemoUtils.jsonObjectForFile("predictive-response", company: company) {
            return SRSAppOpenResponse.instanceWithJSON(json) as? SRSAppOpenResponse
        }
        return nil
    }
}
