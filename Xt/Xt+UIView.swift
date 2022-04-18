//
//  Xt+UIView.swift
//
//  Created by Sergey Gorin on 03/12/2018.
//  Copyright © 2018 Sergey Gorin. All rights reserved.
//

import UIKit

extension UIView: XtCompatible {}

extension Xt where Base: UIView {
    
    /// Checks if any animation is in progress
    var isAnimating: Bool {
        guard let animationKeys = base.layer.animationKeys() else {
            return false
        }
        return animationKeys.count > 0
    }
    
    /// Status bar height for convinience
    var statusBarHeight: CGFloat {
        return UIApplication.shared.statusBarFrame.height
    }
    
    /// Returns optimal size for self
    var layoutFittingCompressedSize: CGSize {
        return base.systemLayoutSizeFitting(UIView.layoutFittingCompressedSize)
    }
    
    /// Add several subviews to view at once
    func addSubviews(_ subviews: [UIView]) {
        subviews.forEach { base.addSubview($0) }
    }
    
    /// Add several subviews to view at once
    func addSubviews(_ subviews: UIView...) {
        subviews.forEach { base.addSubview($0) }
    }
    
    /// Checks view's visibility in the given view or in it's superview if parameter 'view' is nil
    func isVisible(in view: UIView? = nil) -> Bool {
        guard base.alpha > 0 && !base.isHidden else { return false }
        guard let view = view ?? base.superview else { return true }
        
        let frame = view.convert(base.bounds, from: base)
        if frame.intersects(view.bounds) {
            return view.xt.isVisible(in: view.superview)
        }
        return false
    }
    
    func getSubview<T: LosslessStringConvertible>(withId id: T) -> UIView? {
        if base.accessibilityIdentifier == id.description { return base }
        for subview in base.subviews {
            if let result = subview.xt.getSubview(withId: id) { return result }
        }
        return nil
    }
    
    func setId<T: LosslessStringConvertible>(_ id: T) {
        base.accessibilityIdentifier = id.description
    }
    
    func visibleRect(in view: UIView? = nil) -> CGRect {
        guard base.alpha > 0 && !base.isHidden else { return .zero }
        guard let view = view ?? base.superview else { return base.frame }
        
        let frame = view.convert(base.bounds, from: base)
        return frame.intersection(view.bounds)
    }
    
    /// Improve drawing performance
    func rasterize(opaqued: Bool = true) {
        base.layer.shouldRasterize = true
        base.layer.rasterizationScale = UIScreen.main.scale
        base.isOpaque = opaqued
    }
    
    /// Make round corners
    func round(borderWidth: CGFloat = 0.0,
               borderColor: UIColor = .clear,
               cornerRadius: CGFloat = 0) {
        base.layer.cornerRadius = cornerRadius > 0 ? cornerRadius : base.frame.height * 0.5
        base.layer.borderColor = borderColor.cgColor
        base.layer.borderWidth = borderWidth
        base.layer.masksToBounds = true
    }
    
    /// Adds gradient sublayer
    @discardableResult
    func addGradient(inRect bounds: CGRect? = nil,
                     at index: UInt32 = 0,
                     colors: [UIColor] = [.black, .clear],
                     startPoint: CGPoint = CGPoint(x: 0.5, y: 0.0),
                     endPoint: CGPoint = CGPoint(x: 0.5, y: 1.0),
                     locations: [NSNumber]? = nil) -> CALayer {
        return CAGradientLayer().with {
            $0.frame = bounds ?? base.bounds
            $0.colors = colors.map { $0.cgColor }
            $0.startPoint = startPoint
            $0.endPoint = endPoint
            $0.locations = locations
            base.layer.insertSublayer($0, at: index)
        }
    }
    
    /// Sets shadow parameters to the view's layer
    func applyShadow(opacity: Float = 0.0,
                     offset: CGSize = CGSize(width: 0.0, height: 2.0),
                     radius: CGFloat = 3.0,
                     color: UIColor = UIColor.black.withAlphaComponent(0.16),
                     path: UIBezierPath? = nil,
                     shouldRasterize: Bool = false) {
        base.layer.shadowOpacity = opacity
        base.layer.shadowOffset = offset
        base.layer.shadowRadius = radius
        base.layer.shadowColor = color.cgColor
        base.layer.shadowPath = path?.cgPath ?? UIBezierPath(
            roundedRect: base.bounds,
            cornerRadius: base.layer.cornerRadius
        ).cgPath
        base.layer.shouldRasterize = shouldRasterize
        base.layer.masksToBounds = false
    }
    
