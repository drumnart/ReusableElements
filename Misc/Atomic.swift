//
//  Atomic.swift
//
//  Created by Sergey Gorin on 03/09/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation

final class Atomic<T> {
    private let queue = DispatchQueue(
        label: Bundle.main.bundleIdentifier ?? "com" + ".atomic.serialQueue"
    )
    private var _value: T
    init(_ value: T) {
        self._value = value
    }
    
    var value: T {
        get {
            return queue.sync { _value }
        }
        set {
            queue.sync {
                _value = newValue
            }
        }
    }
}
