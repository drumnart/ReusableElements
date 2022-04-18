//
//  Optional+Unwrapping.swift
//
//  Created by Sergey Gorin on 04/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

extension Optional {
    
    /// Tries to unwrap an optional and calls closure with unwrapped value on success
    @discardableResult
    public func `let`(_ closure: (Wrapped) -> Void) -> Optional {
        if case let .some(value) = self {
            closure(value)
        }
        return self
    }
}
