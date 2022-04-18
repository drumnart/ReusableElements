//
//  Xt+UIStackView.swift
//
//  Created by Sergey Gorin on 09.11.2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

//extension UIStackView: XtCompatible {}

extension Xt where Base: UIStackView {
    
    /// Add several arranged subviews to the stackview at once
    func addArrangedSubviews(_ subviews: [UIView]) {
        subviews.forEach { base.addArrangedSubview($0) }
    }
    
    /// Add several subviews  to the stackview at once
    func addArrangedSubviews(_ subviews: UIView...) {
        subviews.forEach { base.addArrangedSubview($0) }
    }
}
