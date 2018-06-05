//
//  DispatchTimeIntervalExtensions.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 6/1/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

extension DispatchTimeInterval {
    static var defaultAnimationDuration: DispatchTimeInterval {
        return .milliseconds(300)
    }
    
    static func seconds(_ value: Double) -> DispatchTimeInterval {
        return .milliseconds(Int(value * 1000))
    }
    
    static func milliseconds(_ value: Double) -> DispatchTimeInterval {
        return .microseconds(Int(value * 1000))
    }
    
    static func microseconds(_ value: Double) -> DispatchTimeInterval {
        return .nanoseconds(Int(value * 1000))
    }
    
    static func nanoseconds(_ value: Double) -> DispatchTimeInterval {
        return .nanoseconds(Int(value))
    }
    
    static func * (lhs: DispatchTimeInterval, rhs: Int) -> DispatchTimeInterval {
        switch lhs {
        case let .seconds(value):
            return .seconds(value * rhs)
        case let .milliseconds(value):
            return .milliseconds(value * rhs)
        case let .microseconds(value):
            return .microseconds(value * rhs)
        case let .nanoseconds(value):
            return .nanoseconds(value * rhs)
        case .never:
            return .never
        }
    }
    
    static func * (lhs: DispatchTimeInterval, rhs: Double) -> DispatchTimeInterval {
        return lhs * Int(rhs)
    }
    
    var seconds: Double {
        switch self {
        case let .seconds(value):
            return Double(value)
        case let .milliseconds(value):
            return Double(value) / 1000
        case let .microseconds(value):
            return Double(value) / 1000 / 1000
        case let .nanoseconds(value):
            return Double(value) / 1000 / 1000 / 1000
        case .never:
            return Double.greatestFiniteMagnitude
        }
    }
    
    var nanoseconds: Int {
        switch self {
        case let .seconds(value):
            return value * 1000 * 1000 * 1000
        case let .milliseconds(value):
            return value * 1000 * 1000
        case let .microseconds(value):
            return value * 1000
        case let .nanoseconds(value):
            return value
        case .never:
            return Int.max
        }
    }
    
    static func + (lhs: DispatchTimeInterval, rhs: DispatchTimeInterval) -> DispatchTimeInterval {
        return .nanoseconds(lhs.nanoseconds + rhs.nanoseconds)
    }
    
    static func + (lhs: DispatchTimeInterval, rhs: TimeInterval) -> DispatchTimeInterval {
        return lhs + .seconds(rhs)
    }
}
