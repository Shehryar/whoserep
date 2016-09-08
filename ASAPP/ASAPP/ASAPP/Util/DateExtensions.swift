//
//  DateExtensions.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

extension NSDate {
    
    func getDateComponents() -> NSDateComponents {
        let calendar = NSCalendar.currentCalendar()
        return calendar.components([.Year, .Month, .Day, .Hour, .Minute, .Second], fromDate: self)
    }
    
    func isSameDayAs(date: NSDate) -> Bool {
        let dateComponents = date.getDateComponents()
        let componenets = getDateComponents()
        
        return (dateComponents.year == componenets.year &&
            dateComponents.month == componenets.month &&
            dateComponents.day == componenets.day)
    }
    
    func isToday() -> Bool {
        return isSameDayAs(NSDate())
    }
    
    func isYesterday() -> Bool {
        let dateComponents = NSDateComponents()
        dateComponents.day = -1
        
        if let yesterday =  NSCalendar.currentCalendar().dateByAddingComponents(dateComponents, toDate: NSDate(), options: []) {
            return isSameDayAs(yesterday)
        }
        return false
    }
    
    func isThisMonth() -> Bool {
        let todaysComponenets = NSDate().getDateComponents()
        let componenets = getDateComponents()
        
        return (todaysComponenets.year == componenets.year &&
            todaysComponenets.month == todaysComponenets.month)
    }
    
    func isThisYear() -> Bool {
        let todaysComponenets = NSDate().getDateComponents()
        let componenets = getDateComponents()
        
        return todaysComponenets.year == componenets.year
    }
}

extension NSDate {
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
