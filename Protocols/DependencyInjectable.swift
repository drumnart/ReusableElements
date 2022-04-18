//
//  DependencyInjectable.swift
//
//  Created by Sergey Gorin on 04/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation

// DI Protocol
protocol DependencyInjectable {
    associatedtype T
    
    mutating func inject(_: T)
}
