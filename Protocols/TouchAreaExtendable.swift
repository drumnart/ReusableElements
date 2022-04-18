//
//  TouchAreaExtendable.swift
//
//  Created by Sergey Gorin on 07/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

protocol TouchAreaExtendable: NSObjectProtocol {
    func point(inside point: CGPoint, with event: UIEvent?) -> Bool
}

extension TouchAreaExtendable where Self: UIView {
    
    func touch(point: CGPoint, withMargins margins: CGPoint) -> Bool {
        return bounds.insetBy(dx: -margins.x, dy: -margins.y).contains(point)
    }
}