    func hideShadow() {
        base.layer.shadowOpacity = 0.0
    }
    
    /// Calculates item size for given bounding width and number of items per line
    func suggestedSize(maxWidth: CGFloat? = nil,
                       interItemSpacing: CGFloat = 0.0,
                       lineSpacing: CGFloat = 0.0,
                       margins: UIEdgeInsets = .zero,
                       maxItemsPerRow: CGFloat = 2,
                       minRatio: CGFloat = 1.0,
                       multipliers: (x: Int, y: Int) = (1, 1)) -> CGSize {
        
        let maxWidth = maxWidth ?? base.frame.width
        let maxItemsPerRow = maxItemsPerRow > 0 ? maxItemsPerRow : 1
        let hSpacing = interItemSpacing * CGFloat(maxItemsPerRow - 1)
        let minWidth = (maxWidth - hSpacing - margins.leftRight) / maxItemsPerRow
        let minHeight = minWidth * minRatio
        let mult: (x: CGFloat, y: CGFloat) = (CGFloat(multipliers.x), CGFloat(multipliers.y))
        return CGSize(width: floor(minWidth * mult.x + interItemSpacing * (mult.x - 1)),
                      height: floor(minHeight * mult.y + lineSpacing * (mult.y - 1)))
    }
}

// MARK: - Gestures

extension UIView {
    
    private struct Keys {
        fileprivate static let tapClosure = AssociatedKey(
            "tapClosure_" + UUID().uuidString
        )
        fileprivate static let longPressClosure = AssociatedKey(
            "longPressClosure" + UUID().uuidString
        )
        fileprivate static let panClosure = AssociatedKey(
            "panClosure_" + UUID().uuidString
        )
        fileprivate static let edgePanClosure = AssociatedKey(
            "edgePanClosure_" + UUID().uuidString
        )
        fileprivate static let swipeClosure = AssociatedKey(
            "swipeClosure_" + UUID().uuidString
        )
    }
    
    typealias TapGestureRecognizerClosure = (UITapGestureRecognizer) -> Void
    typealias LongPressGestureRecognizerClosure = (UILongPressGestureRecognizer) -> Void
    typealias PanGestureRecognizerClosure = (UIPanGestureRecognizer) -> Void
    typealias EdgePanGestureRecognizerClosure = (UIScreenEdgePanGestureRecognizer) -> Void
    typealias SwipeGestureRecognizerClosure = (UISwipeGestureRecognizer) -> Void
    
    fileprivate var tapClosure: TapGestureRecognizerClosure? {
        get { return getAssociatedObject(forKey: Keys.tapClosure) }
        set { setAssociatedObject(newValue, forKey: Keys.tapClosure) }
    }
    
    fileprivate var longPressClosure: LongPressGestureRecognizerClosure? {
        get { return getAssociatedObject(forKey: Keys.longPressClosure) }
        set { setAssociatedObject(newValue, forKey: Keys.longPressClosure) }
    }
    
    fileprivate var panClosure: PanGestureRecognizerClosure? {
        get { return getAssociatedObject(forKey: Keys.panClosure) }
        set { setAssociatedObject(newValue, forKey: Keys.panClosure) }
    }
    
    fileprivate var edgePanClosure: EdgePanGestureRecognizerClosure? {
        get { return getAssociatedObject(forKey: Keys.edgePanClosure) }
        set { setAssociatedObject(newValue, forKey: Keys.edgePanClosure) }
    }
    
    fileprivate var swipeClosure: SwipeGestureRecognizerClosure? {
        get { return getAssociatedObject(forKey: Keys.swipeClosure) }
        set { setAssociatedObject(newValue, forKey: Keys.swipeClosure) }
    }
    
    @objc fileprivate func handleTap(_ tap: UITapGestureRecognizer) {
        tapClosure?(tap)
    }
    
    @objc fileprivate func handleLongPress(_ longPress: UILongPressGestureRecognizer) {
        longPressClosure?(longPress)
    }
    
    @objc fileprivate func handlePan(_ pan: UIPanGestureRecognizer) {
        panClosure?(pan)
    }
    
    @objc fileprivate func handleEdgePan(_ edgePan: UIScreenEdgePanGestureRecognizer) {
        edgePanClosure?(edgePan)
    }
    
    @objc fileprivate func handleSwipe(_ swipe: UISwipeGestureRecognizer) {
        swipeClosure?(swipe)
    }
}

