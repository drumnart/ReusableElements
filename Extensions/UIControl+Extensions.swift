//
//  UIControl+Extensions.swift
//
//  Created by Sergey Gorin on 15/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

extension AssociatedKey {
    fileprivate static let actionClosure = AssociatedKey("actionClosure_" + UUID().uuidString)
}

extension UIControl {
    
    typealias ActionClosure = (UIControl) -> ()
    
    private var actionClosure: ActionClosure? {
        get { return getAssociatedObject(forKey: .actionClosure) }
        set { setAssociatedObject(newValue, forKey: .actionClosure) }
    }
    
    @objc private func action(_ events: UIControl.Event) {
        actionClosure?(self)
    }
    
    func onAction(_ events: UIControl.Event = .touchUpInside,
                  closure: @escaping ActionClosure) {
        actionClosure = closure
        addTarget(self, action: #selector(action(_:)), for: events)
    }
}
