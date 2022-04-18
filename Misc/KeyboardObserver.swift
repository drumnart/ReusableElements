//
//  KeyboardObserver.swift
//
//  Created by Sergey Gorin on 18/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

protocol KeyboardObservable {
    
    associatedtype AnimationCallback
    
    var animationCallback: AnimationCallback { get set }
    
    func start()
    func stop()
    func keyboardDidChange(_ notification: Notification)
}

class KeyboardObserver: KeyboardObservable {
    
    enum KeyboardAnimationState {
        case willShow
        case willHide
        case isShowing
        case isHiding
        case didShow
        case didHide
    }
    
    var animationCallback: (_ state: KeyboardAnimationState, _ height: CGFloat) -> () = {_,_  in}
    
    var keyboardRect = CGRect.zero
    
    deinit {
        stop()
    }
    
    func start() {
        let center = NotificationCenter.default
        center.addUniqueObserver(self,
                                 selector: #selector(keyboardDidChange(_:)),
                                 name: UIResponder.keyboardWillShowNotification,
                                 object: nil)
        center.addUniqueObserver(self,
                                 selector: #selector(keyboardDidChange(_:)),
                                 name: UIResponder.keyboardDidShowNotification,
                                 object: nil)
        center.addUniqueObserver(self,
                                 selector: #selector(keyboardDidChange(_:)),
                                 name: UIResponder.keyboardWillHideNotification,
                                 object: nil)
        center.addUniqueObserver(self,
                                 selector: #selector(keyboardDidChange(_:)),
                                 name: UIResponder.keyboardDidHideNotification,
                                 object: nil)
    }
    
    func stop() {
        NotificationCenter.default.removeObserver(self)
    }
    
    @objc internal func keyboardDidChange(_ notification: Notification) {
        
        let userInfo = notification.userInfo ?? [:]
        let duration = (userInfo[UIResponder.keyboardAnimationDurationUserInfoKey] as? NSNumber)?.doubleValue ?? 0
        let animationCurveRawValue = (userInfo[UIResponder.keyboardAnimationCurveUserInfoKey] as? NSNumber)?.uintValue ?? 0
        let options: UIView.AnimationOptions = [UIView.AnimationOptions(rawValue: animationCurveRawValue), .layoutSubviews]
        let rect = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue ?? .zero
        
        switch notification.name {
        case UIResponder.keyboardWillShowNotification:
            
            self.animationCallback(.willShow, 0)
            
            UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                self.animationCallback(.isShowing, rect.height)
            }, completion: nil)
            keyboardRect = rect
            
        case UIResponder.keyboardDidShowNotification:
            animationCallback(.didShow, keyboardRect.height)
            
        case UIResponder.keyboardWillHideNotification:
            
            self.animationCallback(.willHide, rect.height)
            
            UIView.animate(withDuration: duration, delay: 0.0, options: options, animations: {
                self.animationCallback(.isHiding, 0)
            }, completion: nil)
            keyboardRect = .zero
            
        case UIResponder.keyboardDidHideNotification:
            animationCallback(.didHide, keyboardRect.height)
            
        default: return
        }
    }
}

