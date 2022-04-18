//
//  UINavigationBar+Extensions.swift
//
//  Created by Sergey Gorin on 18/08/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

extension UINavigationBar {
    
    func enableTransparency(withImage bgImage: UIImage? = UIImage()) {
        setBackgroundImage(bgImage, for: .default)
        isTranslucent = true
        shadowImage = UIImage()
        backgroundColor = nil
    }
    
    func disableTransparency() {
        setBackgroundImage(nil, for: .default)
        shadowImage = nil
        isTranslucent = false
        backgroundColor = nil
    }
}
