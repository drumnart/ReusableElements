//
//  BlurEffectButton.swift
//
//  Created by Sergey Gorin on 27/09/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class BlurEffectButton: UIButton {

    var style: UIBlurEffect.Style = .extraLight {
        didSet {
            blurEffectView.effect = UIBlurEffect(style: style)
        }
    }
    
    lazy var blurEffectView = UIVisualEffectView(effect: effect).with {
        $0.isUserInteractionEnabled = false
    }
    
    lazy var vibrancyEffectView = UIVisualEffectView(effect:
        UIVibrancyEffect(blurEffect: effect)
    )
    
    private var effect: UIBlurEffect {
        return UIBlurEffect(style: style)
    }
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        setup()
    }
    
    private func setup() {
        enableEffect()
    }
    
    func enableEffect() {
        let vibrancy = UIVibrancyEffect(blurEffect: effect)
        let vibrancyView = UIVisualEffectView(effect: vibrancy)
        
        if let imageView = imageView {
            insertSubview(blurEffectView, belowSubview: imageView)
            vibrancyView.contentView.addSubview(imageView)
        }
        
        if let titleLabel = titleLabel {
            vibrancyView.contentView.addSubview(titleLabel)
        }
        blurEffectView.effect = effect
        blurEffectView.contentView.addSubview(vibrancyView)
        
        vibrancyView.xt.pinEdges()
        blurEffectView.xt.pinEdges()
        
    }
    
    func disableEffect() {
        blurEffectView.effect = nil
        blurEffectView.removeFromSuperview()
        if let imageView = imageView {
            addSubview(imageView)
        }
        if let titleLabel = titleLabel {
            addSubview(titleLabel)
        }
    }
}
