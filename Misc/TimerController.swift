//
//  TimerController.swift
//
//  Created by Sergey Gorin on 26/03/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation

class TimerController {
    
    enum State {
        case stopped
        case running
        case iddle
    }
    
    typealias Callback = (TimerController) -> Void
    
    private var callback: Callback = { _ in }
    private var timer: Timer?
    
    private(set) var interval: TimeInterval = -1
    private(set) var state: State = .stopped
    
    func start(with timeInterval: TimeInterval, tolerance: TimeInterval = 0.0) {
        guard timeInterval > 0 else { return }
        interval = timeInterval
        
        if timer == nil {
            
            timer = Timer(timeInterval: timeInterval,
                          target: self,
                          selector: #selector(tick(_:)),
                          userInfo: nil,
                          repeats: true)
            
            if let timer = timer {
                RunLoop.current.add(timer, forMode: .common)
                timer.tolerance = tolerance
            }
        }
        
        state = .running
    }
    
    func pause() {
        timer?.invalidate()
        timer = nil
        state = .iddle
    }
    
    func resume() {
        if interval > 0 {
            start(with: interval)
        }
    }
    
    func stop() {
        pause()
        interval = -1
        state = .stopped
    }
    
    @discardableResult
    func onDidTick(_ callback: @escaping Callback) -> TimerController {
        self.callback = callback
        return self
    }
    
    @objc fileprivate func tick(_ timer: Timer) {
        DispatchQueue.main.async {
            self.callback(self)
        }
    }
    
    deinit {
        stop()
    }
}
