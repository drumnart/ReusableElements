//
//  Throttler.swift
//
//  Created by Sergey Gorin on 21/05/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation

class Throttler {
    
    private var interval: TimeInterval
    private let queue: DispatchQueue
    private var workItem: DispatchWorkItem = DispatchWorkItem(block: {})
    private var previousDate: Date = .distantPast
    
    init(interval: TimeInterval,
         queue: DispatchQueue = DispatchQueue.global(qos: .background)) {
        self.interval = interval
        self.queue = queue
    }
    
    func throttle(_ closure: @escaping () -> ()) {
        workItem.cancel()
        workItem = DispatchWorkItem { [weak self] in
            self?.previousDate = Date()
            closure()
        }
        
        let delay = Date().timeIntervalSince(previousDate) > interval ? 0 : interval
        log("Delay: \(delay)")
        queue.asyncAfter(deadline: .now() + delay, execute: workItem)
    }
}
