//
//  DividableByZero.swift
//
//  Created by Sergey Gorin on 26/03/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation
import CoreGraphics.CGGeometry

infix operator /?: MultiplicationPrecedence

protocol DividableByZero {}

extension DividableByZero where Self: FloatingPoint {
    
    static func /? (lhs: Self, rhs: Self) -> Self {
        if rhs == 0 { return 0 }
        return lhs / rhs
    }
}

extension DividableByZero where Self == Int {
    
    static func /? (lhs: Self, rhs: Self) -> Self {
        if rhs == 0 { return 0 }
        return lhs / rhs
    }
}

extension FloatingPoint {
    var isBad: Bool { return isNaN || isInfinite }
}

extension Int: DividableByZero {}
extension Float: DividableByZero {}
extension Double: DividableByZero {}
extension CGFloat: DividableByZero {}
