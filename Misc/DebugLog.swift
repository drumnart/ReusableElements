//
//  Debug.swift
//
//  Created by Sergey Gorin on 05/06/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import Foundation

func log(_ items: Any..., separator: String = " ", terminator: String = "\n") {
    #if DEBUG
    items.forEach {
        Swift.print($0, separator: separator, terminator: terminator)
    }
    #endif
}
