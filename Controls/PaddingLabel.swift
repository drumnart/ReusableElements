//
//  PaddingLabel.swift
//
//  Created by Sergey Gorin on 23/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class PaddingLabel: UILabel {

    var padding = UIEdgeInsets(top: 4, left: 4, bottom: 4, right: 4)
    
    override func drawText(in rect: CGRect) {
        let insets = UIEdgeInsets(
            top: padding.top,
            left: padding.left,
            bottom: padding.bottom,
            right: padding.right
        )
        super.drawText(in: rect.inset(by: insets))
    }
    
    override var intrinsicContentSize: CGSize {
        
        var intrinsicContentSize = super.intrinsicContentSize
        
        let textWidth = frame.size.width - (padding.left + padding.right)
        let size = NSString(string: text ?? "").boundingRect(
            with: CGSize(width: textWidth, height: .greatestFiniteMagnitude),
            options: .usesLineFragmentOrigin,
            attributes: [.font: font ?? UIFont()],
            context: nil
            ).size
        
        intrinsicContentSize.height = ceil(size.height) + padding.top + padding.bottom
        intrinsicContentSize.width += padding.left + padding.right
        
        return intrinsicContentSize
    }
}
