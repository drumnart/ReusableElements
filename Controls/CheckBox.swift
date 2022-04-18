//
//  CheckBox.swift
//
//  Created by Sergey Gorin on 15/04/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

class CheckBox: WidenTouchAreaButton {

    override init(frame: CGRect) {
        super.init(frame: frame)
        prepare()
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        prepare()
    }

    private func prepare() {
        tintColor = .tbxCheckboxNotActive
        setImage(Asset.CheckBox.checkboxNotActive.image.withRenderingMode(.alwaysTemplate),
                 for: .normal)
        setImage(Asset.CheckBox.checkboxActive.image, for: .selected)
    }
}