extension Xt where Base: UIView {
    
    @discardableResult
    func onTap(_ closure: UIView.TapGestureRecognizerClosure?) -> UITapGestureRecognizer {
        return UITapGestureRecognizer(target: base, action: #selector(base.handleTap(_:))).with {
            base.tapClosure = closure
            base.isUserInteractionEnabled = true
            base.addGestureRecognizer($0)
        }
    }
    
    @discardableResult
    func onLongPress(_ closure: UIView.LongPressGestureRecognizerClosure?) -> UILongPressGestureRecognizer {
        return UILongPressGestureRecognizer(target: base, action: #selector(base.handleLongPress(_:))).with {
            base.longPressClosure = closure
            base.isUserInteractionEnabled = true
            base.addGestureRecognizer($0)
        }
    }
    
    @discardableResult
    func onPan(_ closure: UIView.PanGestureRecognizerClosure?) -> UIPanGestureRecognizer {
        return UIPanGestureRecognizer(target: base, action: #selector(base.handlePan(_:))).with {
            base.panClosure = closure
            base.isUserInteractionEnabled = true
            base.addGestureRecognizer($0)
        }
    }
    
    @discardableResult
    func onPan(fromEdges edges: UIRectEdge, _ closure: UIView.EdgePanGestureRecognizerClosure?)
        -> UIScreenEdgePanGestureRecognizer {
            return UIScreenEdgePanGestureRecognizer(
                target: base,
                action: #selector(base.handleEdgePan(_:))).with {
                    base.edgePanClosure = closure
                    $0.edges = edges
                    base.isUserInteractionEnabled = true
                    base.addGestureRecognizer($0)
            }
    }
    
    @discardableResult
    func onSwipe(direction: UISwipeGestureRecognizer.Direction = .right,
                 _ closure: UIView.SwipeGestureRecognizerClosure?) -> UISwipeGestureRecognizer {
        return UISwipeGestureRecognizer(
            target: base,
            action: #selector(base.handleSwipe(_:))).with {
                base.swipeClosure = closure
                $0.direction = direction
                base.isUserInteractionEnabled = true
                base.addGestureRecognizer($0)
        }
    }
}

extension Xt where Base: UIView {
    var isScrolling: Bool {
        
        if let scrollView = base as? UIScrollView {
            if (scrollView.isDragging || scrollView.isDecelerating) {
                return true
            }
        }
        
        for subview in base.subviews {
            if subview.xt.isScrolling {
                return true
            }
        }
        return false
    }
}

// MARK: Layout Constraints configuring helpers

extension Xt where Base: UIView {
    
    /// Dimensions & Anchors
    
    var width: NSLayoutDimension {
        return base.widthAnchor
    }
    
    var height: NSLayoutDimension {
        return base.heightAnchor
    }
    
    var top: NSLayoutYAxisAnchor {
        return base.topAnchor
    }
    
    var topMargin: NSLayoutYAxisAnchor {
        return base.layoutMarginsGuide.topAnchor
    }
    
    var bottom: NSLayoutYAxisAnchor {
        return base.bottomAnchor
    }
    
    var bottomMargin: NSLayoutYAxisAnchor {
        return base.layoutMarginsGuide.bottomAnchor
    }
    
    var leading: NSLayoutXAxisAnchor {
        return base.leadingAnchor
    }
    
    var leadingMargin: NSLayoutXAxisAnchor {
        return base.layoutMarginsGuide.leadingAnchor
    }
    
    var trailing: NSLayoutXAxisAnchor {
        return base.trailingAnchor
    }
    
    var trailingMargin: NSLayoutXAxisAnchor {
        return base.layoutMarginsGuide.trailingAnchor
    }
    
    var centerX: NSLayoutXAxisAnchor {
        return base.centerXAnchor
    }
    
    var centerY: NSLayoutYAxisAnchor {
        return base.centerYAnchor
    }
    
    var center: (NSLayoutXAxisAnchor, NSLayoutYAxisAnchor) {
        return (base.centerXAnchor, base.centerYAnchor)
    }
    
    /// Activators & Deactivators
    
    @discardableResult
    func activate(constraint: NSLayoutConstraint) -> NSLayoutConstraint {
        return constraint.xt.activate()
    }
    
    func activate(constraints: [NSLayoutConstraint]) {
        NSLayoutConstraint.xt.activate(constraints)
    }
    
