//
//  Observer.swift
//
//  Created by Sergey Gorin on 29/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation

protocol Observing {
    
    associatedtype Value
    
    func notify(_ value: Value)
}

/// Wrapper around a closure
class Observer<T>: Observing {
    
    private let _observer: (T) -> ()
    
    init(_ observer: @escaping (T) -> ()) {
        self._observer = observer
    }
    
    func notify(_ value: T) {
        _observer(value)
    }
}
