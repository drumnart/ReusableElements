//
//  SlideOutTransitionManager.swift
//
//  Created by Sergey Gorin on 01/07/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class SlideOutTransitionManager: NSObject {
    
    typealias StatusBarConfigurator = (SlideOutMenu.TransitionMode) -> SlideOutMenu.StatusBarConfiguration
    typealias StatusBarUpdator = (_ config: SlideOutMenu.StatusBarConfiguration) -> ()
    
    let isPresenting: Observable<Bool> = Observable(false)
    
    /// Configurator of transition animation parameters
    var animationConfig: (_ mode: SlideOutMenu.TransitionMode) -> SlideOutMenu.AnimationConfiguration = {
        switch $0 {
        case .presentation:
            return SlideOutMenu.AnimationConfiguration(
                dampingRatio: 0.8,
                springVelocity: 0.9,
                options: [.overrideInheritedOptions]
            )
            
        case .dismissal:
            return SlideOutMenu.AnimationConfiguration(
                delay: 0.1, // Delay > 0 to fix animation glitches in iOS 11.
                options: [.overrideInheritedOptions]
            )
        }
    }
    
    /// Closure for settings animation parameters.
    /// If it equals nil then `defaultStatusBarConfigurator` is used.
    var statusBarConfigurator: StatusBarConfigurator?
    
    /// Closure for making changes or animations of status bar if needed
    var statusBarUpdator: StatusBarUpdator?
    
    var thresholdToEnd: CGFloat = 0.15
    var interactionVelocity: CGFloat = 0.5
    
    var canvasColor: UIColor?
    
    private(set) var visibleRate: CGFloat = 1.0
    
    private var interactor = SlideOutTransition()
    
    private var primaryContentController: UIViewController?
    
    private var drawerContentControllers: [SlideOutMenu.Edge: UIViewController] = [:]
    
    private var edge: SlideOutMenu.Edge = .left
    
    private(set) var sideViewControllerWrapper: SlidableSideViewController?
    
    private var defaultStatusBarConfigurator: StatusBarConfigurator = {
        return SlideOutMenu.StatusBarConfiguration(isHidden: $0 == .presentation)
    }
    
    private var transitionMode: SlideOutMenu.TransitionMode {
        return isPresenting.value ? .dismissal : .presentation
    }
    
    private var transitionDirection: SlideOutMenu.Direction {
        switch transitionMode {
        case .presentation: return edge.direction
        case .dismissal: return edge.direction.opposite
        }
    }
    
    init(primaryContentController: UIViewController) {
        super.init()
        self.primaryContentController = primaryContentController
        setupObservers()
    }
    
    private func setupObservers() {
        interactor.state.observe() { [unowned self] in
            switch ($0.new, self.transitionMode) {
            case (.started, .presentation):
                self.statusBarUpdator?(self.statusBarConfiguration(for: self.transitionMode))
                
            case (.started, .dismissal):
                self.dismissDrawer(animated: true)
                
            case (.canceled, _):
                self.statusBarUpdator?(self.statusBarConfiguration(for: self.transitionMode.opposite))
                
            case (.finished, .dismissal):
                self.sideViewControllerWrapper = nil
                self.statusBarUpdator?(self.statusBarConfiguration(for: self.transitionMode))
                
            default: break
            }
        }
    }
    
    private func statusBarConfiguration(for mode: SlideOutMenu.TransitionMode) -> SlideOutMenu.StatusBarConfiguration {
        return statusBarConfigurator?(mode) ?? defaultStatusBarConfigurator(mode)
    }
}

extension SlideOutTransitionManager {
    
    func setDrawerContentController(_ vc: UIViewController, for edge: SlideOutMenu.Edge) {
        drawerContentControllers[edge] = vc
    }
    
    func removeDrawerContentController(for edge: SlideOutMenu.Edge) {
        drawerContentControllers.removeValue(forKey: edge)
    }
    
    func presentDrawer(from edge: SlideOutMenu.Edge,
                       showingRate visibleRate: CGFloat = 0.87,
                       withDuration duration: TimeInterval = 0.3,
                       completion: (() -> Void)? = nil) {
        
        guard let presentable = drawerContentControllers[edge] else {
            print("[Error] - \(className): Side controller for \(edge) edge was not set.")
            return
        }
        
        self.edge = edge
        self.visibleRate = visibleRate
        
        sideViewControllerWrapper = SlidableSideViewController().with {
            $0.edge = edge
            $0.contentVisibleRate = visibleRate
            $0.canvasColor = canvasColor
            $0.transitioningDelegate = self
            $0.modalPresentationStyle = .custom
            $0.addChild(presentable)
            $0.loadViewIfNeeded()
            $0.contentView?.addSubview(presentable.view)
            $0.restAreaView?.xt.onTap { [weak self] _ in
                guard let s = self else { return }
                s.dismissDrawer(animated: true) {
                    s.statusBarUpdator?(s.statusBarConfiguration(for: .dismissal))
                }
            }
            $0.view.xt.onPan { [weak self] pan in
                self?.interactor.sync(with: pan)
            }
            
            presentable.preferredContentSize = $0.contentView.bounds.size
            presentable.view.xt.pinEdges()
            presentable.didMove(toParent: $0)
            presentable.view.layoutIfNeeded()
            
            primaryContentController?.present($0, animated: true, completion: completion)
            statusBarUpdator?(statusBarConfiguration(for: .presentation))
        }
    }
    
    func dismissDrawer(animated: Bool = true, completion: (() -> Void)? = nil) {
        guard let sideVC = sideViewControllerWrapper, !sideVC.isBeingDismissed else { return }
        sideVC.dismiss(animated: animated, completion: {
            completion?()
        })
    }
}

extension SlideOutTransitionManager: UIViewControllerTransitioningDelegate {
    
    func animationController(forPresented presented: UIViewController,
                             presenting: UIViewController,
                             source: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideOutAnimator().with {
            $0.direction = edge.direction
            $0.presentedConfig.visibleRate = visibleRate
            $0.animationConfig = animationConfig(.presentation)
        }
    }
    
    func animationController(forDismissed dismissed: UIViewController) -> UIViewControllerAnimatedTransitioning? {
        return SlideOutAnimator().with {
            $0.direction = edge.direction.opposite
            $0.animationConfig = animationConfig(.dismissal)
        }
    }
    
    func presentationController(forPresented presented: UIViewController,
                                presenting: UIViewController?,
                                source: UIViewController) -> UIPresentationController? {
        return SlideOutPresentationController(presentedViewController: presented, presenting: presenting).with {
            $0.visibleRate = visibleRate
            $0.presentingDirection = transitionDirection
            $0.isPresenting.observe { [weak self] in
                self?.isPresenting.set($0.new)
            }
        }
    }
    
    func interactionControllerForPresentation(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            guard case .started = interactor.state.value else { return nil }
            return interactor.with { $0.params.direction = transitionDirection }
    }
    
    func interactionControllerForDismissal(using animator: UIViewControllerAnimatedTransitioning)
        -> UIViewControllerInteractiveTransitioning? {
            guard case .started = interactor.state.value else { return nil }
            return interactor.with { $0.params.direction = transitionDirection }
    }
}
