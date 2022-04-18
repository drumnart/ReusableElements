//
//  UINavigationItem+Extensions.swift
//
//  Created by Sergey Gorin on 15/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

extension UINavigationItem {
    
    /// Remove back button title keeping icon '<'.
    func clearBackButtonItem() {
        backBarButtonItem = UIBarButtonItem(title: "", style: .plain, target: nil, action: nil)
    }
}
