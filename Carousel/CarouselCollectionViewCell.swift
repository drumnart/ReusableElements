//
//  CarouselCollectionViewCell.swift
//
//  Created by Sergey Gorin on 26/03/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class CarouselCollectionViewCell: UICollectionViewCell {
    
    var imageView: UIImageView!
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        configure()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        configure()
    }
    
    override func prepareForReuse() {
        super.prepareForReuse()
        imageView?.cancelDownloading()
        imageView?.image = nil
    }
    
    func configure() {
        configureViews()
        configureConstraints()
    }
    
    func configureViews() {
        
        if #available(iOS 11.0, *) {
            insetsLayoutMarginsFromSafeArea = false
        }
        
        imageView = UIImageView().with {
            $0.contentMode = .scaleAspectFit
            $0.clipsToBounds = true
        }
        contentView.addSubview(imageView)
        
        xt.rasterize()
    }
    
    func configureConstraints() {
        imageView?.xt.pinEdges()
    }
}
