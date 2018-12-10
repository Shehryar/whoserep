//
//  DatePickerConfig.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/28/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

struct DatePickerConfig {
    let selectedDateFormat: String
    let minDate: Date?
    let maxDate: Date?
    let disabledDates: Set<Date>?
    
    static func from(_ content: [String: Any]?) -> DatePickerConfig {
        let selectedDateFormat = content?.string(for: TextInputItem.JSONKey.selectedDateFormat.rawValue) ?? TextInputItem.defaultSelectedDateFormat
        let minDateString = content?.string(for: TextInputItem.JSONKey.minDate.rawValue)
        let maxDateString = content?.string(for: TextInputItem.JSONKey.maxDate.rawValue)
        let disabledDates = content?.strings(for: TextInputItem.JSONKey.disabledDates.rawValue)
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        let disabledSet: Set<Date>?
        if let parsedDisabled = disabledDates?.map({ dateFormatter.date(from: $0) }).compactMap({ $0 }) {
            disabledSet = Set(parsedDisabled)
        } else {
            disabledSet = nil
        }
        
        let parsedMinDate = dateFormatter.date(from: minDateString)
        if let minDateString = minDateString, !minDateString.isEmpty, parsedMinDate == nil {
            DebugLog.e(caller: self, "Could not parse min date: \(minDateString)")
        }
        
        let parsedMaxDate = dateFormatter.date(from: maxDateString)
        if let maxDateString = maxDateString, !maxDateString.isEmpty, parsedMaxDate == nil {
            DebugLog.e(caller: self, "Could not parse max date: \(maxDateString)")
        }
        
        return DatePickerConfig(
            selectedDateFormat: selectedDateFormat,
            minDate: parsedMinDate,
            maxDate: parsedMaxDate,
            disabledDates: disabledSet)
    }
    
    func getPickerOptions() -> [PickerOption] {
        guard
            minDate != nil || maxDate != nil || disabledDates != nil,
            let calendar = NSCalendar(calendarIdentifier: .ISO8601),
            let (min, max) = computeLimits(calendar: calendar, min: minDate, max: maxDate)
            else {
                return []
        }
        
        var dates: [Date] = []
        var current: Date? = min
        while let valid = current, [.orderedSame, .orderedAscending].contains(valid.compare(max)) {
            dates.append(valid)
            current = calendar.date(byAdding: .day, value: 1, to: valid, options: [])
        }
        
        let filteredDates = dates.filter { !(disabledDates?.contains($0) ?? false) }
        let options = getOptions(from: filteredDates)
        
        return options
    }
    
    private func computeLimits(calendar: NSCalendar, min minDate: Date?, max maxDate: Date?) -> (Date, Date)? {
        let maxOptions = 365
        let min, max: Date
        switch (minDate, maxDate) {
        case let (.some(unwrappedMin), .some(unwrappedMax)):
            min = unwrappedMin
            max = unwrappedMax
            return (min, max)
        case let (.some(unwrappedMin), .none):
            min = unwrappedMin
            if let computedMax = calendar.date(byAdding: .day, value: maxOptions, to: min, options: []) {
                max = computedMax
                return (min, max)
            } else {
                return nil
            }
        case let (.none, .some(unwrappedMax)):
            max = unwrappedMax
            if let computedMin = calendar.date(byAdding: .day, value: -maxOptions, to: max, options: []) {
                min = computedMin
                return (min, max)
            } else {
                return nil
            }
        case (.none, .none): return nil
        }
    }
    
    private func getOptions(from dates: [Date]) -> [PickerOption] {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "EEE, MMM d"
        var options: [PickerOption] = []
        for date in dates {
            let text = dateFormatter.string(from: date)
            options.append(PickerOption(text: text, value: date))
        }
        return options
    }
}
