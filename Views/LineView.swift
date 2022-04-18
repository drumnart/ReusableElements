//
//  LineView.swift
//
//  Created by Sergey Gorin on 15/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class LineView: UIView {
    
    enum Axis {
        case horizontal, vertical
    }
    
    var axis: Axis = .horizontal
    var isDashed: Bool = false
    var dashLength: CGFloat = 1.0
    
    var lineColor: UIColor = .black
    var lineThickness: CGFloat = 0.5
    
    init(axis: Axis = .horizontal,
         dashed: Bool = false,
         dashLength: CGFloat = 1,
         lineColor: UIColor = .black,
         lineThickness: CGFloat = 0.5) {
        
        super.init(frame: .zero)
        commonInit()
        self.axis = axis
        self.isDashed = dashed
        self.dashLength = dashLength
        self.lineColor = lineColor
        self.lineThickness = lineThickness
    }
    
    override public init(frame: CGRect) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    func update() {
        setNeedsDisplay()
    }
    
    private func commonInit() {
        backgroundColor = .clear
        clearsContextBeforeDrawing = false
    }
    
    override func layoutSubviews() {
        setNeedsDisplay()
    }
    
    override func draw(_ rect: CGRect) {
        let path = UIBezierPath()
        path.lineWidth = lineThickness
        
        switch axis {
        case .horizontal:
            
            let endX = rect.size.width
                - (rect.size.width.truncatingRemainder(dividingBy: lineThickness * 2))
                + lineThickness
            let startX = (rect.size.width - endX).half + lineThickness
            let centerY = rect.height.half
            
            path.move(to: CGPoint(x: startX, y: centerY))
            path.addLine(to: CGPoint(x: endX, y: centerY))
            
        case .vertical:
            
            let endY = rect.size.height
                - (rect.size.height.truncatingRemainder(dividingBy: lineThickness * 2))
                + lineThickness
            let startY = (rect.size.height - endY).half + lineThickness
            let centerX = rect.width.half
            
            path.move(to: CGPoint(x: centerX, y: startY))
            path.addLine(to: CGPoint(x: centerX, y: endY))
        }
        
        if isDashed {
            let dashes: [CGFloat] = [dashLength, dashLength]
            path.setLineDash(dashes, count: dashes.count, phase: 0)
            path.lineCapStyle = .butt
        }
        
        lineColor.setStroke()
        
        path.stroke()
    }
}
