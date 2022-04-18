//
//  Geometry+Extensions.swift
//
//  Created by Sergey Gorin on 04/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import CoreGraphics
import UIKit.UIGeometry

extension CGFloat {
    
    var half: CGFloat { self * 0.5 }
    var fourth: CGFloat { self * 0.25 }
    var third: CGFloat { self / 3 }
}

extension CGSize {
    
    /// Exchange width and height
    var swapped: CGSize {
        return CGSize(width: height, height: width)
    }
    
    var isLandscape: Bool {
        return width > height
    }
    
    static func + (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width + rhs.width,
                      height: lhs.height + rhs.height)
    }
    
    static func - (lhs: CGSize, rhs: CGSize) -> CGSize {
        return CGSize(width: lhs.width - rhs.width,
                      height: lhs.height - rhs.height)
    }
}

extension CGPoint {
    
    static func + (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x + rhs.x,
                       y: lhs.y + rhs.y)
    }
    
    static func - (lhs: CGPoint, rhs: CGPoint) -> CGPoint {
        return CGPoint(x: lhs.x - rhs.x,
                       y: lhs.y - rhs.y)
    }
}

extension CGRect {
    
    var center: CGPoint {
        return CGPoint(x: midX, y: midY)
    }
}

extension UIEdgeInsets {
    
    var leftRight: CGFloat {
        return left + right
    }
    
    var topBottom: CGFloat {
        return top + bottom
    }
    
    static func apply(top: CGFloat = 0.0,
                      left: CGFloat = 0.0,
                      bottom: CGFloat = 0.0,
                      right: CGFloat = 0.0) -> UIEdgeInsets {
        return .init(top: top, left: left, bottom: bottom, right: right)
    }
    
    static func all(_ inset: CGFloat = 0.0) -> UIEdgeInsets {
        return .init(top: inset, left: inset, bottom: inset, right: inset)
    }
}

extension NSDirectionalEdgeInsets {
    
    var leftRight: CGFloat {
        return leading + trailing
    }
    
    var topBottom: CGFloat {
        return top + bottom
    }
    
    static func apply(top: CGFloat = 0.0,
                      leading: CGFloat = 0.0,
                      bottom: CGFloat = 0.0,
                      trailing: CGFloat = 0.0) -> NSDirectionalEdgeInsets {
        return .init(top: top, leading: leading, bottom: bottom, trailing: trailing)
    }
    
    static func all(_ inset: CGFloat = 0.0) -> NSDirectionalEdgeInsets {
        return .init(top: inset, leading: inset, bottom: inset, trailing: inset)
    }
}

extension Double {
    
    var degrees: Double {
        return self * .pi / 180.0
    }
    
    var radians: Double {
        return self * 180.0 / .pi
    }
}

extension String {
    
    /// Size of rect for string
    func sizeOfTextWithBoundingSize(
        _ boundingSize: CGSize,
        withOptions options: NSStringDrawingOptions,
        withAttributes attributes:[NSAttributedString.Key : Any]) -> CGSize {
        
        return self.boundingRect(
            with: boundingSize,
            options: options,
            attributes: attributes,
            context: nil).size
    }
    
    func height(forWidth width: CGFloat,
                maxHeight: CGFloat = .greatestFiniteMagnitude,
                options: NSStringDrawingOptions = [.usesLineFragmentOrigin],
                font: UIFont) -> CGFloat {
        
        let boundingSize = sizeOfTextWithBoundingSize(
            CGSize(width: width, height: maxHeight),
            withOptions: options,
            withAttributes: [.font: font]
        )
        
        return ceil(boundingSize.height)
    }
    
    func width(forHeight height: CGFloat,
               maxWidth: CGFloat = .greatestFiniteMagnitude,
               options: NSStringDrawingOptions = [.usesLineFragmentOrigin],
               font: UIFont) -> CGFloat {
        
        let boundingSize = sizeOfTextWithBoundingSize(
            CGSize(width: maxWidth, height: height),
            withOptions: options,
            withAttributes: [.font: font]
        )
        
        return ceil(boundingSize.width)
    }
}
