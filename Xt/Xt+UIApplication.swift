//
//  Xt+UIApplication.swift
//
//  Created by Sergey Gorin on 04/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit.UIApplication

extension UIApplication: XtCompatible {
    fileprivate static var activityIndicatorSetVisibleCount = 0
}

extension Xt where Base: UIApplication {
    
    /// Activity Indicator Visibility Handling
    static func setNetworkActivityIndicatorVisible(_ visible: Bool) {
        UIApplication.activityIndicatorSetVisibleCount += visible ? 1 : -1
        if UIApplication.activityIndicatorSetVisibleCount < 0 {
            UIApplication.activityIndicatorSetVisibleCount = 0
        }
        UIApplication.shared.isNetworkActivityIndicatorVisible = UIApplication.activityIndicatorSetVisibleCount > 0
    }
    
    /// Reset Application Icon Badge Number
    static func resetBadgeNumber() {
        UIApplication.shared.applicationIconBadgeNumber = 0
    }
}
