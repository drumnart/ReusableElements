//
//  TagsBarCell.swift
//
//  Created by Sergey Gorin on 30.10.2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

protocol TagsBarCellDelegate: class {
    
    func handleTagBarItemDelete(for cell: TagsBarCell)
}

class TagsBarCell: UICollectionViewCell {
    
    weak var delegate: TagsBarCellDelegate?
    
    var title: String = "" {
        didSet {
            titleLabel.text = title
        }
    }
    
    lazy var titleLabel = UILabel().with {
        $0.numberOfLines = 1
        $0.font = .regular(15)
        $0.textAlignment = .left
    }
    
    lazy var deleteBtn = WidenTouchAreaButton(type: .custom).with {
        $0.setImage(Asset.Baseline.closeSmall.image, for: .normal)
        $0.onAction { [unowned self] _ in
            self.delegate?.handleTagBarItemDelete(for: self)
        }
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    func configure() {
        
        backgroundColor = .tbxBackground
        
        if #available(iOS 11.0, *) {
            insetsLayoutMarginsFromSafeArea = false
        }
        
        contentView.xt.addSubviews(titleLabel, deleteBtn)
        
        titleLabel.xt.layout {
            $0.pinEdges([.top,. bottom])
            $0.leading(13)
        }
        
        deleteBtn.xt.layout {
            $0.centerY(equalTo: $1)
            $0.leading(13, to: titleLabel.xt.trailing)
            $0.trailing(-13)
            $0.size(w: 10, h: 10)
        }
        
        xt.round(borderWidth: 1,
                 borderColor: .tbxMainAccent,
                 cornerRadius: bounds.height.half)
        xt.rasterize()
    }
    
    override func preferredLayoutAttributesFitting(
        _ layoutAttributes: UICollectionViewLayoutAttributes) -> UICollectionViewLayoutAttributes {
        
        return layoutAttributes.with {
            $0.bounds.size.width = xt.layoutFittingCompressedSize.width
        }
    }
}
