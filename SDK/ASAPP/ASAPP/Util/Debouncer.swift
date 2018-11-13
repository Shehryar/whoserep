//
//  Debouncer.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 11/12/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

class Debouncer {
    private let queue = DispatchQueue.global(qos: .utility)
    private var workItem = DispatchWorkItem(block: {})
    private var lastExecuted = Date.distantPast
    
    let interval: TimeInterval
    
    required init(interval: DispatchTimeInterval) {
        self.interval = interval.seconds
    }
    
    func debounce(handler: @escaping (() -> Void)) {
        guard Date().timeIntervalSince(lastExecuted) > interval else {
            return
        }
        
        workItem.cancel()
        workItem = DispatchWorkItem { [weak self] in
            self?.lastExecuted = Date()
            handler()
        }
        queue.async(execute: workItem)
    }
    
    func cancel() {
        workItem.cancel()
    }
}
