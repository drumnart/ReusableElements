//
//  HidingBarDelegate.swift
//
//  Created by Sergey Gorin on 19/03/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class HidingBarDelegate: NSObject, UIScrollViewDelegate {

    weak var bar: UIView?
    
    var topConstr: NSLayoutConstraint!
    var hidingHeightConstr: NSLayoutConstraint!
    
    var adjustedTopInset: CGFloat {
        return hidingHeightConstr.constant + topConstr.constant
    }
    
    private var threshold: CGFloat = 0.0
    private var lastScrollOffset: CGPoint = .zero
    
    func hide(duration: Double = 0.0, animated: Bool = true) {
        if topConstr.constant != -hidingHeightConstr.constant {
            topConstr.constant = -hidingHeightConstr.constant
            bar?.setNeedsLayout()
            UIView.animate(withDuration: animated ? duration : duration, delay: 0.0, options: .curveEaseIn, animations: {
                if let superview = self.bar?.superview {
                    superview.layoutIfNeeded()
                } else {
                    self.bar?.layoutIfNeeded()
                }
            }, completion: nil)
        }
    }
    
    func show(duration: Double = 0.0, animated: Bool = true) {
        if topConstr.constant != 0 {
            topConstr.constant = 0
            bar?.setNeedsLayout()
            UIView.animate(withDuration: animated ? duration : duration, animations: {
                if let superview = self.bar?.superview {
                    superview.layoutIfNeeded()
                } else {
                    self.bar?.layoutIfNeeded()
                }
            }, completion: nil)
        }
    }
    
    private func setFinalHeight(_ scrollView: UIScrollView) {
        if scrollView.contentOffset.y >= 0 {
            if topConstr.constant >= -hidingHeightConstr.constant.half {
                show()
            } else {
                hide()
            }
        }
    }
    
    func scrollViewDidScroll(_ scrollView: UIScrollView) {
        let minTopOffset: CGFloat = -hidingHeightConstr.constant
        let maxTopOffset: CGFloat = 0
        var barTopOffset = topConstr.constant
        
        let contentOffset: CGPoint = scrollView.contentOffset
        var contentInset: UIEdgeInsets = scrollView.contentInset
        
        let delta = lastScrollOffset.y - contentOffset.y
        barTopOffset += delta
        
        let isTail: Bool = (contentOffset.y + scrollView.frame.size.height) > scrollView.contentSize.height
        
        if barTopOffset > maxTopOffset {
            barTopOffset = maxTopOffset
        }
        
        if barTopOffset < minTopOffset {
            barTopOffset = minTopOffset
        }
        
        if !isTail {
            if contentOffset.y > -contentInset.top {
                topConstr.constant = barTopOffset
            }
            contentInset.top = adjustedTopInset
        }
        
        lastScrollOffset = contentOffset
    }
    
    func scrollViewWillBeginDragging(_ scrollView: UIScrollView) {
        lastScrollOffset = scrollView.contentOffset
    }
    
    func scrollViewDidEndDragging(_ scrollView: UIScrollView,
                                  willDecelerate decelerate: Bool) {
        if !decelerate {
            setFinalHeight(scrollView)
        }
    }
    
    func scrollViewDidEndDecelerating(_ scrollView: UIScrollView) {
        setFinalHeight(scrollView)
    }
}