    func activate(constraints: NSLayoutConstraint...) {
        activate(constraints: constraints)
    }
    
    func deactivate(constraints: [NSLayoutConstraint]) {
        NSLayoutConstraint.deactivate(constraints)
    }
    
    func deactivate(constraints: NSLayoutConstraint...) {
        deactivate(constraints: constraints)
    }
    
    @discardableResult
    func applyConstraints(_ closure: (UIView) -> [NSLayoutConstraint]) -> Self {
        activate(constraints: closure(base))
        return self
    }
    
    /// Constraining
    
    enum Condition {
        case equal
        case lessThanOrEqual
        case greaterThanOrEqual
    }
    
    /// Size
    
    func size(_ size: CGSize) {
        width(size.width)
        height(size.height)
    }
    
    func size(w: CGFloat, h: CGFloat) {
        width(w)
        height(h)
    }
    
    func size(equalTo view: UIView, multipliers: CGPoint = CGPoint(x: 1.0, y: 1.0)) {
        width(.equal, to: view, multiplier: multipliers.x)
        height(.equal, to: view, multiplier: multipliers.y)
    }
    
    /// Width
    
    @discardableResult
    func width(_ w: CGFloat) -> NSLayoutConstraint {
        return width.constraint(equalToConstant: w).xt.activate()
    }
    
    @discardableResult
    func width(_ condition: Condition, to constant: CGFloat) -> NSLayoutConstraint {
        switch condition {
        case .equal:
            return width.constraint(equalToConstant: constant).xt.activate()
        case .lessThanOrEqual:
            return width.constraint(lessThanOrEqualToConstant: constant).xt.activate()
        case .greaterThanOrEqual:
            return width.constraint(greaterThanOrEqualToConstant: constant).xt.activate()
        }
    }
    
    @discardableResult
    func width(_ condition: Condition,
               to dimension: NSLayoutDimension,
               multiplier: CGFloat = 1.0,
               constant: CGFloat = 0.0) -> NSLayoutConstraint {
        
        switch condition {
        case .equal:
            return width.constraint(equalTo: dimension,
                                    multiplier: multiplier,
                                    constant: constant).xt.activate()
            
        case .lessThanOrEqual:
            return width.constraint(lessThanOrEqualTo: dimension,
                                    multiplier: multiplier,
                                    constant: constant).xt.activate()
            
        case .greaterThanOrEqual:
            return width.constraint(greaterThanOrEqualTo: dimension,
                                    multiplier: multiplier,
                                    constant: constant).xt.activate()
        }
    }
    
    @discardableResult
    func width(_ condition: Condition,
               to view: UIView,
               multiplier: CGFloat = 1.0,
               constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return width(condition, to: view.xt.width, multiplier: multiplier, constant: constant)
    }
    
    /// Height
    
    @discardableResult
    func height(_ h: CGFloat) -> NSLayoutConstraint {
        return height.constraint(equalToConstant: h).xt.activate()
    }
    
    @discardableResult
    func height(_ condition: Condition, to constant: CGFloat) -> NSLayoutConstraint {
        switch condition {
        case .equal:
            return height.constraint(equalToConstant: constant).xt.activate()
        case .lessThanOrEqual:
            return height.constraint(lessThanOrEqualToConstant: constant).xt.activate()
        case .greaterThanOrEqual:
            return height.constraint(greaterThanOrEqualToConstant: constant).xt.activate()
        }
    }
    
    @discardableResult
    func height(_ condition: Condition,
               to dimension: NSLayoutDimension,
               multiplier: CGFloat = 1.0,
               constant: CGFloat = 0.0) -> NSLayoutConstraint {
        
        switch condition {
        case .equal:
            return height.constraint(equalTo: dimension,
                                    multiplier: multiplier,
                                    constant: constant).xt.activate()
            
        case .lessThanOrEqual:
            return height.constraint(lessThanOrEqualTo: dimension,
                                    multiplier: multiplier,
                                    constant: constant).xt.activate()
            
        case .greaterThanOrEqual:
            return height.constraint(greaterThanOrEqualTo: dimension,
                                    multiplier: multiplier,
                                    constant: constant).xt.activate()
        }
    }
    
    @discardableResult
    func height(_ condition: Condition,
               to view: UIView,
               multiplier: CGFloat = 1.0,
               constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return height(condition, to: view.xt.height, multiplier: multiplier, constant: constant)
    }
    
    
    /// Top
    
