//
//  UINavigationController+Extensions.swift
//
//  Created by Sergey Gorin on 04/08/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

extension UINavigationController {
    
    override open var childForStatusBarStyle: UIViewController? {
        return topViewController
    }
    
    override open var childForStatusBarHidden: UIViewController? {
        return topViewController
    }
    
    open override var preferredStatusBarStyle: UIStatusBarStyle {
        return topViewController?.preferredStatusBarStyle ?? .default
    }
}
