//
//  DateExtensions.swift
//  ASAPP
//
//  Created by Mitchell Morgan on 7/29/16.
//  Copyright © 2016 asappinc. All rights reserved.
//

import UIKit

internal extension Date {

    static func timeSince(date: Date, isGreaterThan numberOfSeconds: TimeInterval) -> Bool {
        return date.timeSinceIsGreaterThan(numberOfSeconds: numberOfSeconds)
    }
    
    func timeSinceIsGreaterThan(numberOfSeconds: TimeInterval) -> Bool {
        let referenceDate = self.addingTimeInterval(numberOfSeconds)
        let referenceDateHasPassed = referenceDate.hasPassed()
        
        return referenceDateHasPassed
    }
    
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
            dateFormat = "h:mm a"
        } else if isYesterday() {
            dateFormat = "'Yesterday at' h:mm a"
        } else if isThisYear() {
            dateFormat = "MMMM d 'at' h:mm a"
        } else {
            dateFormat = "MMMM d, yyyy 'at' h:mm a"
        }
        return dateFormat
    }
    
    func formattedStringMostRecent() -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone.autoupdatingCurrent
        dateFormatter.dateFormat = dateFormatForMostRecent()
        return dateFormatter.string(from: self)
    }
    
    var asRFC3339String: String {
        let formatter = DateFormatter()
        formatter.locale = Locale(identifier: "en_US_POSIX")
        formatter.timeZone = TimeZone(secondsFromGMT: 0)
        formatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss.SSS'Z"
        return formatter.string(from: self)
    }
}