    @discardableResult
    func top(_ constant: CGFloat = 0.0, to anchor: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
        return top.constraint(equalTo: anchor, constant: constant).xt.activate()
    }
    
    @discardableResult
    func top(_ constant: CGFloat = 0.0) -> NSLayoutConstraint? {
        guard let superview = base.superview else { return nil }
        return top.constraint(equalTo: superview.xt.top, constant: constant).xt.activate()
    }
    
    @discardableResult
    func top(_ condition: Condition,
             to dimension: NSLayoutYAxisAnchor,
             constant: CGFloat = 0.0) -> NSLayoutConstraint {
        switch condition {
        case .equal:
            return top.constraint(equalTo: dimension,
                                  constant: constant).xt.activate()
            
        case .lessThanOrEqual:
            return top.constraint(lessThanOrEqualTo: dimension,
                                  constant: constant).xt.activate()
            
        case .greaterThanOrEqual:
            return top.constraint(greaterThanOrEqualTo: dimension,
                                  constant: constant).xt.activate()
        }
    }
    
    /// Bottom
    
    @discardableResult
    func bottom(_ constant: CGFloat = 0.0, to anchor: NSLayoutYAxisAnchor) -> NSLayoutConstraint {
        return bottom.constraint(equalTo: anchor, constant: constant).xt.activate()
    }
    
    @discardableResult
    func bottom(_ constant: CGFloat = 0.0) -> NSLayoutConstraint? {
        guard let superview = base.superview else { return nil }
        return bottom.constraint(equalTo: superview.xt.bottom, constant: constant).xt.activate()
    }
    
    @discardableResult
    func bottom(_ condition: Condition,
                to dimension: NSLayoutYAxisAnchor,
                constant: CGFloat = 0.0) -> NSLayoutConstraint {
        switch condition {
        case .equal:
            return bottom.constraint(equalTo: dimension,
                                     constant: constant).xt.activate()
            
        case .lessThanOrEqual:
            return bottom.constraint(lessThanOrEqualTo: dimension,
                                     constant: constant).xt.activate()
            
        case .greaterThanOrEqual:
            return bottom.constraint(greaterThanOrEqualTo: dimension,
                                     constant: constant).xt.activate()
        }
    }
    
    /// Leading
    
    @discardableResult
    func leading(_ constant: CGFloat = 0.0, to anchor: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
        return leading.constraint(equalTo: anchor, constant: constant).xt.activate()
    }
    
    @discardableResult
    func leading(_ constant: CGFloat = 0.0) -> NSLayoutConstraint? {
        guard let superview = base.superview else { return nil }
        return leading.constraint(equalTo: superview.xt.leading, constant: constant).xt.activate()
    }
    
    @discardableResult
    func leading(_ condition: Condition,
                to dimension: NSLayoutXAxisAnchor,
                constant: CGFloat = 0.0) -> NSLayoutConstraint {
        switch condition {
        case .equal:
            return leading.constraint(equalTo: dimension,
                                      constant: constant).xt.activate()
           
        case .lessThanOrEqual:
            return leading.constraint(lessThanOrEqualTo: dimension,
                                      constant: constant).xt.activate()
           
        case .greaterThanOrEqual:
            return leading.constraint(greaterThanOrEqualTo: dimension,
                                      constant: constant).xt.activate()
        }
   }
    
    
    /// Trailing
    
    @discardableResult
    func trailing(_ constant: CGFloat = 0.0, to anchor: NSLayoutXAxisAnchor) -> NSLayoutConstraint {
        return trailing.constraint(equalTo: anchor, constant: constant).xt.activate()
    }
    
    @discardableResult
    func trailing(_ constant: CGFloat = 0.0) -> NSLayoutConstraint? {
        guard let superview = base.superview else { return nil }
        return trailing.constraint(equalTo: superview.xt.trailing, constant: constant).xt.activate()
    }
    
    @discardableResult
    func trailing(_ condition: Condition,
                  to dimension: NSLayoutXAxisAnchor,
                  constant: CGFloat = 0.0) -> NSLayoutConstraint {
        switch condition {
        case .equal:
            return trailing.constraint(equalTo: dimension,
                                       constant: constant).xt.activate()
            
        case .lessThanOrEqual:
            return trailing.constraint(lessThanOrEqualTo: dimension,
                                       constant: constant).xt.activate()
            
        case .greaterThanOrEqual:
            return trailing.constraint(greaterThanOrEqualTo: dimension,
                                       constant: constant).xt.activate()
        }
    }
    
