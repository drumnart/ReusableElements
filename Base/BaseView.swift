//
//  BaseView.swift
//
//  Created by Sergey Gorin on 23/03/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class BaseView: UIView {

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }

    override class var requiresConstraintBasedLayout: Bool {
      return true
    }
    
    func prepare() {
        /// Should be overriden in subview
    }
}
