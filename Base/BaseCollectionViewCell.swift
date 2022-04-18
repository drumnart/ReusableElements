//
//  BaseCollectionViewCell.swift
//
//  Created by Sergey Gorin on 23/03/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class BaseCollectionViewCell: UICollectionViewCell {
    
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
        
        if #available(iOS 11.0, *) {
            insetsLayoutMarginsFromSafeArea = false
        }
    }
}
