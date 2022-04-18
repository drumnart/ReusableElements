//
//  UITabBarController+Extensions.swift
//
//  Created by Sergey Gorin on 26/09/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

extension UITabBarController {
    
    func popSelectedToRoot(animated: Bool = true) {
        guard let nc = (selectedViewController as? UINavigationController) else { return }

        if nc.visibleViewController != nc.viewControllers.first {
            nc.popToRootViewController(animated: animated)
        }
    }
}
