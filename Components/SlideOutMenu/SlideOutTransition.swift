//
//  SlideOutTransition.swift
//
//  Created by Sergey Gorin on 01/07/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class SlideOutTransition: UIPercentDrivenInteractiveTransition {
    
    enum TransitionState {
        case unknown
        case started
        case changed(progress: CGFloat)
        case canceled
        case finished
    }
    
    let state: Observable<TransitionState> = Observable(.unknown)
    var params: SlideOutMenu.TransitionParams = .default
}

extension SlideOutTransition {
    
    func sync(with pan: UIPanGestureRecognizer) {
        
        switch pan.state {
        case .began:
            state.set(.started)
            
        case .changed:
            let progress = getProgress(of: pan)
            //            print("progress =", progress)
            update(progress)
            state.set(.changed(progress: progress))
            
        case .ended:
            
            if percentComplete > params.thresholdToEnd {
                completionSpeed = 0.9
                finish()
                state.set(.finished)
            } else {
                completionSpeed = 0.2
                cancel()
                state.set(.canceled)
            }
            
        default:
            cancel()
            state.set(.canceled)
        }
    }
    
    private func getProgress(of gesture: UIPanGestureRecognizer) -> CGFloat {
        
        let bounds = gesture.view?.bounds ?? .zero
        let visibleWidth = bounds.width * params.visibleRate
        let visibleHeight = bounds.height * params.visibleRate
        let translation = gesture.translation(in: gesture.view)
        let velocityMult = params.interactionVelocity
        
        switch params.direction {
        case .left: return abs(min(translation.x * velocityMult /? visibleWidth, 0.0))
        case .right: return abs(max(translation.x * velocityMult /? visibleWidth, 0.0))
        case .up: return abs(min(translation.y * velocityMult /? visibleHeight, 0.0))
        case .down: return abs(max(translation.y * velocityMult /? visibleHeight, 0.0))
        }
    }
}
