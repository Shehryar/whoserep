//
//  BillDetails.swift
//  ASAPPTest
//
//  Created by Mitchell Morgan on 11/4/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

struct LineItem {
    let name: String?
    let date: String?
    let amount: String?
}

class BillDetails: NSObject {
    
    let total: String = "$126.22"
    
    let billingPeriod: String = "10/15/2016 - 11/14/2016"
    
    let dueDate: String = "November 18"
    
    let dueDateString: String = "Due on November 18"
    
    let lineItems = [
        LineItem(name: "Movie: Avengers 2",
                 date: "10/11/2016",
                 amount: "$5.99"),
        LineItem(name: "Internet: Misc Charge",
                 date: "10/10/2016",
                 amount: "$5.99"),
        LineItem(name: "HBO: Charge",
                 date: "10/10/2016",
                 amount: "$5.99"),
        LineItem(name: "Internet: Misc Charge",
                 date: "10/5/2016",
                 amount: "$5.99"),
        LineItem(name: "Internet: Misc Charge",
                 date: "10/1/2016",
                 amount: "$5.99")
        ]
}
