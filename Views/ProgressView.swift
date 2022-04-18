//
//  ProgressView.swift
//
//  Created by Sergey Gorin on 18/08/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class ProgressView: UIProgressView {
    
    private var _frame: CGRect = .zero {
        didSet {
            super.frame = _frame
        }
    }
    
    override var frame: CGRect {
        get { return _frame }
        set { _frame = newValue }
    }
    
    override func sizeThatFits(_ size: CGSize) -> CGSize {
        return _frame.size
    }
}
