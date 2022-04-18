//
//  BaseCollectionView.swift
//
//  Created by Sergey Gorin on 31/07/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class BaseCollectionView: UICollectionView {

    private var reloadDataCompletionBlock: (() -> Void)?
    
    override func layoutSubviews() {
        super.layoutSubviews()
        
        reloadDataCompletionBlock?()
        reloadDataCompletionBlock = nil
    }
    
    
    func reloadData(completion: @escaping () -> Void) {
        reloadDataCompletionBlock = completion
        self.reloadData()
    }
}
