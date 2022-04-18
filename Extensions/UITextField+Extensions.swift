//
//  UITextField+Extensions.swift
//
//  Created by Sergey Gorin on 24.12.2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit.UITextField

extension UITextField {
    
    func fixCaretPosition() {
        let beginning = beginningOfDocument
        selectedTextRange = textRange(from: beginning, to: beginning)
        let end = endOfDocument
        selectedTextRange = textRange(from: end, to: end)
    }
}
