//
//  UIViewController+QuickNotification.swift
//
//  Created by Sergey Gorin on 29/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

extension UIViewController {
    
    // MARK: - Quick notification
    
    @discardableResult
    func showQuickNotification(at edge: QuickNotificationEdge = .bottom,
                               minHeight: CGFloat = 44.0,
                               withText text: String = "Connection problem!",
                               withTextColor textColor: UIColor = .black,
                               withTextALignment textAlignment: NSTextAlignment = .left,
                               withFont font: UIFont = .systemFont(ofSize: UIFont.systemFontSize),
                               withBackgroundColor bgColor: UIColor = UIColor.black.withAlphaComponent(0.8),
                               withInsets insets: UIEdgeInsets = .zero,
                               withSafeAreaInsets insetsFromSafeArea: Bool = true,
                               withHideDelay hideDelay: Double = 0.0,
                               withDuration duration: Double = 0.4) -> QuickNotificationView {
        
        var insets = insets
        if insetsFromSafeArea {
            switch edge {
            case .top: insets.top += safeAreaTopInset
            case .bottom: insets.bottom += safeAreaBottomInset
            }
        }
        
        return QuickNotificationView.show(at: edge,
                                          in: view,
                                          withMinimumHeight: minHeight,
                                          withInsets: insets,
                                          withHideDelay: hideDelay,
                                          withText: text,
                                          withTextColor: textColor,
                                          withFont: font,
                                          withTextALignment: textAlignment,
                                          withBackgroundColor: bgColor,
                                          withDuration: duration)
    }
    
    @discardableResult
    func showSuccessNotification(withText text: String,
                                 atEdge edge: QuickNotificationEdge = .bottom,
                                 respectingSafeAreaInsets: Bool = true,
                                 minHeight: CGFloat = 50.0,
                                 insets: UIEdgeInsets = .zero,
                                 font: UIFont = .regular(14),
                                 textColor: UIColor = .tbxBlack,
                                 textAlignment: NSTextAlignment = .left,
                                 backgroundColor: UIColor = .tbxSuccess,
                                 hideDelay: TimeInterval = 10.0,
                                 onTap: UIView.TapGestureRecognizerClosure?) -> QuickNotificationView {
        return showQuickNotification(at: edge,
                                     minHeight: minHeight,
                                     withText: text,
                                     withTextColor: textColor,
                                     withTextALignment: textAlignment,
                                     withFont: font,
                                     withBackgroundColor: backgroundColor,
                                     withInsets: insets,
                                     withSafeAreaInsets: respectingSafeAreaInsets,
                                     withHideDelay: hideDelay).with {
                                        $0.xt.onTap { [qn = $0] recognizer in
                                            onTap?(recognizer)
                                            qn.dismiss(withDelay: 0.2, withDuration: 0.4)
                                        }
                                        $0.xt.onPan { [qn = $0] pan in
                                            let yTranslation = pan.translation(in: pan.view).y
                                            if pan.state == .began
                                                && ((edge == .bottom && yTranslation > 0)
                                                    || (edge == .top && yTranslation < 0)) {
                                                qn.dismiss(withDuration: 0.2)
                                            }
                                        }
        }
    }
    
    @discardableResult
    func showErrorNotification(withError error: Error,
                               atEdge edge: QuickNotificationEdge = .bottom,
                               respectingSafeAreaInsets: Bool = true,
                               minHeight: CGFloat = 44.0,
                               textColor: UIColor = .tbxWhite,
                               delay: TimeInterval = 10.0) -> QuickNotificationView {
        
        return showQuickNotification(at: edge,
                                     minHeight: minHeight,
                                     withText: error.localizedDescription,
                                     withTextColor: textColor,
                                     withFont: .regular(14),
                                     withBackgroundColor: .tbxFailureAlert,
                                     withSafeAreaInsets: respectingSafeAreaInsets,
                                     withHideDelay: delay).with {
                                        $0.xt.onTap { [qn = $0] _ in
                                            qn.dismiss(withDelay: 0.2, withDuration: 0.4)
                                        }
                                        $0.xt.onPan { [qn = $0] pan in
                                            let yTranslation = pan.translation(in: pan.view).y
                                            if pan.state == .began
                                                && ((edge == .bottom && yTranslation > 0)
                                                || (edge == .top && yTranslation < 0)) {
                                                qn.dismiss(withDuration: 0.2)
                                            }
                                        }
        }
    }
    
    func dismissQuickNotification(withDelay delay: Double = 0.0, withDuration duration: Double = 0.4) {
        QuickNotificationView.sharedInstance.dismiss(withDelay: delay, withDuration: duration)
    }
}
