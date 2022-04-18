//
//  Xt+PullToRefresh.swift
//
//  Created by Sergey Gorin on 19/03/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit.UIScrollView

// MARK: - `UIScrollView` + PullToRefresh
extension Xt where Base: UIScrollView {
    
    /// Another name for `refreshControl`
    public var refreshView: UIRefreshControl? {
        return _refreshControl
    }
    
    /// Refresh Status
    public var isRefreshing: Bool {
        return _refreshControl?.isRefreshing ?? false
    }
    
    /// Can be used to add and cofigure custom refreshControl if needed.
    @discardableResult
    public func setupRefreshControl(_ closure: () -> UIRefreshControl) -> Self {
        let refreshControl = closure()
        refreshControl.addTarget(base, action: #selector(base.pullToRefresh(_:)), for: .valueChanged)
        if #available(iOS 10.0, *) {
            base.refreshControl = refreshControl
        } else {
            base.addSubview(refreshControl)
        }
        return self
    }
    
    /// Used to add and cofigure refreshControl (just another way using @autoclosure).
    @discardableResult
    public func addRefreshControl(_ closure: @autoclosure () -> UIRefreshControl) -> Self {
        return setupRefreshControl(closure)
    }
    
    @discardableResult
    public func removeRefreshControl() -> Self {
        if #available(iOS 10.0, *) {
            base.refreshControl = nil
        } else {
            _refreshControl?.removeFromSuperview()
        }
        return self
    }
    
    /// Used for handling PullToRefresh action. Creates instance of UIRefreshControl if it doesn't already exist.
    @discardableResult
    public func onPullToRefresh(_ closure: @escaping UIScrollView.PullToRefreshCallback) -> Self {
        if _refreshControl == nil { addRefreshControl(UIRefreshControl()) }
        base.pullToRefreshCallback = closure
        return self
    }
    
    /// Starts animating `refreshControl`
    public func beginRefreshing() {
        guard let refreshControl = _refreshControl, !refreshControl.isRefreshing else {
            return
        }
        
        refreshControl.beginRefreshing()
//        refreshControl.sendActions(for: .valueChanged)
        
//        let contentOffset = CGPoint(x: 0, y: -refreshControl.frame.height)

        let contentOffset = CGPoint(x: 0, y: base.contentOffset.y - refreshControl.frame.height)
        base.setContentOffset(contentOffset, animated: true)
    }
    
    /// Stops animating `refreshControl`
    public func endRefreshing(animated: Bool = false,
                              duaration: TimeInterval = 0.3,
                              delay: TimeInterval = 0.3,
                              completion: ((Bool) -> ())? = nil) {
        
        guard isRefreshing == true else { return }
        
        if animated {
            UIView.animate(
                withDuration: duaration,
                delay: delay,
                options: [],
                animations: {
                    self._refreshControl?.endRefreshing()
            }, completion: completion)
        } else {
            _refreshControl?.endRefreshing()
        }
    }
    
    private var _refreshControl: UIRefreshControl? {
        if #available(iOS 10.0, *) {
            return base.refreshControl
        } else {
            return base.subviews.filter { $0 is UIRefreshControl }.first as? UIRefreshControl
        }
    }
}

extension UIScrollView {
    
    public typealias PullToRefreshCallback = (_ sender: UIRefreshControl) -> ()
    
    @objc fileprivate func pullToRefresh(_ sender: UIRefreshControl) {
        pullToRefreshCallback?(sender)
    }
    
    private struct Keys {
        fileprivate static let pullToRefresh = AssociatedKey("pullToRefreshKey_" + UUID().uuidString)
    }
    
    fileprivate var pullToRefreshCallback: PullToRefreshCallback? {
        get { return getAssociatedObject(forKey: Keys.pullToRefresh) }
        set { setAssociatedObject(newValue, forKey: Keys.pullToRefresh) }
    }
}
