//
//  BaseCollectionReusableView.swift
//
//  Created by Sergey Gorin on 28/03/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class BaseCollectionReusableView: UICollectionReusableView {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    func prepare() {
        /// Should be overriden in subview
        
        insetsLayoutMarginsFromSafeArea = false   
    }
}
