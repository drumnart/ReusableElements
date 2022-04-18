//
//  PageControl.swift
//
//  Created by Sergey Gorin on 25/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class PageControl: UIPageControl {
    
    override init(frame: CGRect = .zero) {
        super.init(frame: frame)
        commonInit()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        commonInit()
    }
    
    fileprivate func commonInit() {
        isUserInteractionEnabled = false
        currentPage = 0
        pageIndicatorTintColor = .tbxPageIndicator
        currentPageIndicatorTintColor = .tbxWhite
        hidesForSinglePage = true
    }
}
