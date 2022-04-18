//
//  CGFloat+Extensions.swift
//
//  Created by Sergey Gorin on 20/09/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

extension CGFloat {
    
    /// Returns self converted to relative dimension (density-independent pixels).
    /// - Parameter baseWidth: The base screen width the UI is desiged on.
    func dp(baseWidth: CGFloat = 375.0) -> CGFloat {
        return (self /? baseWidth) * UIScreen.main.bounds.width
    }
    
    var dp: CGFloat { return dp() }
}

extension Int {
    
    var dp: CGFloat { return CGFloat(self).dp }
}
