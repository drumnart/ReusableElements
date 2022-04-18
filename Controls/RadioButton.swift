//
//  RadioButton.swift
//
//  Created by Sergey Gorin on 15/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class RadioButton: WidenTouchAreaButton {
    
    var innerShapeStrokeColor: UIColor = .black {
        didSet {
            updateFillState()
        }
    }
    
    var outerShapeStrokeColor: UIColor = .black {
        didSet {
            updateFillState()
        }
    }
    
    var outerShapeStrokeInactiveColor: UIColor = .black {
        didSet {
            updateFillState()
        }
    }
    
    var outerShapeLineWidth: CGFloat = 1.0 {
        didSet {
            updateLayout()
        }
    }
    
    var interShapeSpacing: CGFloat = 3.0 {
        didSet {
            updateLayout()
        }
    }
    
    /// Corner radius for shapes. If not set circle shape is used. Default value is nil.
    var shapeCornerRadius: CGFloat?
    
    /// Custom UIBezierPath for outer shape. By default circle shape is used
    var outerShapePath: UIBezierPath? {
        didSet {
            updateLayout()
        }
    }
    
    /// Custom UIBezierPath for inner shape. By default circle shape is used
    var innerShapePath: UIBezierPath? {
        didSet {
            updateLayout()
        }
    }
    
    private var innerShapeLayer = CAShapeLayer() // Indicator
    private var outerShapeLayer = CAShapeLayer() // Icon
    
    private var selectionChanged: Bool = false
    
    override var isSelected: Bool {
        didSet {
            updateFillState()
            selectionChanged = false
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    override func layoutSubviews() {
        super.layoutSubviews()
        updateLayout()
    }
}

// MARK: - Private part

extension RadioButton {
    
    fileprivate func setup() {
        
        let clear = UIImage.fromColor(.clear)
        setImage(clear, for: [])
        setBackgroundImage(clear, for: [])
        
        addTarget(self, action: #selector(didTouchUpInside(_:)), for: .touchUpInside)
        
        outerShapeLayer.frame = bounds
        outerShapeLayer.lineWidth = outerShapeLineWidth
        outerShapeLayer.fillColor = UIColor.clear.cgColor
        outerShapeLayer.strokeColor = outerShapeStrokeInactiveColor.cgColor
        layer.addSublayer(outerShapeLayer)
        
        innerShapeLayer.frame = bounds
        innerShapeLayer.lineWidth = outerShapeLineWidth
        innerShapeLayer.fillColor = UIColor.clear.cgColor
        innerShapeLayer.strokeColor = UIColor.clear.cgColor
        layer.addSublayer(innerShapeLayer)
        
        updateFillState()
        updateLayout()
    }
    
    @objc private func didTouchUpInside(_ events: UIControl.Event) {
        if !selectionChanged {
            isSelected = !isSelected
            selectionChanged = true
        }
    }
    
    fileprivate func updateFillState() {
        innerShapeLayer.fillColor = isSelected ? innerShapeStrokeColor.cgColor : UIColor.clear.cgColor
        outerShapeLayer.strokeColor = isSelected ? outerShapeStrokeColor.cgColor : outerShapeStrokeInactiveColor.cgColor
    }
    
    fileprivate func updateLayout() {
        outerShapeLayer.frame = bounds
        outerShapeLayer.lineWidth = outerShapeLineWidth
        outerShapeLayer.path = outerShapePath?.cgPath ?? defaultPaths.outer.cgPath
        
        innerShapeLayer.frame = bounds
        innerShapeLayer.lineWidth = outerShapeLineWidth
        innerShapeLayer.path = innerShapePath?.cgPath ?? defaultPaths.inner.cgPath
    }
    
    private var defaultPaths: (inner: UIBezierPath, outer: UIBezierPath) {
        let width = bounds.width
        let height = bounds.height
        let outerDiameter: CGFloat = max(width, height) - outerShapeLineWidth
        let origin: CGPoint
        
        if width < height {
            origin = CGPoint(x: (width - outerDiameter) / 2, y: outerShapeLineWidth / 2)
        } else {
            origin = CGPoint(x: outerShapeLineWidth / 2, y: (height - outerDiameter) / 2)
        }
        
        let inset = self.interShapeSpacing + outerShapeLineWidth / 2
        let outerRect = CGRect(origin: origin, size: CGSize(width: outerDiameter, height: outerDiameter))
        let innerRect = outerDiameter - inset > 0 ? outerRect.insetBy(dx: inset, dy: inset) : .zero
        
        return (UIBezierPath(roundedRect: innerRect,
                             cornerRadius: shapeCornerRadius ?? outerDiameter / 2),
                UIBezierPath(roundedRect: outerRect,
                             cornerRadius: shapeCornerRadius ?? outerDiameter / 2))
    }
}

