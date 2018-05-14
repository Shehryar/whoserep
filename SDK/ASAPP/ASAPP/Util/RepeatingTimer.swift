//
//  RepeatingTimer.swift
//  ASAPP
//
//  Created by Hans Hyttinen on 5/4/18.
//  Copyright © 2018 asappinc. All rights reserved.
//

import Foundation

class RepeatingTimer {
    private enum State {
        case active
        case inactive
    }
    
    private var state = State.inactive
    
    private var timer: DispatchSourceTimer
    
    init(interval: TimeInterval, handler: @escaping (() -> Void)) {
        let timerSource = DispatchSource.makeTimerSource()
        timerSource.schedule(deadline: .now(), repeating: interval)
        self.timer = timerSource
        self.timer.setEventHandler(handler: handler)
    }
    
    deinit {
        timer.setEventHandler {}
        timer.cancel()
        resume()
    }
    
    func resume() {
        guard state == .inactive else {
            return
        }
        
        state = .active
        timer.resume()
    }
    
    func suspend() {
        guard state == .active else {
            return
        }
        
        state = .inactive
        timer.suspend()
    }
}
