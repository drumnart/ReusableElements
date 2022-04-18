//
//  Xt+NSLayoutConstraint.swift
//
//  Created by Sergey Gorin on 04/12/2018.
//  Copyright © 2018 Sergey Gorin. All rights reserved.
//

import UIKit.NSLayoutConstraint

extension NSLayoutConstraint: XtCompatible {}

extension Xt where Base: NSLayoutConstraint {
    
    @discardableResult
    func activate(translatingAutoresizingMaskIntoConstraints isTranslatingEnabled: Bool = false) -> Base {
        (base.firstItem as? UIView)?.translatesAutoresizingMaskIntoConstraints = isTranslatingEnabled
        base.isActive = true
        return base
    }
    
    @discardableResult
    func deactivate() -> Base {
        base.isActive = false
        return base
    }
    
    class func activate(_ constraints: [NSLayoutConstraint],
                        translatingAutoresizingMaskIntoConstraints isTranslatingEnabled: Bool = false) {
        constraints.forEach {
            $0.xt.activate(translatingAutoresizingMaskIntoConstraints: isTranslatingEnabled)
        }
    }
    
    class func deactivate(_ constraints: [NSLayoutConstraint]) {
        NSLayoutConstraint.deactivate(constraints)
    }
}
