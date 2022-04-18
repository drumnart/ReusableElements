//
//  UIKitMetricsProvider.swift
//
//  Created by Sergey Gorin on 04/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

protocol UIKitMetricsProvider: UIKitBarsMetricsProvider {}

extension UIKitMetricsProvider {
    
    var screenBounds: CGRect {
        return UIScreen.main.bounds
    }
    
    var screenWidth: CGFloat {
        return screenBounds.size.width
    }
    
    var screenHeight: CGFloat {
        return screenBounds.size.height
    }
    
    var screenScale: CGFloat {
        return UIScreen.main.scale
    }
}

extension UIKitMetricsProvider where Self: UIViewController {
    
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.topAnchor
        } else {
            return topLayoutGuide.bottomAnchor
        }
    }
    
    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.bottomAnchor
        } else {
            return bottomLayoutGuide.topAnchor
        }
    }
    
    var safeAreaLeftAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.leftAnchor
        } else {
            return view.leftAnchor
        }
    }
    
    var safeAreaRightAnchor: NSLayoutXAxisAnchor {
        if #available(iOS 11.0, *) {
            return view.safeAreaLayoutGuide.rightAnchor
        } else {
            return view.rightAnchor
        }
    }
    
    var safeAreaTopInset: CGFloat {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets.top
        } else {
            return topLayoutGuide.length
        }
    }
    
    var safeAreaBottomInset: CGFloat {
        if #available(iOS 11.0, *) {
            return view.safeAreaInsets.bottom
        } else {
            return bottomLayoutGuide.length
        }
    }
}

extension UIKitMetricsProvider where Self: UIView {
    
    var safeAreaTopAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.topAnchor
        }
        return topAnchor
    }
    
    var safeAreaBottomAnchor: NSLayoutYAxisAnchor {
        if #available(iOS 11.0, *) {
            return safeAreaLayoutGuide.bottomAnchor
        }
        return bottomAnchor
    }
}
