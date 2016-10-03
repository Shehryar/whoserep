//
//  DateExtensions.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

internal extension Date {
    
    func hasPassed() -> Bool {
        return timeIntervalSinceNow < 0
    }
    
    func getDateComponents() -> DateComponents {
        let calendar = Calendar.current
        return (calendar as NSCalendar).components([.year, .month, .day, .hour, .minute, .second], from: self)
    }
    
    func isSameDayAs(_ date: Date) -> Bool {
        let dateComponents = date.getDateComponents()
        let componenets = getDateComponents()
        
        return (dateComponents.year == componenets.year &&
            dateComponents.month == componenets.month &&
            dateComponents.day == componenets.day)
    }
    
    func isToday() -> Bool {
        return isSameDayAs(Date())
    }
    
    func isYesterday() -> Bool {
        var dateComponents = DateComponents()
        dateComponents.day = -1
        
        if let yesterday =  (Calendar.current as NSCalendar).date(byAdding: dateComponents, to: Date(), options: []) {
            return isSameDayAs(yesterday)
        }
        return false
    }
    
    func isThisMonth() -> Bool {
        let todaysComponenets = Date().getDateComponents()
        let componenets = getDateComponents()
        
        return (todaysComponenets.year == componenets.year &&
            todaysComponenets.month == todaysComponenets.month)
    }
    
    func isThisYear() -> Bool {
        let todaysComponenets = Date().getDateComponents()
        let componenets = getDateComponents()
        
        return todaysComponenets.year == componenets.year
    }
}

extension Date {
    func dateFormatForMostRecent() -> String {
        var dateFormat: String
        if isToday() {
            dateFormat = "h:mma"
        } else if isYesterday() {
            dateFormat = "'Yesterday at' h:mma"
        } else if isThisYear() {
            dateFormat = "MMMM d 'at' h:mma"
        } else {
            dateFormat = "MMMM d, yyyy 'at' h:mma"
        }
        return dateFormat
    }
}
