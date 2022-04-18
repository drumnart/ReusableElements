//
//  HalfmodalController.swift
//
//  Created by Sergey Gorin on 18/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

/// MoPup - is a helper component for presenting half modal popups

class MoPup: NSObject {
    
    enum Mode {
        case halfmodal
        case modal
        case fullScreen
    }
    
    enum State {
        case collapsed
        case opened
        
        struct Parameters: BlockScopable {
            var height: CGFloat
            var cornersRadius: CGFloat
            var overlayAlpha: CGFloat
            var isPanGestureEnabled: Bool
            
            init(height: CGFloat,
                 cornersRadius: CGFloat = 10,
                 overlayAlpha: CGFloat = 0.5,
                 panGestureEnabled: Bool = true) {
                self.height = height
                self.cornersRadius = cornersRadius
                self.overlayAlpha = overlayAlpha
                self.isPanGestureEnabled = panGestureEnabled
            }
            
            static func defaultCollapsed(height: CGFloat) -> Parameters {
                return Parameters(height: height, cornersRadius: 0, overlayAlpha: 0)
            }
            
            static func defaultOpened(height: CGFloat) -> Parameters {
                return Parameters(height: height, cornersRadius: 10, overlayAlpha: 0.5)
            }
            
            static func params(height: CGFloat,
                               cornersRadius: CGFloat = 0,
                               overlayAlpha: CGFloat = 0.5,
                               panGestureEnabled: Bool = true) -> Parameters {
                return Parameters(
                    height: height,
                    cornersRadius: cornersRadius,
                    overlayAlpha: overlayAlpha,
                    panGestureEnabled: panGestureEnabled
                )
            }
            
            static var unexpected: Parameters {
                defer {
                    assert(false, "Trying to set parameters for unexpected MoPup state")
                }
                return Parameters(height: 0)
            }
        }
    }
    
    struct Settings {
        var onTapAnimationDuration = 0.5
        var onPanAnimationDuration = 0.5
        var isOverlayDimmingEnabled = true
    }
    
    var settings = Settings()
    
    /// Callback for additional animations
    var relatedAnimations: ((State) -> ())?
    
    /// Callback for additional completions
    var relatedCompletions: ((State, UIViewAnimatingPosition) -> ())?
    
    var animatorsForState: ((_ state: State, _ duration: TimeInterval) -> ([UIViewPropertyAnimator]))?
    
    private var changeStateClosure: ((_ old: State, _ new: State) -> ())?
    
    private(set) lazy var overlayView = UIView().with {
        $0.backgroundColor = .black
        $0.alpha = 0.0
        $0.addGestureRecognizer(
            UITapGestureRecognizer(target: self, action: #selector(overlayTapped))
        )
    }
    
    private(set) lazy var contentContainer = UIView().with {
//        $0.backgroundColor = .white
        $0.clipsToBounds = true
        
        if #available(iOS 11.0, *) {
            $0.layer.maskedCorners = [.layerMaxXMinYCorner, .layerMinXMinYCorner]
        }
        $0.layer.shadowColor = UIColor.black.cgColor
        $0.layer.shadowOpacity = 0.1
        $0.layer.shadowRadius = 10
        $0.addGestureRecognizer(popupPanGestureRecognizer)
    }
    
    private(set) lazy var popupPanGestureRecognizer = UIPanGestureRecognizer(
        target: self,
        action: #selector(popupPanned)).with {
            $0.isEnabled = parameters(for: self.state).isPanGestureEnabled
    }
    
    private var bottomConstr: NSLayoutConstraint!
    private var heightConstr: NSLayoutConstraint!
    
    private var collapsedStateHeight: CGFloat = 0 {
        didSet {
            updateLayout(for: state)
        }
    }
    
    private var openedStateHeight: CGFloat = 0 {
        didSet {
            heightConstr?.constant = openedStateHeight
            updateLayout(for: state)
        }
    }
    
    private(set) weak var superview: UIView!
    
    private(set) weak var contentView: UIView! {
        didSet {
            contentView?.xt.pinEdges()
        }
    }
    
    private(set) var state: State = .collapsed {
        didSet {
            changeStateClosure?(oldValue, state)
        }
    }
    
    private var runningAnimators = [UIViewPropertyAnimator]()
    
    private var animationProgress = [CGFloat]()
    
    static let defaultStates: [State: State.Parameters] = [
        .collapsed: .defaultCollapsed(height: UIScreen.main.bounds.height * 0.15),
        .opened: .defaultOpened(height: UIScreen.main.bounds.height * 0.7)
    ]
    
    private var supportedStates: [State: State.Parameters]
    
    init(with contentView: UIView,
         in superview: UIView,
         supportedStates: [State: State.Parameters] = defaultStates) {
        self.supportedStates = supportedStates
        self.contentView = contentView
        self.superview = superview
        super.init()
        self.layout()
    }
}

extension MoPup {
    
    func setState(_ state: State, duration: TimeInterval = 0.5) {
        if superview?.subviews.contains(contentContainer) == false {
            layout()
        }
        animateTransition(to: state, duration: duration)
    }
    
    func setHeight(_ height: CGFloat, for state: State) {
        guard supportedStates[state] != nil else { return }
        
        let currentParameters = parameters(for: state)
        supportedStates[state] = State.Parameters(
            height: height,
            cornersRadius: currentParameters.cornersRadius,
            overlayAlpha: currentParameters.overlayAlpha,
            panGestureEnabled: currentParameters.isPanGestureEnabled
        )
        
        switch state {
        case .collapsed: collapsedStateHeight = height
        case .opened: openedStateHeight = height
        }
    }
    
