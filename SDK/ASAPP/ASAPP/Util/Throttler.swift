//
//  Throttler.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 5/9/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

class Throttler {
    private let queue = DispatchQueue.global(qos: .utility)
    private var workItem = DispatchWorkItem(block: {})
    private var lastExecuted = Date.distantPast
    
    let interval: TimeInterval
    
    required init(interval: TimeInterval) {
        self.interval = interval
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
