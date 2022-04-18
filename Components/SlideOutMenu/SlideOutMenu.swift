//
//  SlideOutMenu.swift
//
//  Created by Sergey Gorin on 01/07/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

struct SlideOutMenu {
    
    typealias TransitionManager = SlideOutTransitionManager
    
    enum Edge {
        case top, left, bottom, right
        
        var direction: Direction {
            switch self {
            case .top: return .down
            case .left: return .right
            case .bottom: return .up
            case .right: return .left
            }
        }
    }
    
    enum Direction {
        case up, down, left, right
        
        var opposite: Direction {
            switch self {
            case .up: return .down
            case .down: return .up
            case .left: return .right
            case .right: return .left
            }
        }
    }
    
    enum TransitionMode {
        case presentation
        case dismissal
        
        var opposite: TransitionMode {
            switch self {
            case .presentation: return .dismissal
            case .dismissal: return .presentation
            }
        }
    }
    
    struct AnimationConfiguration {
        
        var duration: TimeInterval
        var delay: TimeInterval
        var dampingRatio: CGFloat
        var springVelocity: CGFloat
        var options: UIView.AnimationOptions
        
        init(duration: TimeInterval = 0.6,
             delay: TimeInterval = 0.0,
             dampingRatio: CGFloat = 1.0,
             springVelocity: CGFloat = 0.0,
             options: UIView.AnimationOptions = []) {
            self.duration = duration
            self.delay = delay
            self.dampingRatio = dampingRatio
            self.springVelocity = springVelocity
            self.options = options
        }
    }
    
    struct StatusBarConfiguration {
        var style: UIStatusBarStyle
        var isHidden: Bool
        
        static var `default` = StatusBarConfiguration()
        
        init(style: UIStatusBarStyle = .default,
             isHidden: Bool = true) {
            self.style = style
            self.isHidden = isHidden
        }
    }
    
    struct TransitionParams {
        var visibleRate: CGFloat = 1.0
        var thresholdToEnd: CGFloat = 0.15
        var interactionVelocity: CGFloat = 0.5
        var direction: SlideOutMenu.Direction
        
        static let `default` = TransitionParams(visibleRate: 1.0,
                                                thresholdToEnd: 0.15,
                                                interactionVelocity: 0.5,
                                                direction: .right)
        
        init(visibleRate: CGFloat = 1.0,
             thresholdToEnd: CGFloat = 0.15,
             interactionVelocity: CGFloat = 0.5,
             direction: SlideOutMenu.Direction  = .right) {
            self.visibleRate = visibleRate
            self.thresholdToEnd = thresholdToEnd
            self.interactionVelocity = interactionVelocity
            self.direction = direction
        }
    }
}
