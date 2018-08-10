//
//  Timer.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 8/10/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

class Timer {
    private enum State {
        case active
        case inactive
    }
    
    private var state = State.inactive
    
    private var timer: DispatchSourceTimer
    
    init(delay: DispatchTimeInterval, handler: @escaping (() -> Void)) {
        let timerSource = DispatchSource.makeTimerSource()
        timerSource.schedule(deadline: .now() + delay)
        self.timer = timerSource
        self.timer.setEventHandler(handler: handler)
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        timer.resume()
    }
    
    func start() {
        guard state == .inactive else {
            return
        }
        
        state = .active
        timer.resume()
    }
    
    func cancel() {
        guard state == .active else {
            return
        }
        
        state = .inactive
        timer.suspend()
    }
}
