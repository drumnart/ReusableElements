//
//  RelaxDecorationReusableView.swift
//
//  Created by Sergey Gorin on 08/12/2018.
//  Copyright © 2018 Sergey Gorin. All rights reserved.
//

import UIKit

class RelaxDecorationReusableView: UICollectionReusableView {
    
    override func apply(_ layoutAttributes: UICollectionViewLayoutAttributes) {
        super.apply(layoutAttributes)
        let attributes = layoutAttributes as? RelaxLayoutAttributes
        backgroundColor = attributes?.color
    }
}
