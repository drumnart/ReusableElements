//
//  SlideOutPresentationController.swift
//
//  Created by Sergey Gorin on 01/07/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class SlideOutPresentationController: UIPresentationController {
    
    var presentingDirection: SlideOutMenu.Direction = .right
    var visibleRate: CGFloat = 1.0
    
    let isPresenting: Observable<Bool> = Observable(false)
    
    override var shouldRemovePresentersView: Bool {
        return false
    }
    
    override func presentationTransitionDidEnd(_ completed: Bool) {
        isPresenting.set(completed)
    }
    
    override func dismissalTransitionDidEnd(_ completed: Bool) {
        isPresenting.set(!completed)
    }
    
    override func viewWillTransition(to size: CGSize, with coordinator: UIViewControllerTransitionCoordinator) {
        guard isPresenting.value else { return }
        super.viewWillTransition(to: size, with: coordinator)
        coordinator.animate(alongsideTransition: { (context) in
            self.presentingViewController.view?.frame = self.adjustFrame(using: size)
        })
    }
    
    fileprivate func adjustFrame(using size: CGSize) -> CGRect {
        switch presentingDirection {
        case .up: return CGRect(origin: CGPoint(x: 0, y: -size.height * visibleRate), size: size)
        case .down: return CGRect(origin: CGPoint(x: 0, y: size.height * visibleRate), size: size)
        case .left: return CGRect(origin: CGPoint(x: -size.width * visibleRate, y: 0), size: size)
        case .right: return CGRect(origin: CGPoint(x: size.width * visibleRate, y: 0), size: size)
        }
    }
}