    func onStateDidChange(_ closure: ((_ old: State, _ new: State) -> ())?) {
        changeStateClosure = closure
    }
    
    func setPopupPanGestureEnabled(_ enabled: Bool, for state: State) {
        supportedStates[state]?.isPanGestureEnabled = enabled
        popupPanGestureRecognizer.isEnabled = enabled
    }
    
    func removeFromSuperview() {
        setState(.collapsed)
        contentContainer.removeFromSuperview()
        overlayView.removeFromSuperview()
        contentView.removeFromSuperview()
    }
}

extension MoPup {
    
    private var bottomOffset: CGFloat {
        return openedStateHeight - collapsedStateHeight
    }
    
    private func parameters(for state: State) -> State.Parameters {
        return supportedStates[state] ?? .unexpected
    }
    
    private func layout() {
        superview.xt.addSubviews(overlayView, contentContainer)
        contentContainer.addSubview(contentView)
        contentView.xt.pinEdges()
        overlayView.xt.pinEdges()

        contentContainer.xt.layout {
            $0.pinEdges([.left, .right])
            bottomConstr = $0.bottom(0, to: superview.xt.bottom)
            heightConstr = $0.height(0)
        }
        
        collapsedStateHeight = parameters(for: .collapsed).height
        openedStateHeight = parameters(for: .opened).height
        
        superview.layoutIfNeeded()
    }
}

extension MoPup {
    
    private func proposeNextState() -> State {
        switch state {
        case .collapsed: return .opened
        case .opened: return .collapsed
        }
    }
    
    @objc private func overlayTapped(recognizer: UITapGestureRecognizer) {
        animateTransition(to: .collapsed,
                          duration: settings.onTapAnimationDuration)
    }
    
    @objc private func popupPanned(recognizer: UIPanGestureRecognizer) {
        switch recognizer.state {
        case .began:
            
            animateTransition(to: proposeNextState(),
                              duration: settings.onPanAnimationDuration)
            runningAnimators.forEach { $0.pauseAnimation() }
            animationProgress = runningAnimators.map { $0.fractionComplete }
            
        case .changed:
            
            let translation = recognizer.translation(in: contentContainer)
            
            let distance = openedStateHeight
            var fraction = -translation.y / distance
            
            switch state {
            case .opened:
                fraction *= -1
                
            case .collapsed: break
            }
            
            let isReversedTransition = runningAnimators[0].isReversed
            if isReversedTransition { fraction *= -1 }
        
            for (index, animator) in runningAnimators.enumerated() {
                animator.fractionComplete = fraction + animationProgress[index]
            }
            
        case .ended:
            
            let yVelocity = recognizer.velocity(in: contentContainer).y
            
            if yVelocity == 0 {
                runningAnimators.forEach {
                    $0.continueAnimation(withTimingParameters: nil, durationFactor: 0)
                }
                break
            }
            
            let isCollapsing = yVelocity > 0
            let isReversedTransition = runningAnimators[0].isReversed
            
            // reverse the animations
            switch state {
            case .opened:
                if !isCollapsing && !isReversedTransition || isCollapsing && isReversedTransition {
                    runningAnimators.forEach { $0.isReversed = !$0.isReversed }
                }
                
            case .collapsed:
                if isCollapsing && !isReversedTransition || !isCollapsing && isReversedTransition {
                    runningAnimators.forEach { $0.isReversed = !$0.isReversed }
                }
            }
            
            let velocityVector = CGVector(dx: 0, dy: yVelocity * 0.5)
            let springParams = UISpringTimingParameters(
                dampingRatio: 0.9,
                initialVelocity: velocityVector
            )
            runningAnimators.forEach {
                $0.continueAnimation(withTimingParameters: springParams, durationFactor: 1)
            }
            
        default: break
        }
    }
    
    private func animateTransition(to state: State,
                                   duration: TimeInterval,
                                   dampingRatio: CGFloat = 0.9) {
        
        guard runningAnimators.isEmpty else { return }
        
        let transitionAnimator = UIViewPropertyAnimator(
            duration: duration,
            dampingRatio: dampingRatio) {
            
                self.updateLayout(for: state)
                self.applyAnimations(for: state)
                self.relatedAnimations?(state)
                self.superview?.layoutIfNeeded()
        }
        transitionAnimator.addCompletion { position in
            
            switch position {
            case .start, .current: break
            case .end: self.state = state
            @unknown default: break
            }
            
            self.updateLayout(for: self.state)
            self.completeChanges(for: self.state)
            self.relatedCompletions?(state, position)
            self.runningAnimators.removeAll()
        }
        
        transitionAnimator.startAnimation()
        runningAnimators.append(transitionAnimator)
        
        animatorsForState?(state, duration).forEach {
            $0.startAnimation()
            runningAnimators.append($0)
        }
    }
    
    private func updateLayout(for state: State) {
        switch state {
        case .collapsed:
            bottomConstr.constant = bottomOffset
            
        case .opened:
            bottomConstr.constant = 0.0
        }
    }
    
    private func applyAnimations(for state: State) {
        let params = parameters(for: state)
        contentContainer.layer.cornerRadius = params.cornersRadius
        if self.settings.isOverlayDimmingEnabled {
            self.overlayView.alpha = params.overlayAlpha
        }
    }
    
    private func completeChanges(for state: State) {
        popupPanGestureRecognizer.isEnabled = parameters(for: state).isPanGestureEnabled
    }
}
