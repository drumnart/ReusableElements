//
//  UIKitBarsMetricsProvider.swift
//
//  Created by Sergey Gorin on 04/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

protocol UIKitBarsMetricsProvider {}

extension UIKitBarsMetricsProvider {
    
    var statusBarSize: CGSize {
        return UIApplication.shared.statusBarFrame.size
    }
    
    var statusBarHeight: CGFloat { return statusBarSize.height }
}

extension UIKitBarsMetricsProvider where Self: UIViewController {
    
    var navigationBarSize: CGSize {
        return navigationController?.navigationBar.frame.size ?? .zero
    }
    
    var navigationBarHeight: CGFloat { return navigationBarSize.height }
    
    var tabBarSize: CGSize {
        return tabBarController?.tabBar.frame.size ?? .zero
    }
    
    var tabBarHeight: CGFloat {
        return tabBarSize.height
    }
    
    var tabBarHeightExcludingHomeBarArea: CGFloat {
        if #available(iOS 11.0, *) {
            return tabBarSize.height - (UIApplication.shared.keyWindow?.safeAreaInsets.bottom ?? 0)
        } else {
            return tabBarSize.height
        }
    }
}
