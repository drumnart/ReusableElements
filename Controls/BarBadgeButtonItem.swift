//
//  BarBadgeButtonItem.swift
//
//  Created by Sergey Gorin on 25.03.2020.
//  Copyright © 2020 Sergey Gorin. All rights reserved.
//

import UIKit

class BarBadgeButtonItem: UIBarButtonItem {

    lazy var badgeView = BadgeView().with {
        $0.isUserInteractionEnabled = false
        $0.backgroundColor = .tbxAttention
        $0.badgeLabel.textColor = .tbxTextLight
    }
    
    lazy var button = CustomButton().with {
        $0.touchMargin = 41
        $0.tintColor = .tbxMainTint
        $0.frame = CGRect(origin: .zero, size: CGSize(width: 36, height: 36))
        $0.xt.size($0.frame.size)
    }
    
    override init() {
        super.init()
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }
    
    func prepare() {
        
        customView = UIView().with {
            $0.xt.addSubviews(button, badgeView)
            $0.xt.size(CGSize(width: 36, height: 36))
        }
        
        button.xt.layout {
            $0.pinEdges([.left, .top])
        }
        
        badgeView.xt.layout {
            $0.top(3)
            $0.trailing(0)
            $0.height(15)
            $0.width(.greaterThanOrEqual, to: 15)
        }
    }
}
