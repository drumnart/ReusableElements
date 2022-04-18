//
//  BadgeView.swift
//
//  Created by Sergey Gorin on 09/05/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class BadgeView: BaseView {
    
    var badgeText: String = "" {
        didSet {
            isHidden = badgeText.isBlank
            badgeLabel.text = badgeText
        }
    }
    
    lazy var badgeLabel = UILabel().with {
        $0.font = .medium(11.dp)
        $0.textColor = .white
        $0.textAlignment = .center
    }
    
    override func prepare() {
        
        backgroundColor = .black
        
        addSubview(badgeLabel)
        
        badgeLabel.xt.layout {
            $0.top(2)
            $0.bottom(-2)
            $0.leading(2)
            $0.trailing(-2)
            $0.centerX(equalTo: $1)
        }
        
        isHidden = true
    }
    
    override func layoutSubviews() {
        layer.cornerRadius = frame.height * 0.5
        layer.masksToBounds = true
    }
}
