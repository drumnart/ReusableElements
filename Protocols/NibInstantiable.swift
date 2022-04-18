//
//  NibInstantiable.swift
//
//  Created by Sergey Gorin on 04/02/2019.
//  Copyright © 2019 Sergey Gorin. All rights reserved.
//

import UIKit

/// To load type-safely from XIB
public protocol NibInstantiable: class {
    static var nib: UINib { get }
}

// Default implementation
extension NibInstantiable {
    public static var nib: UINib {
        return UINib(nibName: String(describing: self), bundle: Bundle(for: self))
    }
}

extension NibInstantiable where Self: UIView {
    
    /// Instantiating UIView object from nib
    public func loadFromNib(_ owner: Self? = Self(), options: [UINib.OptionsKey: Any]? = nil) -> Self {
        return Self.loadFromNib(owner, options: options)
    }
    
    /// Instantiating UIView object from nib
    public static func loadFromNib(_ owner: Self? = Self(), options: [UINib.OptionsKey: Any]? = nil) -> Self {
        
        let topObjects = nib.instantiate(withOwner: owner, options: options)
        if let owner = owner {
            for view in topObjects {
                if let view = view as? UIView {
                    owner.addSubview(view)
                }
            }
            return owner
        } else {
            guard let view = topObjects.first as? Self else {
                fatalError("Top level view in nib \(nib) isn't of type \(self)")
            }
            return view
        }
    }
}
