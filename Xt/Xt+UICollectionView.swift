//
//  UICollectionView+Extensions.swift
//
//  Created by Sergey Gorin on 04/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit.UICollectionView

extension Xt where Base: UICollectionView {
    
    var unexpectedCell: UICollectionViewCell {
        return UICollectionViewCell().with { _ in
            assert(false, "Unexpected cell type")
        }
    }
    
    func reload(animated: Bool = true, invalidatingLayout: Bool = false) {
        if animated {
            base.reloadData()
        } else {
            UIView.performWithoutAnimation {
                base.reloadData()
            }
        }
        if invalidatingLayout {
            base.collectionViewLayout.invalidateLayout()
        }
    }
    
    func reloadItems(at indexPaths: [IndexPath], animated: Bool) {
        if animated {
            base.reloadItems(at: indexPaths)
        } else {
            UIView.performWithoutAnimation {
                base.reloadItems(at: indexPaths)
            }
        }
    }
}

extension Xt where Base: UICollectionViewCell {
    
    static var unexpected: UICollectionViewCell {
        return UICollectionViewCell().with { _ in
            assert(false, "Unexpected cell type")
        }
    }
}
