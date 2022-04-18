//
//  QuickNotificationView.swift
//
//  Created by Sergey Gorin on 29/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

enum QuickNotificationEdge {
    case top
    case bottom
    
    var appearanceDirection: QuickNotificationAppearanceDirection {
        switch self {
        case .top: return .down
        case .bottom: return .up
        }
    }
}

enum QuickNotificationAppearanceDirection {
    case up
    case down
    
    var opposite: QuickNotificationAppearanceDirection {
        switch self {
        case .up: return .down
        case .down: return .up
        }
    }
}

class QuickNotificationView: UIView {
    
    fileprivate(set) lazy var label: UILabel = UILabel().with {
        $0.translatesAutoresizingMaskIntoConstraints = false
        $0.preferredMaxLayoutWidth = bounds.width
            - labelMargins.left
            - labelMargins.right
        $0.numberOfLines = self.maxNumberOfLines
        $0.text = self.text
        $0.textColor = self.textColor
        $0.font = self.font
        $0.textAlignment = self.textAlignment
        $0.isUserInteractionEnabled = false
    }
    
    fileprivate weak var parentView: UIView?
    fileprivate var appearanceDirection = QuickNotificationAppearanceDirection.down
    fileprivate var heightConstraint: NSLayoutConstraint!
    
    var minimumHeight: CGFloat = 44.0
    
    var maxNumberOfLines = 3 {
        didSet {
            label.numberOfLines = maxNumberOfLines
        }
    }
    
    var text: String = "" {
        didSet {
            label.text = text
            label.sizeToFit()
        }
    }
    
    var textColor: UIColor = .white {
        didSet {
            label.textColor = textColor
        }
    }
    
    var font: UIFont = .systemFont(ofSize: UIFont.systemFontSize) {
        didSet {
            label.font = font
        }
    }
    
    /// Text alignment in notification label
    var textAlignment: NSTextAlignment = .left {
        didSet {
            label.textAlignment = textAlignment
        }
    }
    
    /// Label margins from outer notification view
    var labelMargins = UIEdgeInsets(top: 4.0, left: 16.0, bottom: 4.0, right: 16.0)
    
    /// Z position index
    var zPosition: CGFloat = 0.0
    
    /// Notification view insets
    var insets: UIEdgeInsets = .zero
    
    /// Seconds to wait before hidding. 0 - disable auto hiding
    var hideDelay: TimeInterval = 5.0
    
    fileprivate(set) var isVisible = false
    
    static let sharedInstance = QuickNotificationView()
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    convenience init(inParentView parentView: UIView? = nil,
                     withMinimumHeight minimumHeight: CGFloat = 44.0,
                     withInsets insets: UIEdgeInsets = .zero,
                     withHideDelay hideDelay: Double = 5.0,
                     withText text: String,
                     withTextColor textColor: UIColor = .white,
                     withFont font: UIFont = .systemFont(ofSize: UIFont.systemFontSize),
                     withTextALignment textAlignment: NSTextAlignment = .center,
                     withBackgroundColor bgColor: UIColor = .darkGray) {
        
        self.init(frame: .zero)
        self.parentView = parentView
        self.minimumHeight = minimumHeight
        self.insets = insets
        self.hideDelay = hideDelay
        self.text = text
        self.textColor = textColor
        self.font = font
        self.textAlignment = textAlignment
        self.backgroundColor = bgColor
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    fileprivate func setup() {
        addSubview(label)
        
        translatesAutoresizingMaskIntoConstraints = false
        label.xt.pinEdges(insets: labelMargins)
        heightConstraint = label.heightAnchor.constraint(equalToConstant: 0)
        heightConstraint.isActive = true
    }
    
    fileprivate var height: CGFloat {
        let hMargins = labelMargins.left + labelMargins.right
        let vMargins = labelMargins.top + labelMargins.bottom
        
        let textSize = label.sizeThatFits(CGSize(width: bounds.width - hMargins,
                                                 height: .greatestFiniteMagnitude))
        return max((textSize.height + vMargins), minimumHeight)
    }
    
    func show(withText text: String? = nil,
              presentingFrom edge: QuickNotificationEdge = .top,
              withDuration duration: Double = 0.4,
              atZ zPosition: CGFloat = 0.0) {
        
        if isVisible { return }
        
        guard let presenter = parentView ?? UIApplication.shared.keyWindow else { return }
        
        presenter.addSubview(self)
        presenter.bringSubviewToFront(self)
        layer.zPosition = zPosition
        alpha = 0
        
        appearanceDirection = edge.appearanceDirection
        
        if let text = text {
            self.text = text
        }
        
        switch appearanceDirection {
        case .up: xt.pinEdges([.bottom, .left, .right], insets: insets)
        case .down: xt.pinEdges([.top, .left, .right], insets: insets)
        }
        presenter.layoutIfNeeded()
        
        heightConstraint.constant = height
        let hideDelay = self.hideDelay
        setNeedsLayout()
        UIView.animate(withDuration: duration,
                       delay: 0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 0.5,
                       options: [],
                       animations: {
                        self.alpha = 1
                        presenter.layoutIfNeeded()
        }) { _ in
            self.isVisible = true
            if hideDelay > 0 {
                self.dismiss(withDelay: hideDelay, withDuration: duration)
            }
        }
    }
    
    func dismiss(withDelay delay: TimeInterval = 0.0, withDuration duration: Double = 0.0) {
        DispatchQueue.delay(delay) {
            self._dismiss(withDuration: duration)
        }
    }
    
    fileprivate func _dismiss(withDuration duration: TimeInterval = 0.0) {
        
        heightConstraint.constant = 0
        
        setNeedsLayout()
        UIView.animate(withDuration: duration,
                       delay: 0.0,
                       usingSpringWithDamping: 0.7,
                       initialSpringVelocity: 1.0,
                       options: .curveEaseOut,
                       animations: {
                        self.alpha = 0
                        self.superview?.layoutIfNeeded()
        }) { _ in
            self.remove()
        }
    }
    
    fileprivate func remove() {
        removeFromSuperview()
        isVisible = false
    }
}

// MARK: Shared Instance

extension QuickNotificationView {
    
    @discardableResult
    static func show(at edge: QuickNotificationEdge = .top,
                     in parentView: UIView? = nil,
                     atZPosition z: CGFloat = 0.0,
                     withMinimumHeight minimumHeight: CGFloat = 44.0,
                     withInsets insets: UIEdgeInsets = .apply(top: 14, left: 0, bottom: 14, right: 0),
                     withHideDelay hideDelay: Double = 5.0,
                     withText text: String,
                     withTextColor textColor: UIColor = .white,
                     withFont font: UIFont = .systemFont(ofSize: UIFont.systemFontSize),
                     withTextALignment textAlignment: NSTextAlignment = .center,
                     withBackgroundColor bgColor: UIColor = .darkGray,
                     withDuration duration: Double = 0.4) -> QuickNotificationView {
        return QuickNotificationView.sharedInstance.with {
            $0.parentView = parentView
            $0.minimumHeight = minimumHeight
            $0.insets = insets
            $0.hideDelay = hideDelay
            $0.text = text
            $0.textColor = textColor
            $0.font = font
            $0.textAlignment = textAlignment
            $0.backgroundColor = bgColor
            $0.show(presentingFrom: edge, withDuration: duration, atZ: z)
        }
    }
    
    static func dismiss(withDelay delay: Double = 0.0, withDuration duration: Double = 0.0) {
        QuickNotificationView.sharedInstance.dismiss(withDelay: delay, withDuration: duration)
    }
}
