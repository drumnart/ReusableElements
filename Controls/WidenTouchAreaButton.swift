//
//  WidenTouchAreaButton.swift
//
//  Created by Sergey Gorin on 07/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class WidenTouchAreaButton: UIButton, TouchAreaExtendable {
    
    @IBInspectable var touchMargin: CGFloat = 22.0
    
    // Extend touchable area
    override func point(inside point: CGPoint, with event: UIEvent?) -> Bool {
        return touch(point: point,
                     withMargins: CGPoint(x: touchMargin, y: touchMargin))
    }
}
