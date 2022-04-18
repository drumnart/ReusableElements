//
//  Xt.swift
//
//  Created by Sergey Gorin on 01/12/2018.
//  Copyright © 2018 Sergey Gorin. All rights reserved.
//

import Foundation

/// Xt is an extendable class that helps to create extensions
/// for other (mostly standard) types but avoiding intersections
/// with inner properties, methods and extensions of these classes.

public final class Xt<Base>: BlockScopable {
    public let base: Base
    public init(_ base: Base) {
        self.base = base
    }
}

public protocol XtCompatible {
    associatedtype CompatibleType
    static var xt: CompatibleType.Type { get }
    var xt: CompatibleType { get }
}

public extension XtCompatible {
    static var xt: Xt<Self>.Type {
        return Xt.self
    }
    
    var xt: Xt<Self> {
        return Xt(self)
    }
}