    /// Center
    
    @discardableResult
    func centerX(equalTo view: UIView, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return base.centerXAnchor.constraint(equalTo: view.centerXAnchor,
                                             constant: constant).xt.activate()
    }
    
    @discardableResult
    func centerY(equalTo view: UIView, constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return base.centerYAnchor.constraint(equalTo: view.centerYAnchor,
                                             constant: constant).xt.activate()
        
    }
    
    @discardableResult
    func centerX(equalTo anchor: NSLayoutXAxisAnchor,
                 constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return base.centerXAnchor.constraint(equalTo: anchor,
                                             constant: constant).xt.activate()
        
    }
    
    @discardableResult
    func centerY(equalTo anchor: NSLayoutYAxisAnchor,
                 constant: CGFloat = 0.0) -> NSLayoutConstraint {
        return base.centerYAnchor.constraint(equalTo: anchor,
                                             constant: constant).xt.activate()
        
    }
    
    func center(equalTo view: UIView, offset: CGPoint = CGPoint(x: 0.0, y: 0.0)) {
        centerX(equalTo: view, constant: offset.x)
        centerY(equalTo: view, constant: offset.y)
    }
    
    
    /// Edges
    
    /// Attaches given edges of the view to given another view
    /// If parameter view equals nil than the superview is used as another view
    func pinEdges(_ edges: UIRectEdge = .all,
                  to view: UIView? = nil,
                  insets: UIEdgeInsets = .zero) {
        
        guard let anotherView = view ?? base.superview else { return }
        
        var constraints: [NSLayoutConstraint] = []
        
        if edges.contains(.top) {
            constraints.append(base.topAnchor.constraint(
                equalTo: anotherView.topAnchor,
                constant: insets.top
            ))
        }
        if edges.contains(.bottom) {
            constraints.append(base.bottomAnchor.constraint(
                equalTo: anotherView.bottomAnchor,
                constant: -insets.bottom
            ))
        }
        if edges.contains(.left) {
            constraints.append(base.leftAnchor.constraint(
                equalTo: anotherView.leftAnchor,
                constant: insets.left
            ))
        }
        if edges.contains(.right) {
            constraints.append(base.rightAnchor.constraint(
                equalTo: anotherView.rightAnchor,
                constant: -insets.right
            ))
        }
        
        activate(constraints: constraints)
    }
    
    func edges(_ edges: UIRectEdge = .all,
               to view: UIView? = nil,
               insets: UIEdgeInsets = .zero) {
        pinEdges(edges, to: view, insets: insets)
    }
    
    
    func pinToMargins(_ margins: UIRectEdge = .all) {
        
        guard let anotherView = base.superview else { return }
        
        var constraints: [NSLayoutConstraint] = []
        
        if margins.contains(.top) {
            constraints.append(base.topAnchor.constraint(
                equalTo: anotherView.layoutMarginsGuide.topAnchor
            ))
        }
        if margins.contains(.bottom) {
            constraints.append(base.bottomAnchor.constraint(
                equalTo: anotherView.layoutMarginsGuide.bottomAnchor
            ))
        }
        if margins.contains(.left) {
            constraints.append(base.leadingAnchor.constraint(
                equalTo: anotherView.layoutMarginsGuide.leadingAnchor
            ))
        }
        if margins.contains(.right) {
            constraints.append(base.trailingAnchor.constraint(
                equalTo: anotherView.layoutMarginsGuide.trailingAnchor
            ))
        }
        
        activate(constraints: constraints)
    }
    
    /// Complex Layouting
    
    @discardableResult
    func layout(in superview: UIView? = nil, closure: (Xt<Base>) -> Void) -> Self {
        (superview ?? base.superview)?.addSubview(base)
        closure(self)
        return self
    }
    
    @discardableResult
    func layout(in superview: UIView? = nil,
                closure: (_ base: Xt<Base>, _ superview: UIView) -> Void) -> Self {
        guard let sv = (superview ?? base.superview) else {
            return self
        }
        sv.addSubview(base)
        closure(self, sv)
        return self
    }
    
    @discardableResult
    func layout(_ closure: (_ base: Xt<Base>, _ superview: UIView) -> Void) -> Self {
        return layout(in: base.superview, closure: closure)
    }
    
//    @discardableResult
//    func layout(_ subview: UIView, closure: (_ child: Xt<UIView>) -> Void) -> Self {
//        base.addSubview(subview)
//        closure(subview.xt)
//        return self
//    }
}
