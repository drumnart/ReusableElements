//
//  UIKit+Extensions.swift
//
//  Created by Sergey Gorin on 04/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

extension UIColor {
    
    static var random: UIColor {
        return UIColor(
            red: .random(in: 0 ... 1),
            green: .random(in: 0 ... 1),
            blue: .random(in: 0 ... 1),
            alpha: 1
        )
    }
    
    convenience init(hexString: String, else defaultColor: UIColor = .clear) {
        
        let start = hexString.index(hexString.startIndex,
                                    offsetBy: hexString.hasPrefix("#") ? 1 : 0)
        let hexColor = String(hexString[start...])
        let scanner = Scanner(string: hexColor)
        var hexNumber: UInt32 = 0
        if scanner.scanHexInt32(&hexNumber) {
            switch hexColor.count {
            case 6: self.init(hex6: hexNumber)
            case 8: self.init(hex8: hexNumber)
            default: self.init(cgColor: defaultColor.cgColor)
            }
            return
        }
        
        self.init(cgColor: defaultColor.cgColor)
    }
        
    convenience init(hex8: UInt32) {
        let r, g, b, a: CGFloat
        let divisor = CGFloat(255)
        
        r = CGFloat((hex8 & 0xff000000) >> 24) / divisor
        g = CGFloat((hex8 & 0x00ff0000) >> 16) / divisor
        b = CGFloat((hex8 & 0x0000ff00) >> 8) / divisor
        a = CGFloat(hex8 & 0x000000ff) / divisor
        
        self.init(red: r, green: g, blue: b, alpha: a)
    }
    
    convenience init(hex6: UInt32) {
        let r, g, b: CGFloat
        let divisor = CGFloat(255)
        
        r = CGFloat((hex6 & 0xff0000) >> 16) / divisor
        g = CGFloat((hex6 & 0x00ff00) >> 8) / divisor
        b = CGFloat(hex6 & 0x0000ff) / divisor
        
        self.init(red: r, green: g, blue: b, alpha: 1)
    }
}

extension UIScrollView {
    
    public func translation(in view: UIView? = nil) -> CGPoint {
        return panGestureRecognizer.translation(in: view ?? self)
    }
    
    public func velocity(in view: UIView? = nil) -> CGPoint {
        return panGestureRecognizer.velocity(in: view ?? self)
    }
}

extension UICollectionReusableView {
    
    static var unexpected: UICollectionViewCell {
        return UICollectionViewCell().with { _ in
            assert(false, "Unexpected cell type")
        }
    }
}

extension UIView: UIKitMetricsProvider {}

extension UIViewController: UIKitMetricsProvider {}

extension UIViewController {
    
    func setNavigationBarHidden(_ hidden: Bool, withDuration duration: TimeInterval = 0.3) {
        UIView.animate(withDuration: duration) {
            self.navigationController?.setNavigationBarHidden(hidden, animated: false)
        }
    }
    
    var isTabBarHidden: Bool {
        guard let tabBar = tabBarController?.tabBar else { return false }
        return tabBar.frame.origin.y > view.frame.maxY
    }
    
    func setTabBarHidden(_ isHidden: Bool,
                         withDuration duration: TimeInterval = 0.25,
                         completion: ((Bool) -> Void)? = nil) {
        
        guard let tabBar = tabBarController?.tabBar, isTabBarHidden != isHidden else { return }
    
        UIView.animate(withDuration: duration, animations: {
            tabBar.transform = isHidden
                ? CGAffineTransform(translationX: 0, y: tabBar.frame.height + 1)
                :.identity
        }, completion: completion)
    }
    
    var isModal: Bool {
        if presentingViewController != nil {
            return true
        }
        
        if presentingViewController?.presentedViewController == self {
            return true
        }
        
        if let presented = navigationController?.presentingViewController?
            .presentedViewController,
            presented == navigationController {
            return true
        }
        
        if tabBarController?.presentingViewController is UITabBarController {
            return true
        }
        
        return false
    }
}

extension UIButton {
    
    /// Place title and image in the center of the button
    /// - Parameters:
    ///     - gap: Space between title and image;
    ///     - edgeInsets: Insets from edges;
    ///     - inverted: Whether image placed after title or not. Default is false.
    func centerTitleAndImage(withGap gap: CGFloat = 5,
                             edgeInsets: UIEdgeInsets = .zero,
                             inverted: Bool = false) {
        
        let inset = gap * 0.5
        
        if inverted {
            
            titleLabel?.sizeToFit()
            let titleWidth = titleLabel?.frame.width ?? 0
            let imageWidth = imageView?.image?.size.width ?? 0
            
            imageEdgeInsets = .apply(left: titleWidth + inset, right: -titleWidth - inset)
            titleEdgeInsets = .apply(left: -imageWidth - inset, right: imageWidth + inset)
            
        } else {
            imageEdgeInsets = .apply(left: -inset, right: inset)
            titleEdgeInsets = .apply(left: inset, right: -inset)
        }
        
        contentEdgeInsets = UIEdgeInsets(
            top: edgeInsets.top,
            left: edgeInsets.left + inset,
            bottom: edgeInsets.bottom,
            right: edgeInsets.right + inset
        )
    }
}

extension UISearchBar {
    
    var textField: UITextField? {
        return value(forKey: "searchField") as? UITextField
            ?? subviews.first?.subviews.first(where: { $0.isKind(of: UITextField.self) }) as? UITextField
    }
    
    func setTextFieldColor(_ color: UIColor) {
        switch searchBarStyle {
        case .minimal:
            textField?.layer.backgroundColor = color.cgColor
            
        case .prominent, .default:
            textField?.backgroundColor = color
        
        @unknown default: break
        }
    }
    
    var placeholderLabel: UILabel? {
        return textField?.value(forKey: "placeholderLabel") as? UILabel
    }
}
