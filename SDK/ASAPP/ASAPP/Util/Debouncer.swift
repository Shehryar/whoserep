//
//  Debouncer.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/12/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

/// Executes the given handler if at least *interval* has passed since the last execution.
/// Otherwise, does nothing.
/// Handlers are executed immediately in the current thread.
class Debouncer {
    private var lastExecuted = Date.distantPast
    
    let interval: TimeInterval
    
    required init(interval: DispatchTimeInterval) {
        self.interval = interval.seconds
    }
    
    func debounce(handler: @escaping (() -> Void)) {
        guard Date().timeIntervalSince(lastExecuted) > interval else {
            return
        }
        
        lastExecuted = Date()
        handler()
    }
    
    func cancel() {
        lastExecuted = .distantPast
    }
}
