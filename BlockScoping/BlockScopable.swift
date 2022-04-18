//
//  BlockScopable.swift
//
//  Created by Sergey Gorin on 04/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import class Foundation.NSObject

typealias BlockScopable = Appliable & Runnable

extension NSObject: BlockScopable {}

protocol Appliable {}

extension Appliable {
    
    @discardableResult
    public func apply(_ closure: (Self) -> Void) -> Self {
        closure(self)
        return self
    }
    
    @discardableResult
    public static func apply(_ closure: (Self.Type) -> Void) -> Self.Type {
        closure(self)
        return self
    }
    
    @discardableResult
    public func with(_ closure: (Self) -> Void) -> Self {
        return apply(closure)
    }
    
    @discardableResult
    public static func with(_ closure: (Self.Type) -> Void) -> Self.Type {
        return apply(closure)
    }
}

public protocol Runnable {}

public extension Runnable {
    
    @discardableResult
    func run<T>(_ closure: (Self) -> T) -> T {
        return closure(self)
    }
    
    @discardableResult
    static func run<T>(_ closure: (Self.Type) -> T.Type) -> T.Type {
        return closure(self)
    }
}

protocol Mutating {}

extension Mutating {
    
    @discardableResult
    mutating func mutate(_ closure: (inout Self) -> Void) -> Self {
        closure(&self)
        return self
    }
}

// Operators

infix operator <~ : AssignmentPrecedence
extension Appliable {
    static func <~ (left: Self, right: (Self) -> ()) -> Self {
        right(left)
        return left
    }
}

infix operator ~> : AssignmentPrecedence
extension Runnable {
    static func ~> <T>(left: Self, right: (Self) ->T) -> T {
        return right(left)
    }
}
