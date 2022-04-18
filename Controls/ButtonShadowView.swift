//
//  ButtonShadowView.swift
//
//  Created by Sergey Gorin on 29/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class ButtonShadowView: UIView {
    
    var shadowColorWhenEnabled: UIColor = .black {
        didSet {
            if isEnabled {
                layer.shadowColor = shadowColorWhenEnabled.cgColor
            }
        }
    }
    
    var shadowColorWhenDisabled: UIColor = .black {
        didSet {
            if !isEnabled {
                layer.shadowColor = shadowColorWhenDisabled.cgColor
            }
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            layer.shadowColor = isEnabled
                ? shadowColorWhenEnabled.cgColor
                : shadowColorWhenDisabled.cgColor
            button.isEnabled = isEnabled
        }
    }
    
    private var touchClosure: ((UIButton) -> Void)?
    
    lazy var button = BaseButton().with {
        $0.clipsToBounds = true
        $0.addTarget(self, action: #selector(onTouchUpInside), for: .touchUpInside)
    }
    
    init() {
        super.init(frame: .zero)
        layer.shadowColor = shadowColorWhenEnabled.cgColor
        layer.shadowOffset = CGSize(width: 0.0, height: 3.0)
        layer.shadowOpacity = 0.5
        layer.shadowRadius = 5
        
        addSubview(button)
        
        button.xt.pinEdges()
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func onTouch(_ closure: ((UIButton) -> Void)?) {
        touchClosure = closure
    }
    
    @objc private func onTouchUpInside(_ sender: UIButton) {
        touchClosure?(sender)
    }
}
