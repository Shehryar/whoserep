//
//  Throttler.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 5/9/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

/// Executes no more often than once per interval.
/// If it has been less than the interval since the last execution,
/// the handler will be executed once the remainder of the interval has passed.
/// Subsequent calls within the interval will cancel the previous item and delay the
/// execution of the provided handler as appropriate.
/// If it has been longer than the interval since the last execution,
/// the handler will be executed immediately.
/// All handlers are asynchronously executed in a background (QoS: utility) thread.
class Throttler {
    private let queue = DispatchQueue.global(qos: .utility)
    private var workItem = DispatchWorkItem(block: {})
    private var lastExecuted = Date.distantPast
    
    let interval: TimeInterval
    
    required init(interval: DispatchTimeInterval) {
        self.interval = interval.seconds
    }
    
    func throttle(handler: @escaping (() -> Void)) {
        workItem.cancel()
        workItem = DispatchWorkItem { [weak self] in
            self?.lastExecuted = Date()
            handler()
        }
        
        let delay = Date().timeIntervalSince(lastExecuted) > interval ? 0 : interval
        queue.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
    
    func cancel() {
        workItem.cancel()
    }
}
