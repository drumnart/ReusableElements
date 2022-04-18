//
//  SlideOutAnimator.swift
//
//  Created by Sergey Gorin on 01/07/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class SlideOutAnimator: NSObject {
    
    struct PresenterConfig {
        var initialShadowOpacity: Float = 0.0
        var finalShadowOpacity: Float = 0.9
        var finalDimmingColor: UIColor = .black
        var finalDimmingAlpha: CGFloat = 0.54
        
        fileprivate var dimmingViewId: String { return #function }
    }
    
    struct PresentedConfig {
        var visibleRate: CGFloat = 0.9
        var initialAlpha: CGFloat = 0.2
        var finalAlpha: CGFloat = 1.0
    }
    
    var presenterConfig: PresenterConfig = PresenterConfig()
    var presentedConfig: PresentedConfig = PresentedConfig()
    
    var direction: SlideOutMenu.Direction = .right
    var animationConfig = SlideOutMenu.AnimationConfiguration()
}

extension SlideOutAnimator: UIViewControllerAnimatedTransitioning {
    
    func transitionDuration(using transitionContext: UIViewControllerContextTransitioning?) -> TimeInterval {
        return animationConfig.duration
    }
    
    func animateTransition(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard let toVC = transitionContext.viewController(forKey: .to) else { return }
        
        toVC.isBeingPresented
            ? animatePresentation(using: transitionContext)
            : animateDismissal(using: transitionContext)
    }
    
    func animatePresentation(using transitionContext: UIViewControllerContextTransitioning) {
        
        guard
            let toView = transitionContext.view(forKey: .to),
            let fromView = transitionContext.viewController(forKey: .from)?.view else {
                return
        }
        
        let containerView = transitionContext.containerView
        containerView.addSubview(toView)
        containerView.addSubview(fromView)
        
        let dimmingView = UIView().with {
            $0.xt.setId(presenterConfig.dimmingViewId)
            $0.isUserInteractionEnabled = false
            $0.backgroundColor = presenterConfig.finalDimmingColor
            $0.alpha = 0.0
            fromView.addSubview($0)
            $0.xt.pinEdges()
        }
        
        fromView.isUserInteractionEnabled = false
        fromView.layer.shadowOpacity = presenterConfig.finalShadowOpacity
        
        toView.frame.origin = finalPoint(for: direction.opposite, withRate: (1 - presentedConfig.visibleRate),
                                         using: transitionContext)
        toView.alpha = presentedConfig.initialAlpha
        
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: animationConfig.delay,
                       usingSpringWithDamping: animationConfig.dampingRatio,
                       initialSpringVelocity: animationConfig.springVelocity,
                       options: animationConfig.options,
                       animations: {
                        fromView.frame.origin = self.finalPoint(for: self.direction,
                                                                withRate: self.presentedConfig.visibleRate,
                                                                using: transitionContext)
                        dimmingView.alpha = self.presenterConfig.finalDimmingAlpha
                        toView.frame.origin = .zero
                        toView.alpha = self.presentedConfig.finalAlpha
        }, completion: { _ in
            transitionContext.completeTransition(!transitionContext.transitionWasCancelled)
        })
    }
    
    func animateDismissal(using transitionContext: UIViewControllerContextTransitioning) {
        guard
            let toVC = transitionContext.viewController(forKey: .to),
            let fromView = transitionContext.view(forKey: .from) else {
                return
        }
        
        let dimmingView = toVC.view.xt.getSubview(withId: presenterConfig.dimmingViewId)
        let finalFrame = transitionContext.finalFrame(for: toVC)
        
        // Bug: There's animation glitch in iOS 11 if delay is equal zero. Workaround: Set delay > 0
        UIView.animate(withDuration: transitionDuration(using: transitionContext),
                       delay: animationConfig.delay,
                       usingSpringWithDamping: animationConfig.dampingRatio,
                       initialSpringVelocity: animationConfig.springVelocity,
                       options: animationConfig.options,
                       animations: {
                        fromView.frame.origin = self.finalPoint(for: self.direction,
                                                                withRate: (1 - self.presentedConfig.visibleRate),
                                                                using: transitionContext)
                        fromView.alpha = self.presentedConfig.initialAlpha
                        toVC.view.frame = finalFrame
                        dimmingView?.alpha = 0.0
        }, completion: { _ in
            let canComplete = !transitionContext.transitionWasCancelled
            if canComplete {
                dimmingView?.removeFromSuperview()
                UIApplication.shared.keyWindow?.addSubview(toVC.view)
                toVC.view.isUserInteractionEnabled = true
                toVC.view.layer.shadowOpacity = self.presenterConfig.initialShadowOpacity
            }
            transitionContext.completeTransition(canComplete)
        })
    }
}

// MARK: - Helpers
extension SlideOutAnimator {
    
    fileprivate func finalPoint(for direction: SlideOutMenu.Direction,
                                withRate visibleRate: CGFloat,
                                using transitionContext: UIViewControllerContextTransitioning) -> CGPoint {
        let bounds = transitionContext.containerView.bounds
        switch direction {
        case .up: return  CGPoint(x: 0, y: -bounds.height * visibleRate)
        case .down: return CGPoint(x: 0, y: bounds.height * visibleRate)
        case .left: return CGPoint(x: -bounds.width * visibleRate, y: 0)
        case .right: return CGPoint(x: bounds.width * visibleRate, y: 0)
        }
    }
}
