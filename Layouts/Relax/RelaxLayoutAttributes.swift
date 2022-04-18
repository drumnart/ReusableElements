//
//  RelaxLayoutAttributes.swift
//
//  Created by Sergey Gorin on 08/12/2018.
//  Copyright © 2018 Sergey Gorin. All rights reserved.
//

import UIKit

class RelaxLayoutAttributes: UICollectionViewLayoutAttributes {
    var parallax: CGAffineTransform = .identity
    var overlayAlpha: CGFloat = 0.0
    var color: UIColor?
    var effect: UIVisualEffect?
    
    override func copy(with zone: NSZone? = nil) -> Any {
        return (super.copy(with: zone) as? RelaxLayoutAttributes)?.with {
            $0.parallax = parallax
            $0.overlayAlpha = overlayAlpha
            $0.color = color
            $0.effect = effect
            } ?? super.copy(with: zone)
    }
    
    override func isEqual(_ object: Any?) -> Bool {
        guard let other = object as? RelaxLayoutAttributes else {
            return false
        }
        
        if NSValue(cgAffineTransform: other.parallax)
            != NSValue(cgAffineTransform: parallax)
            || other.overlayAlpha != overlayAlpha
            || other.color != color
            || other.effect != effect {
            return false
        }
        
        return super.isEqual(object)
    }
}
